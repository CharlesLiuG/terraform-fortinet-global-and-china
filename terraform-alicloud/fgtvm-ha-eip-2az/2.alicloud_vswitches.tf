data "alicloud_cen_transit_router_available_resources" "centrLandingVsw" {

}


#################### vsw FGT1 ####################
resource "alicloud_vswitch" "vswPublicFgt1" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswPublicFgt1
  zone_id      = var.region1Name == "cn-shanghai" ? data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.0 : data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
  vswitch_name = var.nameVswPublicFgt1

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswPrivateFgt1" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswPrivateFgt1
  zone_id      = var.region1Name == "cn-shanghai" ? data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.0 : data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
  vswitch_name = var.nameVswPrivateFgt1

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswHAsyncFgt1" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswHAsyncFgt1
  zone_id      = var.region1Name == "cn-shanghai" ? data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.0 : data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
  vswitch_name = var.nameVswHAsyncFgt1

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswMgmtFgt1" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswMgmtFgt1
  zone_id      = var.region1Name == "cn-shanghai" ? data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.0 : data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
  vswitch_name = var.nameVswMgmtFgt1

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

#################### vsw FGT2 ####################
resource "alicloud_vswitch" "vswPublicFgt2" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswPublicFgt2
  zone_id      = var.region1Name == "cn-shanghai" ? data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.1 : data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]
  vswitch_name = var.nameVswPublicFgt2

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswPrivateFgt2" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswPrivateFgt2
  zone_id      = var.region1Name == "cn-shanghai" ? data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.1 : data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]
  vswitch_name = var.nameVswPrivateFgt2

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswHAsyncFgt2" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswHAsyncFgt2
  zone_id      = var.region1Name == "cn-shanghai" ? data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.1 : data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]
  vswitch_name = var.nameVswHAsyncFgt2

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswMgmtFgt2" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswMgmtFgt2
  zone_id      = var.region1Name == "cn-shanghai" ? data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.1 : data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]
  vswitch_name = var.nameVswMgmtFgt2

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
