#################### VPC ####################
resource "aws_vpc" "vpcNgfw" {
  count = var.isProvisionVpcNgfw == true ? 1 : 0

  assign_generated_ipv6_cidr_block = "false"
  cidr_block                       = var.cidrVpcNgfw
  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_classiclink               = false
  instance_tenancy                 = "default"

  tags = {
    Name      = var.vpcNameNgfw
    Terraform = true
    Project   = var.ProjectName
  }
}

