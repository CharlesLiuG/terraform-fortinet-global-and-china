#################### VPC ####################
resource "alicloud_vpc" "vpcNgfw" {
  cidr_block = var.cidrVpcNgfw
  vpc_name   = var.vpc1Name

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}


resource "alicloud_vpc" "vpc2" {
  cidr_block = var.cidrVpc2
  vpc_name   = var.vpc2Name

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vpc" "vpc3" {
  cidr_block = var.cidrVpc3
  vpc_name   = var.vpc3Name

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
