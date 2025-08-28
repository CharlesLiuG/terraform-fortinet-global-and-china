resource "aws_instance" "fgt2" {
  depends_on           = [aws_instance.fgt1]
  ami                  = var.imageVersion == "fgtvm64" ? data.aws_ami.amiFgtvm64.id : var.imageVersion == "fgtvm70" ? data.aws_ami.amiFgtvm70.id : data.aws_ami.amiFgtvm72.id
  instance_type        = var.instanceTypeFgtDesignated
  availability_zone    = var.azFtnt2
  iam_instance_profile = aws_iam_instance_profile.iamInstanceProfileFgtHA.name

  user_data = templatefile(var.instanceBootstrapFgt2,
    {
      licenseType         = var.licenseType
      licenseFile         = var.license2File
      portFgtHttps        = var.portFgtHttps
      cidrDestination     = var.cidrSubnetFgtPrivateAz1
      ipAddrPublic        = var.ipAddrFgtPublicAz2
      ipMaskPublic        = cidrnetmask(var.cidrSubnetFgtPublicAz2)
      ipAddrPrivate       = var.ipAddrFgtPrivateAz2
      ipMaskPrivate       = cidrnetmask(var.cidrSubnetFgtPrivateAz2)
      ipAddrHAsync        = var.ipAddrFgtHAsyncAz2
      ipMaskHAsync        = cidrnetmask(var.cidrSubnetFgtHAsyncAz2)
      ipAddrHAsyncPeer    = var.ipAddrFgtHAsyncAz1
      ipAddrMgmt          = var.ipAddrFgtMgmtAz2
      ipMaskMgmt          = cidrnetmask(var.cidrSubnetFgtMgmtAz2)
      fgtConfPort1Gw      = cidrhost(var.cidrSubnetFgtPublicAz2, 1)
      fgtConfPort2Gw      = cidrhost(var.cidrSubnetFgtPrivateAz2, 1)
      fgtConfPort3Gw      = cidrhost(var.cidrSubnetFgtHAsyncAz2, 1)
      fgtConfPort4Gw      = cidrhost(var.cidrSubnetFgtMgmtAz2, 1)
      fgtConfHostname     = local.nameInstanceFgt2Full
      isProvision3PortsHA = var.isProvision3PortsHA
    }
  )

  root_block_device {
    delete_on_termination = "true"
    volume_type           = "standard"
    volume_size           = "2"
  }

  ebs_block_device {
    delete_on_termination = "true"
    device_name           = "/dev/sdb"
    volume_size           = "40"
    volume_type           = "standard"
  }

  network_interface {
    network_interface_id = aws_network_interface.eniFgtPublicAz2.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eniFgtPrivateAz2.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.eniFgtHAsyncAz2.id
    device_index         = 2
  }

  tags = {
    Name      = local.nameInstanceFgt2Full
    Terraform = true
    Project   = var.ProjectName
  }
}



