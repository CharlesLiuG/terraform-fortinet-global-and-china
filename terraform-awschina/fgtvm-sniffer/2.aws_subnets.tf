locals {
  nameSubnetFgtPublicAz1  = "subnet-fgt-public-az1"
  nameSubnetFgtPrivateAz1 = "subnet-fgt-private-az1"
}

#################### Subnet AZ1 ####################
resource "aws_subnet" "subnetFgtPublicAz1" {
  vpc_id            = var.isProvisionVpcSniffer == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtPublicAz1
  availability_zone = var.azFtnt1

  tags = {
    Name      = local.nameSubnetFgtPublicAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_subnet" "subnetFgtPrivateAz1" {
  vpc_id            = var.isProvisionVpcSniffer == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtPrivateAz1
  availability_zone = var.azFtnt1

  tags = {
    Name      = local.nameSubnetFgtPrivateAz1
    Terraform = true
    Project   = var.ProjectName
  }
}
