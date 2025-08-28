locals {
  nameRtbPrivate = "rtb-fgt-private"
}

#################### Route Table DEFINITION ####################
# resource "alicloud_route_table" "rtbFgtPublic" {
#   vpc_id = aws_vpc.vpcNgfw.id

#   tags = {
#     Name      = "RouteTable of FGT Public Subnet"
#     Terraform = true
#   }
# }

resource "alicloud_route_table" "rtbFgtPrivate" {
  depends_on       = [alicloud_vswitch.vswPrivate]
  vpc_id           = alicloud_vpc.vpcNgfw.id
  route_table_name = local.nameRtbPrivate

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}



#################### Route Table Association DEFINITION ####################
# resource "alicloud_route_table_attachment" "subnetPublicAssociate" {
#   subnet_id      = aws_subnet.subnetPublic.id
#   route_table_id = aws_route_table.rtbFgtPublic.id
# }

resource "alicloud_route_table_attachment" "vswPrivateAssociate" {
  depends_on     = [alicloud_route_table.rtbFgtPrivate]
  vswitch_id     = alicloud_vswitch.vswPrivate.id
  route_table_id = alicloud_route_table.rtbFgtPrivate.id
}



#################### UDR(User Defined Routes) DEFINITION ####################
# resource "alicloud_route_entry" "externalRoute" {
#   route_table_id         = aws_route_table.rtbFgtPublic.id
#   gateway_id             = aws_internet_gateway.vpcNgfwIgw.id
#   destination_cidr_block = "0.0.0.0/0"
# }

resource "alicloud_route_entry" "internalRoute" {
  depends_on = [alicloud_route_table.rtbFgtPrivate]

  # The Default Route
  route_table_id        = alicloud_route_table.rtbFgtPrivate.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NetworkInterface"
  nexthop_id            = alicloud_ecs_network_interface.eniFgtPrivate.id
}
