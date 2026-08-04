data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az1 = data.aws_availability_zones.available.names[0]
  az2 = data.aws_availability_zones.available.names[1]
}

data "aws_ami" "fortigate" {
  most_recent = true
  owners      = ["679593333241"] # Fortinet Marketplace account

  filter {
    name = "name"
    values = [
      var.license_type == "byol"
      ? "FortiGate-VM64-AWS*(${var.fortios_version}*)*"
      : "FortiGate-VM64-AWSONDEMAND*(${var.fortios_version}*)*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  # Standard AL2023 only. The looser "al2023-ami-*-x86_64" pattern also matched
  # "al2023-ami-minimal-*", which ships without amazon-ssm-agent — an instance
  # from that image never registers with Session Manager. Anchoring on the
  # "2023<version>...-kernel-<ver>" naming keeps the minimal and ECS/EKS-optimized
  # variants out.
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── GWLB ENI IPs are looked up in geneve_provisioning.tf ────────────────────────
# No data sources needed here — FortiGate instances are created without GWLB
# dependency. GENEVE configuration is applied post-deployment via provisioner.
