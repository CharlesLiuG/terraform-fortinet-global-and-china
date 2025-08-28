locals {
  nameRtbPrivate = "rtb-fgt-private"
}

#################### Route Table Fgt Private (port2) ####################
resource "alicloud_route_table" "rtbFgtPrivate" {
  depends_on       = [alicloud_vswitch.vswPrivateFgt1]
  vpc_id           = alicloud_vpc.vpcNgfw.id
  route_table_name = local.nameRtbPrivate

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

# routetable <-> vsw association
resource "alicloud_route_table_attachment" "vswPrivateFgt1Associate" {
  depends_on     = [alicloud_route_table.rtbFgtPrivate]
  vswitch_id     = alicloud_vswitch.vswPrivateFgt1.id
  route_table_id = alicloud_route_table.rtbFgtPrivate.id
}

# UDR(User Defined Routes) DEFINITION
resource "alicloud_route_entry" "privateDefaultGWv4" {
  depends_on = [alicloud_route_table.rtbFgtPrivate]

  # The Default Route
  route_table_id        = alicloud_route_table.rtbFgtPrivate.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NetworkInterface"
  nexthop_id            = alicloud_ecs_network_interface.eniPrivateFgt1.id
}
