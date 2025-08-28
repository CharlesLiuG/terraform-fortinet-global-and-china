#################### vsw FGT ####################
resource "alicloud_vswitch" "vswPublic" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswPublic
  zone_id      = var.region1Name == "cn-shanghai" ? data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.0 : data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
  vswitch_name = var.nameVswPublic

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswPrivate" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswPrivate
  zone_id      = var.region1Name == "cn-shanghai" ? data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.0 : data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
  vswitch_name = var.nameVswPrivate

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}


#################### vsw FTest ####################
resource "alicloud_vswitch" "vswFTest2" {
  vpc_id       = alicloud_vpc.vpc2.id
  cidr_block   = var.cidrVswFTestVpc2
  zone_id      = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
  vswitch_name = var.nameVswFTestVpc2

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswFTest3" {
  vpc_id       = alicloud_vpc.vpc3.id
  cidr_block   = var.cidrVswFTestVpc3
  zone_id      = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]
  vswitch_name = var.nameVswFTestVpc3

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
