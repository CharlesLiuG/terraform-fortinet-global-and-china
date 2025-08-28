locals {
  cenInstanceName = "cen-ftnt"
  cenTRName       = "tr-${var.region1Name}"
}

resource "alicloud_cen_instance" "cenInstance" {
  cen_instance_name = local.cenInstanceName
  protection_level  = "REDUCED" # CIDR overlapping is allowed

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_cen_transit_router" "trRegion1" {
  transit_router_name = local.cenTRName
  cen_id              = alicloud_cen_instance.cenInstance.id
}
