#################### VPC ####################
resource "alicloud_vpc" "vpcNgfw" {
  cidr_block = var.cidrVpcNgfw
  vpc_name   = var.vpcName

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

