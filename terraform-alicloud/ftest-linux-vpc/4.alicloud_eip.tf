locals {
  nameEipFTest = "eip-ftest"
}

resource "alicloud_eip_address" "eipFTest" {
  address_name         = local.nameEipFTest
  isp                  = "BGP"
  bandwidth            = 10 # <- Modifiable
  internet_charge_type = var.eipFTestChargeType
  payment_type         = var.eipFTestPaymentType

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_eip_association" "eipFgtAssociate" {
  allocation_id = alicloud_eip_address.eipFTest.id
  instance_id   = alicloud_instance.ftestLinux.id
}
