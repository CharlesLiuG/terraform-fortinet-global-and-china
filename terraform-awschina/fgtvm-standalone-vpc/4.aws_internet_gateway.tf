resource "aws_internet_gateway" "vpcNgfwIgw" {
  count = var.isProvisionVpcNgfw == true ? 1 : 0

  vpc_id = aws_vpc.vpcNgfw[0].id

  tags = {
    Name      = "vpc-ngfw-igw"
    Terraform = true
    Project   = var.ProjectName
  }
}
