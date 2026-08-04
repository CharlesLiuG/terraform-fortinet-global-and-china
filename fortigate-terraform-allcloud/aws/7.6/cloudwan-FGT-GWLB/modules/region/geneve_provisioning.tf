# ─────────────────────────────────────────────────────────────────────────────────
# GENEVE Provisioning
#
# After both FortiGate instances and GWLB are created, SSH into each FortiGate
# and configure GENEVE tunnels pointing to the GWLB ENI IPs.
#
# FortiOS doesn't support Terraform remote-exec (no SCP/script upload).
# We use local-exec with sshpass + ssh to pipe commands directly.
# ─────────────────────────────────────────────────────────────────────────────────

# ── Lookup GWLB ENI IPs after GWLB is fully created ────────────────────────────
#
# The GWLB creates one ENI per subnet_mapping. Its description is exactly
#   "ELB gwy/<lb-name>/<lb-id>"
# which is aws_lb.gwlb.arn_suffix prefixed with "ELB ". Matching on that instead
# of the old "*ELB gwy/*" wildcard means:
#   - the filter cannot pick up an ENI belonging to a different GWLB in the VPC
#   - reading arn_suffix makes the dependency on aws_lb.gwlb explicit, so the
#     read is ordered after the LB reaches active state (its ENIs then exist)
#     without relying on depends_on, which would defer the read and make the
#     GENEVE trigger values unknown at plan time
#
# lifecycle.postcondition turns a silent empty match into an immediate, readable
# failure rather than a FortiGate configured with a blank remote-ip.
locals {
  gwlb_eni_description = "ELB ${aws_lb.gwlb.arn_suffix}"
}

data "aws_network_interface" "gwlb_az1" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.sec.id]
  }

  filter {
    name   = "description"
    values = [local.gwlb_eni_description]
  }

  filter {
    name   = "subnet-id"
    values = [aws_subnet.sec_internal_az1.id]
  }

  lifecycle {
    postcondition {
      condition     = self.private_ip != ""
      error_message = "No GWLB ENI found in the AZ1 internal subnet — check that the GWLB finished provisioning."
    }
  }
}

data "aws_network_interface" "gwlb_az2" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.sec.id]
  }

  filter {
    name   = "description"
    values = [local.gwlb_eni_description]
  }

  filter {
    name   = "subnet-id"
    values = [aws_subnet.sec_internal_az2.id]
  }

  lifecycle {
    postcondition {
      condition     = self.private_ip != ""
      error_message = "No GWLB ENI found in the AZ2 internal subnet — check that the GWLB finished provisioning."
    }
  }
}

# ── Configure GENEVE on Primary FortiGate ───────────────────────────────────────
resource "null_resource" "geneve_primary" {
  depends_on = [
    aws_instance.fortigate_primary,
    aws_lb.gwlb,
    aws_eip_association.primary_mgmt,
  ]

  triggers = {
    gwlb_az1_ip = data.aws_network_interface.gwlb_az1.private_ip
    gwlb_az2_ip = data.aws_network_interface.gwlb_az2.private_ip
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting ${var.fortigate_boot_wait}s for FortiGate to boot + license activation + reboot..."
      sleep ${var.fortigate_boot_wait}
      echo "Starting SSH connectivity check to ${aws_eip.primary_mgmt.public_ip}..."
      for i in 1 2 3 4 5 6 7 8 9 10; do
        if sshpass -p '${var.fortigate_admin_password}' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=20 admin@${aws_eip.primary_mgmt.public_ip} "get system status" 2>/dev/null; then
          echo "SSH connection successful on attempt $i"
          break
        fi
        echo "Attempt $i failed, waiting 60s before retry..."
        sleep 60
      done
      sshpass -p '${var.fortigate_admin_password}' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=60 admin@${aws_eip.primary_mgmt.public_ip} << 'EOF'
config system geneve
edit gwlb-az1
set interface port2
set type ppp
set remote-ip ${data.aws_network_interface.gwlb_az1.private_ip}
next
edit gwlb-az2
set interface port2
set type ppp
set remote-ip ${data.aws_network_interface.gwlb_az2.private_ip}
next
end
config system zone
edit gwlb-geneve
set intrazone allow
set interface gwlb-az1 gwlb-az2
next
end
config router policy
edit 1
set input-device gwlb-az1
set src 0.0.0.0/0.0.0.0
set dst 0.0.0.0/0.0.0.0
set output-device gwlb-az1
next
edit 2
set input-device gwlb-az2
set src 0.0.0.0/0.0.0.0
set dst 0.0.0.0/0.0.0.0
set output-device gwlb-az2
next
end
config router static
edit 10
set dst 10.0.0.0 255.0.0.0
set device gwlb-az1
set priority 10
next
edit 11
set dst 10.0.0.0 255.0.0.0
set device gwlb-az2
set priority 10
next
end
config firewall policy
edit 1
set name gwlb-inspection
set srcintf gwlb-geneve
set dstintf gwlb-geneve
set action accept
set srcaddr all
set dstaddr all
set schedule always
set service ALL
set logtraffic all
next
edit 2
set name gwlb-to-internet
set srcintf gwlb-geneve
set dstintf port1
set action accept
set srcaddr all
set dstaddr all
set schedule always
set service ALL
set logtraffic all
set nat enable
next
end
EOF
    EOT
  }
}

