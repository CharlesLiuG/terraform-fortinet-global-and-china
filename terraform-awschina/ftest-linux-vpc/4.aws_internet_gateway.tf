resource "aws_internet_gateway" "vpcFTestIgw" {
  vpc_id = aws_vpc.vpcFTest.id

  tags = {
    Name      = "IGW"
    Terraform = true
    Project   = var.ProjectName
  }
}
