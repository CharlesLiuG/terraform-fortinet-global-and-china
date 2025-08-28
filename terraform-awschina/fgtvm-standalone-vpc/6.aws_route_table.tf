locals {
  nameRtbFgtPublic  = "rtb-fgt-public"
  nameRtbFgtPrivate = "rtb-fgt-private"
}

#################### Route Table Fgt Public (port1) ####################
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

resource "aws_route_table_association" "subnetFgtPublicAz1Associate" {
  subnet_id      = aws_subnet.subnetFgtPublicAz1.id
  route_table_id = aws_route_table.rtbFgtPublic.id
}


#################### Route Table Fgt Private (port2) ####################
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

resource "aws_route_table_association" "subnetFgtPrivateAz1Associate" {
  subnet_id      = aws_subnet.subnetFgtPrivateAz1.id
  route_table_id = aws_route_table.rtbFgtPrivate.id
}
