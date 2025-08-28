#################### VPC ####################
resource "alicloud_vpc" "vpcFTest" {
  cidr_block = var.cidrVpcFTest
  vpc_name   = var.vpcName

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

