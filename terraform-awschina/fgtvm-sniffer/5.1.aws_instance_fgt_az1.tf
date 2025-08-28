locals {
  nameInstanceFgtAz1Full = terraform.workspace == "default" ? var.hostnameFgtAz1 : "${var.hostnameFgtAz1}-${terraform.workspace}"
}

locals {
  nameEipFgtPublicAz1 = "eip-fgt-mgmt-az1"
}

locals {
  nameEniFgtPublicAz1  = "eni-fgt-mgmt-az1"
  nameEniFgtPrivateAz1 = "eni-fgt-sniffer-az1"
}

resource "aws_instance" "fgtStandalone" {
  ami               = var.imageVersion == "fgtvm64" ? data.aws_ami.amiFgtvm64.id : var.imageVersion == "fgtvm70" ? data.aws_ami.amiFgtvm70.id : data.aws_ami.amiFgtvm72.id
  instance_type     = var.instanceTypeFgt
  availability_zone = var.azFtnt1

  user_data = templatefile(var.instanceBootstrapFile,
    {
      # 2ports base variables
      licenseType     = var.licenseType
      licenseFile     = var.licenseFile
      adminsport      = var.portFgtHttps
      fgtConfHostname = local.nameInstanceFgtAz1Full
    }
  )

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    volume_size           = "2"
    volume_type           = "gp2"
  }

  ebs_block_device {
    delete_on_termination = "true"
    device_name           = "/dev/sdb"
    encrypted             = "false"
    volume_size           = var.dataDiskSzFgt
    volume_type           = "gp2"
  }

  ebs_optimized = "true"

  network_interface {
    network_interface_id = aws_network_interface.eniFgtPublicAz1.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eniFgtPrivateAz1.id
    device_index         = 1
  }

  tags = {
    Name      = local.nameInstanceFgtAz1Full
    Terraform = true
    Project   = var.ProjectName
  }
}


#################### FGT1 port1 EIP ####################
resource "aws_eip" "eipFgtPublicAz1" {
  vpc               = true
  network_interface = aws_network_interface.eniFgtPublicAz1.id
  depends_on        = [aws_route_table.rtbFgtPublic]

  tags = {
    Name      = local.nameEipFgtPublicAz1
    Terraform = true
    Project   = var.ProjectName
  }
}


#################### FGT1 port1 ####################
resource "aws_network_interface" "eniFgtPublicAz1" {
  description = local.nameEniFgtPublicAz1
  subnet_id   = aws_subnet.subnetFgtPublicAz1.id
  private_ips = [var.ipAddrFgtPublicAz1]

  tags = {
    Name      = local.nameEniFgtPublicAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_sg_attachment" "eniFgtPublicAz1Attach" {
  depends_on           = [aws_network_interface.eniFgtPublicAz1]
  security_group_id    = aws_security_group.sgFgtPublic.id
  network_interface_id = aws_network_interface.eniFgtPublicAz1.id
}


#################### FGT1 port2 ####################
resource "aws_network_interface" "eniFgtPrivateAz1" {
  description       = local.nameEniFgtPrivateAz1
  subnet_id         = aws_subnet.subnetFgtPrivateAz1.id
  private_ips       = [var.ipAddrFgtPrivateAz1]
  source_dest_check = false

  tags = {
    Name      = local.nameEniFgtPrivateAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_sg_attachment" "eniFgtPrivateAz1Attach" {
  depends_on           = [aws_network_interface.eniFgtPrivateAz1]
  security_group_id    = aws_security_group.sgFgtPrivate.id
  network_interface_id = aws_network_interface.eniFgtPrivateAz1.id
}
