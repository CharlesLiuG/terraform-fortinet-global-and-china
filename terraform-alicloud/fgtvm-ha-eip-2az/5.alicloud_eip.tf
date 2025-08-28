locals {
  nameEipFgt      = "eip-fgt"
  nameEipMgmtFgt1 = "eip-mgmt-fgt1"
  nameEipMgmtFgt2 = "eip-mgmt-fgt2"
}



#################### FGT HA EIP ####################
resource "alicloud_eip_address" "eipFgt" {
  address_name         = local.nameEipFgt
  isp                  = "BGP"
  bandwidth            = 10
  internet_charge_type = var.eipFgtChargeType
  payment_type         = var.eipFgtPaymentType

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_eip_association" "eipFgtAssociate" {
  allocation_id = alicloud_eip_address.eipFgt.id
  instance_id   = alicloud_instance.fgt1.id
}



#################### FGT1 EIP Mgmt ####################
resource "alicloud_eip_address" "eipMgmtFgt1" {
  address_name         = local.nameEipMgmtFgt1
  isp                  = "BGP"
  bandwidth            = 10
  internet_charge_type = var.eipFgtChargeType
  payment_type         = var.eipFgtPaymentType

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_eip_association" "eipMgmtFgt1Associate" {
  instance_type = "NetworkInterface"
  allocation_id = alicloud_eip_address.eipMgmtFgt1.id
  instance_id   = alicloud_ecs_network_interface.eniMgmtFgt1.id
}



#################### FGT2 EIP Mgmt ####################
resource "alicloud_eip_address" "eipMgmtFgt2" {
  address_name         = local.nameEipMgmtFgt2
  isp                  = "BGP"
  bandwidth            = 10
  internet_charge_type = var.eipFgtChargeType
  payment_type         = var.eipFgtPaymentType

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_eip_association" "eipMgmtFgt2Associate" {
  instance_type = "NetworkInterface"
  allocation_id = alicloud_eip_address.eipMgmtFgt2.id
  instance_id   = alicloud_ecs_network_interface.eniMgmtFgt2.id
}