#################### FGT2 port1 ####################
resource "aws_network_interface" "eniFgtPublicAz2" {
  description = local.nameEniFgtPublicAz2
  subnet_id   = aws_subnet.subnetFgtPublicAz2.id
  private_ips = [var.ipAddrFgtPublicAz2]

  tags = {
    Name      = local.nameEniFgtPublicAz2
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_sg_attachment" "sgFgtPublicAttachEniFgtPublicAz2" {
  depends_on           = [aws_network_interface.eniFgtPublicAz2]
  security_group_id    = aws_security_group.sgFgtPublic.id
  network_interface_id = aws_network_interface.eniFgtPublicAz2.id
}

resource "aws_network_interface_sg_attachment" "sgFgtDnatWebSrvAttachEniFgtPublicAz2" {
  count = var.isProvisionDnatWebSrv == true ? 1 : 0

  depends_on           = [aws_network_interface.eniFgtPublicAz2]
  security_group_id    = aws_security_group.sgFgtDnatWebSrv[0].id
  network_interface_id = aws_network_interface.eniFgtPublicAz2.id
}

resource "aws_network_interface_sg_attachment" "sgFgtIPsecAttachEniFgtPublicAz2" {
  count = var.isProvisionIPsec == true ? 1 : 0

  depends_on           = [aws_network_interface.eniFgtPublicAz2]
  security_group_id    = aws_security_group.sgFgtIPsec[0].id
  network_interface_id = aws_network_interface.eniFgtPublicAz2.id
}



#################### FGT2 port2 ####################
resource "aws_network_interface" "eniFgtPrivateAz2" {
  description       = local.nameEniFgtPrivateAz2
  subnet_id         = aws_subnet.subnetFgtPrivateAz2.id
  private_ips       = [var.ipAddrFgtPrivateAz2]
  source_dest_check = false

  tags = {
    Name      = local.nameEniFgtPrivateAz2
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_sg_attachment" "eniFgtPrivateAz2Attach" {
  depends_on           = [aws_network_interface.eniFgtPrivateAz2]
  security_group_id    = aws_security_group.sgFgtPrivate.id
  network_interface_id = aws_network_interface.eniFgtPrivateAz2.id
}

#################### FGT2 port3 ####################
resource "aws_network_interface" "eniFgtHAsyncAz2" {
  description       = local.nameEniFgtHAsyncAz2
  subnet_id         = aws_subnet.subnetFgtHAsyncAz2.id
  private_ips       = [var.ipAddrFgtHAsyncAz2]
  source_dest_check = false

  tags = {
    Name      = local.nameEniFgtHAsyncAz2
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_sg_attachment" "eniFgtHAsyncAz2Attach" {
  depends_on           = [aws_network_interface.eniFgtHAsyncAz2]
  security_group_id    = var.isProvision3PortsHA == true ? aws_security_group.sgFgtPublic.id : aws_security_group.sgFgtPrivate.id
  network_interface_id = aws_network_interface.eniFgtHAsyncAz2.id
}



#################### FGT2 EIP Mgmt ####################
resource "aws_eip" "eipFgtMgmtAz2" {
  count = var.isProvisionFgtEips == true ? 1 : 0

  depends_on = [aws_network_interface.eniFgtMgmtAz2]
  vpc        = true

  tags = {
    Name      = local.nameEipFgtMgmtAz2
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_eip_association" "eipAssocFgtMgmtAz2" {
  depends_on = [
    aws_network_interface.eniFgtMgmtAz2,
    aws_network_interface.eniFgtHAsyncAz2
  ]
  network_interface_id = var.isProvision3PortsHA == true ? aws_network_interface.eniFgtHAsyncAz2.id : aws_network_interface.eniFgtMgmtAz2[0].id
  allocation_id        = var.isProvisionFgtEips == true ? aws_eip.eipFgtMgmtAz2[0].id : var.eipIdFgtMgmtAz2
}

data "aws_eip" "eipIdFgtMgmtAz2ByData" {
  count = var.isProvisionFgtEips == false ? 1 : 0
  id    = var.eipIdFgtMgmtAz2
}

#################### FGT2 port4 ####################
resource "aws_network_interface" "eniFgtMgmtAz2" {
  count = var.isProvision3PortsHA == true ? 0 : 1

  description = local.nameEniFgtMgmtAz2
  subnet_id   = aws_subnet.subnetFgtMgmtAz2[0].id
  private_ips = [var.ipAddrFgtMgmtAz2]

  tags = {
    Name      = local.nameEniFgtMgmtAz2
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_attachment" "eniFgtMgmtAz1AttachFgtAz2" {
  count = var.isProvision3PortsHA == true ? 0 : 1

  instance_id          = aws_instance.fgt2.id
  network_interface_id = aws_network_interface.eniFgtMgmtAz2[0].id
  device_index         = 3
}

resource "aws_network_interface_sg_attachment" "sgFgtPublicAttachEniFgtMgmtAz2" {
  count = var.isProvision3PortsHA == true ? 0 : 1

  depends_on           = [aws_network_interface.eniFgtMgmtAz2]
  security_group_id    = aws_security_group.sgFgtPublic.id
  network_interface_id = aws_network_interface.eniFgtMgmtAz2[0].id
}
