data "alicloud_instance_types" "instanceTypeFTest" {
  image_id             = data.alicloud_images.imageFTestLinux.images.0.id
  network_type         = "Vpc"
  system_disk_category = var.regionName == "cn-shanghai" || var.regionName == "cn-qingdao" ? "cloud_ssd" : "cloud_essd"
  instance_type_family = var.ecsFamilyDesignated != "" ? var.ecsFamilyDesignated : var.regionName == "cn-shanghai" || var.regionName == "cn-qingdao" ? "ecs.t5" : "ecs.s6"
  instance_charge_type = "PostPaid"
  cpu_core_count       = var.vCpuDesignated != "" ? var.vCpuDesignated : 1                        # <- Modifiable
  memory_size          = var.ramDesignated != "" ? var.ramDesignated : 1                          # <- Modifiable
  spot_strategy        = var.spotStrategyDesignated != "" ? var.spotStrategyDesignated : "NoSpot" # <- Modifiable [NoSpot | SpotAsPriceGo]
}

data "alicloud_images" "imageFTestLinux" {
  owners     = "system"
  name_regex = "^ubuntu_18_04_x64" # <- Modifiable [^ubuntu_18_04_x64 | ^centos_7 (not validated)]
  status     = "Available"
}

resource "alicloud_instance" "ftestLinux" {
  instance_name        = "FTest-Linux-${terraform.workspace}"
  host_name            = "FTest-Linux-${terraform.workspace}"
  vswitch_id           = alicloud_vswitch.vswFTest.id
  security_groups      = alicloud_security_group.sgFTest.*.id
  private_ip           = var.ipPrivateFTest
  instance_type        = var.instanceTypeFgtDesignated != "" ? var.instanceTypeFgtDesignated : data.alicloud_instance_types.instanceTypeFTest.instance_types.0.id
  spot_strategy        = data.alicloud_instance_types.instanceTypeFTest.spot_strategy
  image_id             = data.alicloud_images.imageFTestLinux.images.0.id
  instance_charge_type = data.alicloud_instance_types.instanceTypeFTest.instance_charge_type
  system_disk_category = data.alicloud_instance_types.instanceTypeFTest.system_disk_category
  system_disk_size     = 20

  user_data = var.cloudInitScriptPath != "" ? file(var.cloudInitScriptPath) : ""

  password = var.passwordFTest
  key_name = var.keyNameFTest

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
