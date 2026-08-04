locals {
  # Primary is deployed in AZ1, secondary in AZ2.
  # IPs are assigned at .10 in each subnet so they're deterministic for the
  # userdata template without needing a second pass.
  primary_external_ip = cidrhost(local.sec_external_az1_cidr, 10)
  primary_internal_ip = cidrhost(local.sec_internal_az1_cidr, 10)
  primary_ha_ip       = cidrhost(local.sec_ha_az1_cidr, 10)
  primary_mgmt_ip     = cidrhost(local.sec_mgmt_az1_cidr, 10)

  secondary_external_ip = cidrhost(local.sec_external_az2_cidr, 10)
  secondary_internal_ip = cidrhost(local.sec_internal_az2_cidr, 10)
  secondary_ha_ip       = cidrhost(local.sec_ha_az2_cidr, 10)
  secondary_mgmt_ip     = cidrhost(local.sec_mgmt_az2_cidr, 10)
}

# ── Primary FortiGate ENIs (4 ports) ───────────────────────────────────────────
resource "aws_network_interface" "primary_external" {
  subnet_id         = aws_subnet.sec_external_az1.id
  private_ips       = [local.primary_external_ip]
  security_groups   = [aws_security_group.fgt_external.id]
  source_dest_check = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-primary-external"
  })
}

resource "aws_network_interface" "primary_internal" {
  subnet_id         = aws_subnet.sec_internal_az1.id
  private_ips       = [local.primary_internal_ip]
  security_groups   = [aws_security_group.fgt_internal.id]
  source_dest_check = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-primary-internal"
  })
}

resource "aws_network_interface" "primary_ha" {
  subnet_id         = aws_subnet.sec_ha_az1.id
  private_ips       = [local.primary_ha_ip]
  security_groups   = [aws_security_group.fgt_ha.id]
  source_dest_check = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-primary-ha"
  })
}

resource "aws_network_interface" "primary_mgmt" {
  subnet_id         = aws_subnet.sec_mgmt_az1.id
  private_ips       = [local.primary_mgmt_ip]
  security_groups   = [aws_security_group.fgt_mgmt.id]
  source_dest_check = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-primary-mgmt"
  })
}

# ── Secondary FortiGate ENIs (4 ports) ─────────────────────────────────────────
resource "aws_network_interface" "secondary_external" {
  subnet_id         = aws_subnet.sec_external_az2.id
  private_ips       = [local.secondary_external_ip]
  security_groups   = [aws_security_group.fgt_external.id]
  source_dest_check = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-secondary-external"
  })
}

resource "aws_network_interface" "secondary_internal" {
  subnet_id         = aws_subnet.sec_internal_az2.id
  private_ips       = [local.secondary_internal_ip]
  security_groups   = [aws_security_group.fgt_internal.id]
  source_dest_check = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-secondary-internal"
  })
}

resource "aws_network_interface" "secondary_ha" {
  subnet_id         = aws_subnet.sec_ha_az2.id
  private_ips       = [local.secondary_ha_ip]
  security_groups   = [aws_security_group.fgt_ha.id]
  source_dest_check = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-secondary-ha"
  })
}

resource "aws_network_interface" "secondary_mgmt" {
  subnet_id         = aws_subnet.sec_mgmt_az2.id
  private_ips       = [local.secondary_mgmt_ip]
  security_groups   = [aws_security_group.fgt_mgmt.id]
  source_dest_check = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-secondary-mgmt"
  })
}

# ── Primary instance ────────────────────────────────────────────────────────────
resource "aws_instance" "fortigate_primary" {
  ami                  = data.aws_ami.fortigate.id
  instance_type        = var.fortigate_instance_type
  key_name             = local.keypair
  iam_instance_profile = aws_iam_instance_profile.fortigate_ha.name
  user_data            = local.primary_userdata

  # port1 = external
  network_interface {
    network_interface_id = aws_network_interface.primary_external.id
    device_index         = 0
  }

  # port2 = internal (GWLB target via GENEVE)
  network_interface {
    network_interface_id = aws_network_interface.primary_internal.id
    device_index         = 1
  }

  # port3 = ha
  network_interface {
    network_interface_id = aws_network_interface.primary_ha.id
    device_index         = 2
  }

  # port4 = mgmt
  network_interface {
    network_interface_id = aws_network_interface.primary_mgmt.id
    device_index         = 3
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-primary"
  })
}

# ── Secondary instance ──────────────────────────────────────────────────────────
resource "aws_instance" "fortigate_secondary" {
  ami                  = data.aws_ami.fortigate.id
  instance_type        = var.fortigate_instance_type
  key_name             = local.keypair
  iam_instance_profile = aws_iam_instance_profile.fortigate_ha.name
  user_data            = local.secondary_userdata

  # port1 = external
  network_interface {
    network_interface_id = aws_network_interface.secondary_external.id
    device_index         = 0
  }

  # port2 = internal (GWLB target via GENEVE)
  network_interface {
    network_interface_id = aws_network_interface.secondary_internal.id
    device_index         = 1
  }

  # port3 = ha
  network_interface {
    network_interface_id = aws_network_interface.secondary_ha.id
    device_index         = 2
  }

  # port4 = mgmt
  network_interface {
    network_interface_id = aws_network_interface.secondary_mgmt.id
    device_index         = 3
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-secondary"
  })
}