# ── Configure GENEVE on Secondary FortiGate ─────────────────────────────────────
resource "null_resource" "geneve_secondary" {
  depends_on = [
    aws_instance.fortigate_secondary,
    aws_lb.gwlb,
    aws_eip_association.secondary_mgmt,
  ]

  triggers = {
    gwlb_az1_ip = data.aws_network_interface.gwlb_az1.private_ip
    gwlb_az2_ip = data.aws_network_interface.gwlb_az2.private_ip
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting ${var.fortigate_boot_wait}s for FortiGate to boot + license activation + reboot..."
      sleep ${var.fortigate_boot_wait}
      echo "Starting SSH connectivity check to ${aws_eip.secondary_mgmt.public_ip}..."
      for i in 1 2 3 4 5 6 7 8 9 10; do
        if sshpass -p '${var.fortigate_admin_password}' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=20 admin@${aws_eip.secondary_mgmt.public_ip} "get system status" 2>/dev/null; then
          echo "SSH connection successful on attempt $i"
          break
        fi
        echo "Attempt $i failed, waiting 60s before retry..."
        sleep 60
      done
      sshpass -p '${var.fortigate_admin_password}' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=60 admin@${aws_eip.secondary_mgmt.public_ip} << 'EOF'
config system geneve
edit gwlb-az1
set interface port2
set type ppp
set remote-ip ${data.aws_network_interface.gwlb_az1.private_ip}
next
edit gwlb-az2
set interface port2
set type ppp
set remote-ip ${data.aws_network_interface.gwlb_az2.private_ip}
next
end
config system zone
edit gwlb-geneve
set intrazone allow
set interface gwlb-az1 gwlb-az2
next
end
config router policy
edit 1
set input-device gwlb-az1
set src 0.0.0.0/0.0.0.0
set dst 0.0.0.0/0.0.0.0
set output-device gwlb-az1
next
edit 2
set input-device gwlb-az2
set src 0.0.0.0/0.0.0.0
set dst 0.0.0.0/0.0.0.0
set output-device gwlb-az2
next
end
config router static
edit 10
set dst 10.0.0.0 255.0.0.0
set device gwlb-az1
set priority 10
next
edit 11
set dst 10.0.0.0 255.0.0.0
set device gwlb-az2
set priority 10
next
end
config firewall policy
edit 1
set name gwlb-inspection
set srcintf gwlb-geneve
set dstintf gwlb-geneve
set action accept
set srcaddr all
set dstaddr all
set schedule always
set service ALL
set logtraffic all
next
edit 2
set name gwlb-to-internet
set srcintf gwlb-geneve
set dstintf port1
set action accept
set srcaddr all
set dstaddr all
set schedule always
set service ALL
set logtraffic all
set nat enable
next
end
EOF
    EOT
  }
}
