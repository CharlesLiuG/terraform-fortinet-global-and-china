locals {
  nameEniFTest = "eni-ftest"
  nameEipFTest = "eip-ftest"
  nameRtbFTest = "rtb-ftest"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = var.regionName == "cn-north-1" || var.regionName == "cn-northwest-1" ? ["837727238323"] : ["099720109477"] # Canonical
}


resource "aws_instance" "ftestLinux" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instanceType
  availability_zone = var.azFtnt1
  key_name          = var.keyName

  user_data = var.cloudInitScriptPath != "" ? file(var.cloudInitScriptPath) : ""

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    volume_size           = "20"
    volume_type           = "gp2"
  }

  network_interface {
    network_interface_id = aws_network_interface.eniFTestPublic.id
    device_index         = 0
  }

  tags = {
    Name      = var.hostnameFTest
    Terraform = true
    Project   = var.ProjectName
  }
}



#################### eth0 EIP ####################
resource "aws_eip" "eipFTest" {
  count = var.isProvisionNatgw == true ? 0 : 1

  vpc               = true
  network_interface = aws_network_interface.eniFTestPublic.id
  depends_on        = [aws_internet_gateway.vpcFTestIgw]

  tags = {
    Name      = local.nameEipFTest
    Terraform = true
    Project   = var.ProjectName
  }
}



#################### eth0 ####################
resource "aws_network_interface" "eniFTestPublic" {
  description = local.nameEniFTest
  subnet_id   = aws_subnet.subnetFTestAz1.id
  private_ips = [var.fgtConfVipSrcAddr]

  tags = {
    Name      = local.nameEniFTest
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_sg_attachment" "eniFTestEth0AttachSgPublic" {
  depends_on           = [aws_network_interface.eniFTestPublic]
  security_group_id    = aws_security_group.sgFTestPublic.id
  network_interface_id = aws_network_interface.eniFTestPublic.id
}



#################### Route Table ####################
resource "aws_route_table" "rtbFTest" {
  vpc_id = aws_vpc.vpcFTest.id

  tags = {
    Name      = local.nameRtbFTest
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_route_table_association" "subnetFTestAz1Associate" {
  subnet_id      = aws_subnet.subnetFTestAz1.id
  route_table_id = aws_route_table.rtbFTest.id
}

resource "aws_route" "toInternetRouteByIgw" {
  count = var.isProvisionNatgw == true ? 0 : 1

  route_table_id         = aws_route_table.rtbFTest.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpcFTestIgw.id
}

resource "aws_route" "toInternetRouteByNatgw" {
  count = var.isProvisionNatgw == true ? 1 : 0

  route_table_id         = aws_route_table.rtbFTest.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgwAz1[0].id
}
