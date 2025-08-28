locals {
  nameInstanceFgt1Full = terraform.workspace == "default" ? var.hostnameFgtAz1 : "${var.hostnameFgtAz1}-${terraform.workspace}"
  nameInstanceFgt2Full = terraform.workspace == "default" ? var.hostnameFgtAz2 : "${var.hostnameFgtAz2}-${terraform.workspace}"
  nameInternalSrv      = "WEB-SRV" # <- Modifiable
}

locals {
  nameEniFgtPublicAz1  = "eni-fgt-public-az1"
  nameEniFgtPrivateAz1 = "eni-fgt-private-az1"
  nameEniFgtHAsyncAz1  = "eni-fgt-hasync-az1"
  nameEniFgtMgmtAz1    = "eni-fgt-mgmt-az1"
  nameEniFgtPublicAz2  = "eni-fgt-public-az2"
  nameEniFgtPrivateAz2 = "eni-fgt-private-az2"
  nameEniFgtHAsyncAz2  = "eni-fgt-hasync-az2"
  nameEniFgtMgmtAz2    = "eni-fgt-mgmt-az2"
}

locals {
  nameEipFgtCluster = "eip-cluster"
  nameEipFgtMgmtAz1 = "eip-fgt-mgmt-az1"
  nameEipFgtMgmtAz2 = "eip-fgt-mgmt-az2"
}

