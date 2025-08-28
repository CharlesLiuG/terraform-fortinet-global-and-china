locals {
  nameSubnetFgtPublicAz1  = "subnet-fgt-public-az1"
  nameSubnetFgtPrivateAz1 = "subnet-fgt-private-az1"
  nameSubnetFgtHAsyncAz1  = "subnet-fgt-hasync-az1"
  nameSubnetFgtMgmtAz1    = "subnet-fgt-mgmt-az1"
  nameSubnetFgtTgwAz1     = "subnet-tgwc-landing-fgt-az1"
  nameSubnetFgtPublicAz2  = "subnet-fgt-public-az2"
  nameSubnetFgtPrivateAz2 = "subnet-fgt-private-az2"
  nameSubnetFgtHAsyncAz2  = "subnet-fgt-hasync-az2"
  nameSubnetFgtMgmtAz2    = "subnet-fgt-mgmt-az2"
  nameSubnetFgtTgwAz2     = "subnet-tgwc-landing-fgt-az2"
}

#################### Subnet FGT1 ####################
resource "aws_subnet" "subnetFgtPublicAz1" {
  vpc_id            = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtPublicAz1
  availability_zone = var.azFtnt1

  tags = {
    Name      = local.nameSubnetFgtPublicAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_subnet" "subnetFgtPrivateAz1" {
  vpc_id            = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtPrivateAz1
  availability_zone = var.azFtnt1

  tags = {
    Name      = local.nameSubnetFgtPrivateAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_subnet" "subnetFgtHAsyncAz1" {
  vpc_id            = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtHAsyncAz1
  availability_zone = var.azFtnt1

  tags = {
    Name      = local.nameSubnetFgtHAsyncAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_subnet" "subnetFgtMgmtAz1" {
  count = var.isProvision3PortsHA == true ? 0 : 1

  vpc_id            = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtMgmtAz1
  availability_zone = var.azFtnt1

  tags = {
    Name      = local.nameSubnetFgtMgmtAz1
    Terraform = true
    Project   = var.ProjectName
  }
}


resource "aws_subnet" "subnetFgtTgwAz1" {
  count = var.isProvisionFgtTgwLandingSubnets == true ? 1 : 0

  vpc_id            = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtTgwAz1
  availability_zone = var.azFtnt1

  tags = {
    Name      = local.nameSubnetFgtTgwAz1
    Terraform = true
    Project   = var.ProjectName
  }
}




#################### Subnet FGT2 ####################
resource "aws_subnet" "subnetFgtPublicAz2" {
  vpc_id            = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtPublicAz2
  availability_zone = var.azFtnt2

  tags = {
    Name      = local.nameSubnetFgtPublicAz2
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_subnet" "subnetFgtPrivateAz2" {
  vpc_id            = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtPrivateAz2
  availability_zone = var.azFtnt2

  tags = {
    Name      = local.nameSubnetFgtPrivateAz2
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_subnet" "subnetFgtHAsyncAz2" {
  vpc_id            = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtHAsyncAz2
  availability_zone = var.azFtnt2

  tags = {
    Name      = local.nameSubnetFgtHAsyncAz2
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_subnet" "subnetFgtMgmtAz2" {
  count = var.isProvision3PortsHA == true ? 0 : 1

  vpc_id            = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtMgmtAz2
  availability_zone = var.azFtnt2

  tags = {
    Name      = local.nameSubnetFgtMgmtAz2
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_subnet" "subnetFgtTgwAz2" {
  count = var.isProvisionFgtTgwLandingSubnets == true ? 1 : 0

  vpc_id            = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  cidr_block        = var.cidrSubnetFgtTgwAz2
  availability_zone = var.azFtnt2

  tags = {
    Name      = local.nameSubnetFgtTgwAz2
    Terraform = true
    Project   = var.ProjectName
  }
}
