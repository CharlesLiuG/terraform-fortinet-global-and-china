resource "aws_vpc" "vpcNgfw" {
  count = var.isProvisionVpcNgfw == true ? 1 : 0

  cidr_block           = var.cidrVpcNgfw
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name      = var.vpcName
    Terraform = true
    Project   = var.ProjectName
  }
}