resource "aws_instance" "fgt1" {
  depends_on           = [aws_iam_instance_profile.iamInstanceProfileFgtHA]
  ami                  = var.imageVersion == "fgtvm64" ? data.aws_ami.amiFgtvm64.id : var.imageVersion == "fgtvm70" ? data.aws_ami.amiFgtvm70.id : data.aws_ami.amiFgtvm72.id
  instance_type        = var.instanceTypeFgtDesignated
  availability_zone    = var.azFtnt1
  iam_instance_profile = aws_iam_instance_profile.iamInstanceProfileFgtHA.name
  user_data = templatefile(var.instanceBootstrapFgt1,
    {
      licenseType               = var.licenseType
      licenseFile               = var.license1File
      portFgtHttps              = var.portFgtHttps
      cidrDestination           = var.cidrSubnetFgtPrivateAz2
      ipAddrPublic              = var.ipAddrFgtPublicAz1
      ipMaskPublic              = cidrnetmask(var.cidrSubnetFgtPublicAz1)
      ipAddrPrivate             = var.ipAddrFgtPrivateAz1
      ipMaskPrivate             = cidrnetmask(var.cidrSubnetFgtPrivateAz1)
      ipAddrHAsync              = var.ipAddrFgtHAsyncAz1
      ipMaskHAsync              = cidrnetmask(var.cidrSubnetFgtHAsyncAz1)
      ipAddrHAsyncPeer          = var.ipAddrFgtHAsyncAz2
      ipAddrMgmt                = var.ipAddrFgtMgmtAz1
      ipMaskMgmt                = cidrnetmask(var.cidrSubnetFgtMgmtAz1)
      fgtConfPort1Gw            = cidrhost(var.cidrSubnetFgtPublicAz1, 1)
      fgtConfPort2Gw            = cidrhost(var.cidrSubnetFgtPrivateAz1, 1)
      fgtConfPort3Gw            = cidrhost(var.cidrSubnetFgtHAsyncAz1, 1)
      fgtConfPort4Gw            = cidrhost(var.cidrSubnetFgtMgmtAz1, 1)
      fgtConfHostname           = local.nameInstanceFgt1Full
      ipAddrVipWebSrv           = var.ipAddrVipWebSrv
      portFgtDnatWebsrvInt      = var.portFgtDnatWebsrvInt
      portFgtDnatWebsrvExt      = var.portFgtDnatWebsrvExt
      nameFgtDnatWebsrv         = "VIP-${local.nameInternalSrv}-${var.ipAddrVipWebSrv}"
      nameFgtPolicyDnatToWebsrv = "to-vip-${lower(local.nameInternalSrv)}"
      isProvisionDnatWebSrv     = var.isProvisionDnatWebSrv
      isProvision3PortsHA       = var.isProvision3PortsHA
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
    network_interface_id = aws_network_interface.eniFgtPublicAz1.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eniFgtPrivateAz1.id
    device_index         = 1
  }

  network_interface {
    network_interface_id = aws_network_interface.eniFgtHAsyncAz1.id
    device_index         = 2
  }

  tags = {
    Name      = local.nameInstanceFgt1Full
    Terraform = true
    Project   = var.ProjectName
  }
}



#################### FGT Cluster EIP ####################
resource "aws_eip" "eipCluster" {
  count = var.isProvisionFgtEips == true ? 1 : 0

  vpc = true

  tags = {
    Name      = local.nameEipFgtCluster
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_eip_association" "eipAssocFgtPublicAz1" {
  depends_on           = [aws_network_interface.eniFgtPublicAz1]
  network_interface_id = aws_network_interface.eniFgtPublicAz1.id
  allocation_id        = var.isProvisionFgtEips == true ? aws_eip.eipCluster[0].id : var.eipIdCluster
}

data "aws_eip" "eipIdClusterByData" {
  count = var.isProvisionFgtEips == false ? 1 : 0
  id    = var.eipIdCluster
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

resource "aws_network_interface_sg_attachment" "sgFgtPublicAttachEniFgtPublicAz1" {
  depends_on           = [aws_network_interface.eniFgtPublicAz1]
  security_group_id    = aws_security_group.sgFgtPublic.id
  network_interface_id = aws_network_interface.eniFgtPublicAz1.id
}

resource "aws_network_interface_sg_attachment" "sgFgtDnatWebSrvAttachEniFgtPublicAz1" {
  count = var.isProvisionDnatWebSrv == true ? 1 : 0

  depends_on           = [aws_network_interface.eniFgtPublicAz1]
  security_group_id    = aws_security_group.sgFgtDnatWebSrv[0].id
  network_interface_id = aws_network_interface.eniFgtPublicAz1.id
}

resource "aws_network_interface_sg_attachment" "sgFgtIPsecAttachEniFgtPublicAz1" {
  count = var.isProvisionIPsec == true ? 1 : 0

  depends_on           = [aws_network_interface.eniFgtPublicAz1]
  security_group_id    = aws_security_group.sgFgtIPsec[0].id
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

#################### FGT1 port3 ####################
resource "aws_network_interface" "eniFgtHAsyncAz1" {
  description       = local.nameEniFgtHAsyncAz1
  subnet_id         = aws_subnet.subnetFgtHAsyncAz1.id
  private_ips       = [var.ipAddrFgtHAsyncAz1]
  source_dest_check = false

  tags = {
    Name      = local.nameEniFgtHAsyncAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_sg_attachment" "eniFgtHAsyncAz1Attach" {
  depends_on           = [aws_network_interface.eniFgtHAsyncAz1]
  security_group_id    = var.isProvision3PortsHA == true ? aws_security_group.sgFgtPublic.id : aws_security_group.sgFgtPrivate.id
  network_interface_id = aws_network_interface.eniFgtHAsyncAz1.id
}



#################### FGT1 EIP Mgmt ####################
resource "aws_eip" "eipFgtMgmtAz1" {
  count = var.isProvisionFgtEips == true ? 1 : 0

  depends_on = [aws_network_interface.eniFgtMgmtAz1]
  vpc        = true

  tags = {
    Name      = local.nameEipFgtMgmtAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_eip_association" "eipAssocFgtMgmtAz1" {
  depends_on = [
    aws_network_interface.eniFgtMgmtAz1,
    aws_network_interface.eniFgtHAsyncAz1
  ]
  network_interface_id = var.isProvision3PortsHA == true ? aws_network_interface.eniFgtHAsyncAz1.id : aws_network_interface.eniFgtMgmtAz1[0].id
  allocation_id        = var.isProvisionFgtEips == true ? aws_eip.eipFgtMgmtAz1[0].id : var.eipIdFgtMgmtAz1
}

data "aws_eip" "eipIdFgtMgmtAz1ByData" {
  count = var.isProvisionFgtEips == true ? 0 : 1
  id    = var.eipIdFgtMgmtAz1
}



#################### FGT1 port4 ####################
resource "aws_network_interface" "eniFgtMgmtAz1" {
  count = var.isProvision3PortsHA == true ? 0 : 1

  description = local.nameEniFgtMgmtAz1
  subnet_id   = aws_subnet.subnetFgtMgmtAz1[0].id
  private_ips = [var.ipAddrFgtMgmtAz1]

  tags = {
    Name      = local.nameEniFgtMgmtAz1
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_attachment" "eniFgtMgmtAz1AttachFgtAz1" {
  count = var.isProvision3PortsHA == true ? 0 : 1

  instance_id          = aws_instance.fgt1.id
  network_interface_id = aws_network_interface.eniFgtMgmtAz1[0].id
  device_index         = 3
}

resource "aws_network_interface_sg_attachment" "sgFgtPublicAttachEniFgtMgmtAz1" {
  count = var.isProvision3PortsHA == true ? 0 : 1

  depends_on           = [aws_network_interface.eniFgtMgmtAz1]
  security_group_id    = aws_security_group.sgFgtPublic.id
  network_interface_id = aws_network_interface.eniFgtMgmtAz1[0].id
}
