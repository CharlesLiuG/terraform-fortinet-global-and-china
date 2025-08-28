locals {
  nameSubnetFTestAz1 = "subnet-ftest-az1"
}

resource "aws_subnet" "subnetFTestAz1" {
  vpc_id            = aws_vpc.vpcFTest.id
  cidr_block        = var.cidrSubnetFTestAz1
  availability_zone = var.azFtnt1

  tags = {
    Name      = local.nameSubnetFTestAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

