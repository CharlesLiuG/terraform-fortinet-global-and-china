locals {
  nameEniPublicFgt1  = "eni-fgt1-public"
  nameEniPrivateFgt1 = "eni-fgt1-private"
  nameEniHAsyncFgt1  = "eni-fgt1-hasync"
  nameEniMgmtFgt1    = "eni-fgt1-mgmt"
  nameEniPublicFgt2  = "eni-fgt2-public"
  nameEniPrivateFgt2 = "eni-fgt2-private"
  nameEniHAsyncFgt2  = "eni-fgt2-hasync"
  nameEniMgmtFgt2    = "eni-fgt2-mgmt"
}

#################### FGT1 port2 ####################
resource "alicloud_ecs_network_interface" "eniPrivateFgt1" {
  network_interface_name = local.nameEniPrivateFgt1
  vswitch_id             = alicloud_vswitch.vswPrivateFgt1.id
  security_group_ids     = [alicloud_security_group.sgFgtPrivate.id]
  primary_ip_address     = var.ipAddrPrivateFgt1

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_ecs_network_interface_attachment" "eniPrivateFgt1Attach" {
  instance_id          = alicloud_instance.fgt1.id
  network_interface_id = alicloud_ecs_network_interface.eniPrivateFgt1.id
}


#################### FGT1 port3 ####################
resource "alicloud_ecs_network_interface" "eniHAsyncFgt1" {
  network_interface_name = local.nameEniHAsyncFgt1
  vswitch_id             = alicloud_vswitch.vswHAsyncFgt1.id
  security_group_ids     = [alicloud_security_group.sgFgtHAMgmt.id]
  primary_ip_address     = var.ipAddrHAsyncFgt1

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_ecs_network_interface_attachment" "eniHAsyncFgt1Attach" {
  depends_on           = [alicloud_ecs_network_interface_attachment.eniPrivateFgt1Attach]
  instance_id          = alicloud_instance.fgt1.id
  network_interface_id = alicloud_ecs_network_interface.eniHAsyncFgt1.id
}


#################### FGT1 port4 ####################
resource "alicloud_ecs_network_interface" "eniMgmtFgt1" {
  network_interface_name = local.nameEniMgmtFgt1
  vswitch_id             = alicloud_vswitch.vswMgmtFgt1.id
  security_group_ids     = [alicloud_security_group.sgFgtHAMgmt.id]
  primary_ip_address     = var.ipAddrMgmtFgt1

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_ecs_network_interface_attachment" "eniMgmtFgt1Attach" {
  depends_on           = [alicloud_ecs_network_interface_attachment.eniHAsyncFgt1Attach]
  instance_id          = alicloud_instance.fgt1.id
  network_interface_id = alicloud_ecs_network_interface.eniMgmtFgt1.id
}



#################### FGT2 port2 ####################
resource "alicloud_ecs_network_interface" "eniPrivateFgt2" {
  network_interface_name = local.nameEniPrivateFgt2
  vswitch_id             = alicloud_vswitch.vswPrivateFgt2.id
  security_group_ids     = [alicloud_security_group.sgFgtPrivate.id]
  primary_ip_address     = var.ipAddrPrivateFgt2

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_ecs_network_interface_attachment" "eniPrivateFgt2Attach" {
  instance_id          = alicloud_instance.fgt2.id
  network_interface_id = alicloud_ecs_network_interface.eniPrivateFgt2.id
}


#################### FGT2 port3 ####################
resource "alicloud_ecs_network_interface" "eniHAsyncFgt2" {
  network_interface_name = local.nameEniHAsyncFgt2
  vswitch_id             = alicloud_vswitch.vswHAsyncFgt2.id
  security_group_ids     = [alicloud_security_group.sgFgtHAMgmt.id]
  primary_ip_address     = var.ipAddrHAsyncFgt2

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_ecs_network_interface_attachment" "eniHAsyncFgt2Attach" {
  depends_on           = [alicloud_ecs_network_interface_attachment.eniPrivateFgt2Attach]
  instance_id          = alicloud_instance.fgt2.id
  network_interface_id = alicloud_ecs_network_interface.eniHAsyncFgt2.id
}


#################### FGT2 port4 ####################
resource "alicloud_ecs_network_interface" "eniMgmtFgt2" {
  network_interface_name = local.nameEniMgmtFgt2
  vswitch_id             = alicloud_vswitch.vswMgmtFgt2.id
  security_group_ids     = [alicloud_security_group.sgFgtHAMgmt.id]
  primary_ip_address     = var.ipAddrMgmtFgt2

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_ecs_network_interface_attachment" "eniMgmtFgt2Attach" {
  depends_on           = [alicloud_ecs_network_interface_attachment.eniHAsyncFgt2Attach]
  instance_id          = alicloud_instance.fgt2.id
  network_interface_id = alicloud_ecs_network_interface.eniMgmtFgt2.id
}
