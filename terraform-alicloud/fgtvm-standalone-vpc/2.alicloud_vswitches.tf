#################### vsw Primary ####################
resource "alicloud_vswitch" "vswPublic" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswPublic
  zone_id      = data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.0
  vswitch_name = var.vswPublicName

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswPrivate" {
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswPrivate
  zone_id      = data.alicloud_instance_types.instanceTypeFgt.instance_types.0.availability_zones.0
  vswitch_name = var.vswPrivateName

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
