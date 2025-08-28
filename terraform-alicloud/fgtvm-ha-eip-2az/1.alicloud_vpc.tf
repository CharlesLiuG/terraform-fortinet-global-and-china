#################### VPC ####################
resource "alicloud_vpc" "vpcNgfw" {
  cidr_block = var.cidrVpcNgfw
  vpc_name   = var.vpc1Name

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
