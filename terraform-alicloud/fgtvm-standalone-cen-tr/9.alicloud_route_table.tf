locals {
  nameRtbPrivate       = "rtb-fgt-private"
  nameRtbTRLandingVpc1 = "rtb-trlanding-vpc1"
  nameRtbVpc2          = "rtb-${lower(var.vpc2Name)}"
  nameRtbVpc3          = "rtb-${lower(var.vpc3Name)}"
}

#################### Route Table Fgt Private (port2) ####################
resource "alicloud_route_table" "rtbFgtPrivate" {
  depends_on       = [alicloud_vswitch.vswPrivate]
  vpc_id           = alicloud_vpc.vpcNgfw.id
  route_table_name = local.nameRtbPrivate

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

# routetable <-> vsw association
resource "alicloud_route_table_attachment" "vswPrivateAssociate" {
  depends_on     = [alicloud_route_table.rtbFgtPrivate]
  vswitch_id     = alicloud_vswitch.vswPrivate.id
  route_table_id = alicloud_route_table.rtbFgtPrivate.id
}

# UDR(User Defined Routes) DEFINITION 
resource "alicloud_route_entry" "routeToVpc2" {
  depends_on = [alicloud_route_table.rtbFgtPrivate, alicloud_cen_transit_router_vpc_attachment.centrVpc1Attachment]

  # The Default Route
  route_table_id        = alicloud_route_table.rtbFgtPrivate.id
  destination_cidrblock = var.cidrVpc2
  nexthop_type          = "Attachment"
  nexthop_id            = alicloud_cen_transit_router_vpc_attachment.centrVpc1Attachment.transit_router_attachment_id
}

resource "alicloud_route_entry" "routeToVpc3" {
  depends_on = [alicloud_route_table.rtbFgtPrivate, alicloud_cen_transit_router_vpc_attachment.centrVpc1Attachment]

  # The Default Route
  route_table_id        = alicloud_route_table.rtbFgtPrivate.id
  destination_cidrblock = var.cidrVpc3
  nexthop_type          = "Attachment"
  nexthop_id            = alicloud_cen_transit_router_vpc_attachment.centrVpc1Attachment.transit_router_attachment_id
}


#################### Route Table TRLandingVsw (VpcNgfw) ####################
resource "alicloud_route_table" "rtbTRLandingVpc1" {
  depends_on       = [alicloud_vswitch.vswTRLanding1Vpc1, alicloud_vswitch.vswTRLanding2Vpc1]
  vpc_id           = alicloud_vpc.vpcNgfw.id
  route_table_name = local.nameRtbTRLandingVpc1

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

# routetable <-> vsw association
resource "alicloud_route_table_attachment" "vswTrlanding1Vpc1Associate" {
  depends_on     = [alicloud_route_table.rtbTRLandingVpc1]
  vswitch_id     = alicloud_vswitch.vswTRLanding1Vpc1.id
  route_table_id = alicloud_route_table.rtbTRLandingVpc1.id
}

resource "alicloud_route_table_attachment" "vswTrlanding2Vpc1Associate" {
  depends_on     = [alicloud_route_table.rtbTRLandingVpc1]
  vswitch_id     = alicloud_vswitch.vswTRLanding2Vpc1.id
  route_table_id = alicloud_route_table.rtbTRLandingVpc1.id
}

# UDR(User Defined Routes) DEFINITION 
resource "alicloud_route_entry" "routeToVpcNgfw" {
  depends_on = [alicloud_route_table.rtbTRLandingVpc1]

  # The Default Route
  route_table_id        = alicloud_route_table.rtbTRLandingVpc1.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NetworkInterface"
  nexthop_id            = alicloud_ecs_network_interface.eniFgtPrivate.id
}


#################### Route Table (Vpc2) ####################
resource "alicloud_route_table" "rtbVpc2" {
  depends_on       = [alicloud_vswitch.vswFTest2]
  vpc_id           = alicloud_vpc.vpc2.id
  route_table_name = local.nameRtbVpc2

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

# routetable <-> vsw association
resource "alicloud_route_table_attachment" "vswVpc2Associate" {
  depends_on     = [alicloud_route_table.rtbVpc2]
  vswitch_id     = alicloud_vswitch.vswFTest2.id
  route_table_id = alicloud_route_table.rtbVpc2.id
}

# UDR(User Defined Routes) DEFINITION 
resource "alicloud_route_entry" "routeGwToTrVpc2" {
  depends_on = [alicloud_route_table.rtbVpc2, alicloud_cen_transit_router_vpc_attachment.centrVpc2Attachment]

  # The Default Route
  route_table_id        = alicloud_route_table.rtbVpc2.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "Attachment"
  nexthop_id            = alicloud_cen_transit_router_vpc_attachment.centrVpc2Attachment.transit_router_attachment_id
}


#################### Route Table (Vpc3) ####################
resource "alicloud_route_table" "rtbVpc3" {
  depends_on       = [alicloud_vswitch.vswFTest3]
  vpc_id           = alicloud_vpc.vpc3.id
  route_table_name = local.nameRtbVpc3

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

# routetable <-> vsw association
resource "alicloud_route_table_attachment" "vswVpc3Associate" {
  depends_on     = [alicloud_route_table.rtbVpc3]
  vswitch_id     = alicloud_vswitch.vswFTest3.id
  route_table_id = alicloud_route_table.rtbVpc3.id
}

# UDR(User Defined Routes) DEFINITION 
resource "alicloud_route_entry" "routeGwToTrVpc3" {
  depends_on = [alicloud_route_table.rtbVpc3, alicloud_cen_transit_router_vpc_attachment.centrVpc3Attachment]

  # The Default Route
  route_table_id        = alicloud_route_table.rtbVpc3.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "Attachment"
  nexthop_id            = alicloud_cen_transit_router_vpc_attachment.centrVpc3Attachment.transit_router_attachment_id
}
