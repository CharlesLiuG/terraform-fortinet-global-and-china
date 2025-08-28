data "alicloud_instance_types" "instanceTypeFTest" {
  availability_zone    = data.alicloud_vswitches.vswFTest.vswitches.0.zone_id
  image_id             = data.alicloud_images.imageFTestLinux.images.0.id
  network_type         = "Vpc"
  system_disk_category = var.regionName == "cn-shanghai" || var.regionName == "cn-qingdao" ? "cloud_ssd" : "cloud_essd"
  instance_type_family = var.regionName == "cn-shanghai" || var.regionName == "cn-qingdao" ? "ecs.t5" : "ecs.s6"
  instance_charge_type = "PostPaid"
  cpu_core_count       = 1        # <- Modifiable
  memory_size          = 1        # <- Modifiable
  spot_strategy        = "NoSpot" # <- Modifiable [NoSpot | SpotAsPriceGo]
}

locals {
  ProjectName               = "ftntDEMO" # <- Modifiable
  internet_egress_bandwidth = 0          # <- Modifiable [0: no internet]
}

data "alicloud_vswitches" "vswFTest" {
  ids = [var.idVswFTest]
}

data "alicloud_images" "imageFTestLinux" {
  owners     = "system"
  name_regex = "^ubuntu_18_04_x64" # <- Modifiable [^ubuntu_18_04_x64 | ^centos_7 (not validated)]
  status     = "Available"
}

resource "alicloud_instance" "ftestLinux" {
  instance_name              = "FTest-Linux-${terraform.workspace}"
  host_name                  = "FTest-Linux-${terraform.workspace}"
  vswitch_id                 = var.idVswFTest
  security_groups            = [var.idSecurityGroupFTest]
  private_ip                 = var.ipPrivateFTest
  internet_max_bandwidth_out = local.internet_egress_bandwidth
  instance_type              = data.alicloud_instance_types.instanceTypeFTest.instance_types.0.id
  spot_strategy              = data.alicloud_instance_types.instanceTypeFTest.spot_strategy
  image_id                   = data.alicloud_images.imageFTestLinux.images.0.id
  instance_charge_type       = data.alicloud_instance_types.instanceTypeFTest.instance_charge_type
  system_disk_category       = data.alicloud_instance_types.instanceTypeFTest.system_disk_category
  system_disk_size           = 20

  user_data = var.cloudInitScriptPath != "" ? file(var.cloudInitScriptPath) : ""
  password = var.passwordFTest

  tags = {
    Terraform = true
    Project   = local.ProjectName
  }
}
