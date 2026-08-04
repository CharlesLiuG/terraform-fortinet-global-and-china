# External EIPs — one per FortiGate for independent outbound NAT (FGSP Active-Active)
resource "aws_eip" "primary_external" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-primary-external-eip"
  })
}

resource "aws_eip_association" "primary_external" {
  network_interface_id = aws_network_interface.primary_external.id
  allocation_id        = aws_eip.primary_external.id

  depends_on = [aws_instance.fortigate_primary]
}

resource "aws_eip" "secondary_external" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-secondary-external-eip"
  })
}

resource "aws_eip_association" "secondary_external" {
  network_interface_id = aws_network_interface.secondary_external.id
  allocation_id        = aws_eip.secondary_external.id

  depends_on = [aws_instance.fortigate_secondary]
}

# Individual management EIPs — one per FortiGate, stay pinned regardless of HA state
resource "aws_eip" "primary_mgmt" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-primary-mgmt-eip"
  })
}

resource "aws_eip_association" "primary_mgmt" {
  network_interface_id = aws_network_interface.primary_mgmt.id
  allocation_id        = aws_eip.primary_mgmt.id

  depends_on = [aws_instance.fortigate_primary]
}

resource "aws_eip" "secondary_mgmt" {
  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-secondary-mgmt-eip"
  })
}

resource "aws_eip_association" "secondary_mgmt" {
  network_interface_id = aws_network_interface.secondary_mgmt.id
  allocation_id        = aws_eip.secondary_mgmt.id

  depends_on = [aws_instance.fortigate_secondary]
}
