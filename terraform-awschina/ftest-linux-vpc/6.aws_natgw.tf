locals {
  nameSubnetNatgwAz1 = "subnet-natgw-az1"
  nameNatgwAz1       = "natgw-az1"
  nameEipNatgwAz1    = "eip-natgw-az1"
  nameRtbNatgw       = "rtb-natgw"
}



#################### NATGW Subnet ####################
resource "aws_subnet" "subnetNatgwAz1" {
  count = var.isProvisionNatgw == true ? 1 : 0

  vpc_id            = aws_vpc.vpcFTest.id
  cidr_block        = var.cidrSubnetNatgwAz1
  availability_zone = var.azFtnt1

  tags = {
    Name      = local.nameSubnetNatgwAz1
    Terraform = true
    Project   = var.ProjectName
  }
}



#################### NATGW ####################
resource "aws_eip" "eipNatgwAz1" {
  count = var.isProvisionNatgw == true ? 1 : 0

  depends_on = [aws_internet_gateway.vpcFTestIgw]

  vpc = true

  tags = {
    Name      = local.nameEipNatgwAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_nat_gateway" "natgwAz1" {
  count = var.isProvisionNatgw == true ? 1 : 0

  depends_on = [aws_internet_gateway.vpcFTestIgw]

  allocation_id     = aws_eip.eipNatgwAz1[0].id
  connectivity_type = "public"
  subnet_id         = aws_subnet.subnetNatgwAz1[0].id

  tags = {
    Name      = local.nameNatgwAz1
    Terraform = true
    Project   = var.ProjectName
  }
}



#################### NATGW RouteTable ####################
resource "aws_route_table" "rtbNatgw" {
  count = var.isProvisionNatgw == true ? 1 : 0

  vpc_id = aws_vpc.vpcFTest.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpcFTestIgw.id
  }

  tags = {
    Name      = local.nameRtbNatgw
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_route_table_association" "rtbNatgwAssocSubnetNatgwAz1" {
  count = var.isProvisionNatgw == true ? 1 : 0

  subnet_id      = aws_subnet.subnetNatgwAz1[0].id
  route_table_id = aws_route_table.rtbNatgw[0].id
}
