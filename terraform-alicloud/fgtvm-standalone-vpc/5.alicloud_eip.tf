locals {
  nameEipFgt = "eip-fgt"
}

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
  instance_id   = alicloud_instance.fgtStandalone.id
}
