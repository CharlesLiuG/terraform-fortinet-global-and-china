#################### vsw Primary ####################
resource "alicloud_vswitch" "vswFTest" {
  vpc_id       = alicloud_vpc.vpcFTest.id
  cidr_block   = var.cidrVswFTest
  zone_id      = data.alicloud_instance_types.instanceTypeFTest.instance_types.0.availability_zones.0
  vswitch_name = var.nameVswFTest

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
