locals {
  nameEniFTestWebsrv     = terraform.workspace == "default" ? "eni-ftest" : "eni-ftest-${terraform.workspace}"
  hostnameFTestWebsrv    = terraform.workspace == "default" ? "ftest-websrv" : "ftest-websrv-${terraform.workspace}"
  instanceTypeFTestLinux = "t2.micro"

  subnetFTestWebsrvList = [
    aws_subnet.subnetFgtPrivateAz1
  ]

  sgFTestList = [
    aws_security_group.sgFgtPrivate
  ]
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

resource "aws_instance" "ftestWebsrv" {
  # FLAG for toggling resource on/off
  count = var.isProvisionDnatWebSrv == true ? length(local.subnetFTestWebsrvList) : 0

  depends_on = [
    aws_instance.fgtStandalone,
    aws_route_table.rtbFgtPublic,
    aws_route_table.rtbFgtPrivate
  ]

  ami               = data.aws_ami.ubuntu.id
  instance_type     = local.instanceTypeFTestLinux
  availability_zone = local.subnetFTestWebsrvList[count.index].availability_zone
  key_name          = var.keyName

  user_data = var.cloudInitScriptPath != "" ? file(var.cloudInitScriptPath) : ""

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    volume_size           = "20"
    volume_type           = "gp2"
  }

  network_interface {
    network_interface_id = aws_network_interface.eniFTestWebsrv[count.index].id
    device_index         = 0
  }

  tags = {
    Name      = "${local.hostnameFTestWebsrv}-${count.index}"
    Terraform = true
    Project   = var.ProjectName
  }
}


resource "aws_network_interface" "eniFTestWebsrv" {
  # FLAG for toggling resource on/off
  count = var.isProvisionDnatWebSrv == true ? length(local.subnetFTestWebsrvList) : 0

  description = "${local.nameEniFTestWebsrv}-${count.index}"
  subnet_id   = local.subnetFTestWebsrvList[count.index].id
  private_ips = [var.ipAddrFgtDnatWebsrv]

  tags = {
    Name      = "${local.nameEniFTestWebsrv}-${count.index}"
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_sg_attachment" "eniFTestWebsrvAttach" {
  # FLAG for toggling resource on/off
  count = var.isProvisionDnatWebSrv == true ? length(local.subnetFTestWebsrvList) : 0

  depends_on           = [aws_network_interface.eniFTestWebsrv]
  security_group_id    = local.sgFTestList[count.index].id
  network_interface_id = aws_network_interface.eniFTestWebsrv[count.index].id
}
