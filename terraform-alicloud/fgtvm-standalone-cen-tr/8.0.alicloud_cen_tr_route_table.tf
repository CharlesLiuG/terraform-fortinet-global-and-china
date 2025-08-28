locals {
  trtbUntrustedName = "tr-routetable-untrusted"
  trtbTrustName     = "tr-routetable-trust"
}

#################### TR RouteTable Untrusted ####################
resource "alicloud_cen_transit_router_route_table" "trtbUntrusted" {
  transit_router_id               = alicloud_cen_transit_router.trRegion1.transit_router_id
  transit_router_route_table_name = local.trtbUntrustedName
}


resource "alicloud_cen_transit_router_route_table_association" "trtbUntrustedAssociationVpc2" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.trtbUntrusted.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.centrVpc2Attachment.transit_router_attachment_id
}

resource "alicloud_cen_transit_router_route_table_association" "trtbUntrustedAssociationVpc3" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.trtbUntrusted.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.centrVpc3Attachment.transit_router_attachment_id
}

resource "alicloud_cen_transit_router_route_entry" "trouteToVpcNgfw" {
  transit_router_route_table_id                     = alicloud_cen_transit_router_route_table.trtbUntrusted.transit_router_route_table_id
  transit_router_route_entry_destination_cidr_block = "0.0.0.0/0"
  transit_router_route_entry_next_hop_type          = "Attachment"
  transit_router_route_entry_name                   = "default-to-${lower(var.vpc1Name)}"
  transit_router_route_entry_next_hop_id            = alicloud_cen_transit_router_vpc_attachment.centrVpc1Attachment.transit_router_attachment_id
}


#################### TR RouteTable Trusted ####################
resource "alicloud_cen_transit_router_route_table" "trtbTrust" {
  transit_router_id               = alicloud_cen_transit_router.trRegion1.transit_router_id
  transit_router_route_table_name = local.trtbTrustName
}

resource "alicloud_cen_transit_router_route_table_association" "trtbTrustAssociationVpcNgfw" {
  transit_router_route_table_id = alicloud_cen_transit_router_route_table.trtbTrust.transit_router_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.centrVpc1Attachment.transit_router_attachment_id
}

resource "alicloud_cen_transit_router_route_entry" "trouteBackToVpcNgfw" {
  transit_router_route_table_id                     = alicloud_cen_transit_router_route_table.trtbTrust.transit_router_route_table_id
  transit_router_route_entry_destination_cidr_block = var.cidrVpcNgfw
  transit_router_route_entry_next_hop_type          = "Attachment"
  transit_router_route_entry_name                   = "to-${lower(var.vpc1Name)}"
  transit_router_route_entry_next_hop_id            = alicloud_cen_transit_router_vpc_attachment.centrVpc1Attachment.transit_router_attachment_id
}

resource "alicloud_cen_transit_router_route_entry" "trouteBackToVpc2" {
  transit_router_route_table_id                     = alicloud_cen_transit_router_route_table.trtbTrust.transit_router_route_table_id
  transit_router_route_entry_destination_cidr_block = var.cidrVpc2
  transit_router_route_entry_next_hop_type          = "Attachment"
  transit_router_route_entry_name                   = "to-${lower(var.vpc2Name)}"
  transit_router_route_entry_next_hop_id            = alicloud_cen_transit_router_vpc_attachment.centrVpc2Attachment.transit_router_attachment_id
}

resource "alicloud_cen_transit_router_route_entry" "trouteBackToVpc3" {
  transit_router_route_table_id                     = alicloud_cen_transit_router_route_table.trtbTrust.transit_router_route_table_id
  transit_router_route_entry_destination_cidr_block = var.cidrVpc3
  transit_router_route_entry_next_hop_type          = "Attachment"
  transit_router_route_entry_name                   = "to-${lower(var.vpc3Name)}"
  transit_router_route_entry_next_hop_id            = alicloud_cen_transit_router_vpc_attachment.centrVpc3Attachment.transit_router_attachment_id
}
