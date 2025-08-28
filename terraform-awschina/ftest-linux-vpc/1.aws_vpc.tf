#################### VPC ####################
resource "aws_vpc" "vpcFTest" {
  assign_generated_ipv6_cidr_block = "false"
  cidr_block                       = var.cidrVpcFTest
  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_classiclink               = false
  instance_tenancy                 = "default"

  tags = {
    Name      = var.vpcName
    Terraform = true
    Project   = var.ProjectName
  }
}

