locals {
  nameRtbFgtPublic  = "rtb-fgt-public"
  nameRtbFgtPrivate = "rtb-fgt-private"
  nameRtbFgtTgw     = "rtb-fgt-tgw"
}

#################### Route Table Fgt Public ####################
resource "aws_route_table" "rtbFgtPublic" {
  vpc_id = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.isProvisionVpcNgfw == true ? aws_internet_gateway.vpcNgfwIgw[0].id : var.paramIgwId
  }

  tags = {
    Name      = local.nameRtbFgtPublic
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_route_table_association" "associateSubnetFgtPublicAz1" {
  subnet_id      = aws_subnet.subnetFgtPublicAz1.id
  route_table_id = aws_route_table.rtbFgtPublic.id
}

resource "aws_route_table_association" "associateSubnetFgtPublicAz2" {
  subnet_id      = aws_subnet.subnetFgtPublicAz2.id
  route_table_id = aws_route_table.rtbFgtPublic.id
}

resource "aws_route_table_association" "associateSubnetFgtMgmtAz1" {
  subnet_id      = var.isProvision3PortsHA == true ? aws_subnet.subnetFgtHAsyncAz1.id : aws_subnet.subnetFgtMgmtAz1[0].id
  route_table_id = aws_route_table.rtbFgtPublic.id
}

resource "aws_route_table_association" "associateSubnetFgtMgmtAz2" {
  subnet_id      = var.isProvision3PortsHA == true ? aws_subnet.subnetFgtHAsyncAz2.id : aws_subnet.subnetFgtMgmtAz2[0].id
  route_table_id = aws_route_table.rtbFgtPublic.id
}



################### Route Table Fgt Private ####################
resource "aws_route_table" "rtbFgtPrivate" {
  vpc_id = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.eniFgtPrivateAz1.id
  }

  tags = {
    Name      = local.nameRtbFgtPrivate
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_route_table_association" "associateSubnetFgtPrivateAz1" {
  subnet_id      = aws_subnet.subnetFgtPrivateAz1.id
  route_table_id = aws_route_table.rtbFgtPrivate.id
}

resource "aws_route_table_association" "associateSubnetFgtPrivateAz2" {
  subnet_id      = aws_subnet.subnetFgtPrivateAz2.id
  route_table_id = aws_route_table.rtbFgtPrivate.id
}



################### Route Table Fgt Tgw ####################
resource "aws_route_table" "rtbFgtTgw" {
  count = var.isProvisionFgtTgwLandingSubnets == true ? 1 : 0

  vpc_id = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.eniFgtPrivateAz1.id
  }

  tags = {
    Name      = local.nameRtbFgtPrivate
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_route_table_association" "associateSubnetFgtTgwAz1" {
  count = var.isProvisionFgtTgwLandingSubnets == true ? 1 : 0

  subnet_id      = aws_subnet.subnetFgtTgwAz1[0].id
  route_table_id = aws_route_table.rtbFgtTgw[0].id
}

resource "aws_route_table_association" "associateSubnetFgtTgwAz2" {
  count = var.isProvisionFgtTgwLandingSubnets == true ? 1 : 0

  subnet_id      = aws_subnet.subnetFgtTgwAz2[0].id
  route_table_id = aws_route_table.rtbFgtTgw[0].id
}
