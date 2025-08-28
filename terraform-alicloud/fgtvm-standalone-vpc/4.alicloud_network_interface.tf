locals {
  nameEniFgtPublic  = "eni-fgt-public"
  nameEniFgtPrivate = "eni-fgt-private"
}


resource "alicloud_ecs_network_interface" "eniFgtPrivate" {
  network_interface_name = local.nameEniFgtPrivate
  vswitch_id             = alicloud_vswitch.vswPrivate.id
  security_group_ids     = [alicloud_security_group.sgFgtPrivate.id]
  primary_ip_address     = var.ipAddrPrivateFgt

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}


resource "alicloud_ecs_network_interface_attachment" "eniFgtPrivateAttach" {
  instance_id          = alicloud_instance.fgtStandalone.id
  network_interface_id = alicloud_ecs_network_interface.eniFgtPrivate.id
}
