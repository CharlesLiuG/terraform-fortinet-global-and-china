locals {
  cpu_core_count             = 1        # <- Modifiable
  memory_size                = 1        # <- Modifiable
  eni_amount                 = 1        # <- Modifiable
  spot_strategy              = "NoSpot" # <- Modifiable [NoSpot | SpotAsPriceGo]
  internet_max_bandwidth_out = 0        # <- Modifiable [0: no internet]
}

data "alicloud_images" "imageFTestLinux" {
  owners     = "system"
  name_regex = "^ubuntu_18_04_x64" # <- Modifiable [^ubuntu_18_04_x64 | ^centos_7]
  status     = "Available"
}

data "alicloud_instance_types" "instanceTypeFTest2" {
  availability_zone    = alicloud_vswitch.vswFTest2.availability_zone
  image_id             = data.alicloud_images.imageFTestLinux.images.0.id
  network_type         = "Vpc"
  system_disk_category = var.region2Name == "cn-shanghai" ? "cloud_ssd" : "cloud_essd"
  instance_type_family = var.region2Name == "cn-shanghai" ? "ecs.t5" : "ecs.s6"
  instance_charge_type = "PostPaid"
  cpu_core_count       = local.cpu_core_count
  memory_size          = local.memory_size
  eni_amount           = local.eni_amount
  spot_strategy        = local.spot_strategy
}

data "alicloud_instance_types" "instanceTypeFTest3" {
  availability_zone    = alicloud_vswitch.vswFTest3.availability_zone
  image_id             = data.alicloud_images.imageFTestLinux.images.0.id
  network_type         = "Vpc"
  system_disk_category = var.region3Name == "cn-shanghai" ? "cloud_ssd" : "cloud_essd"
  instance_type_family = var.region3Name == "cn-shanghai" ? "ecs.t5" : "ecs.s6"
  instance_charge_type = "PostPaid"
  cpu_core_count       = local.cpu_core_count
  memory_size          = local.memory_size
  eni_amount           = local.eni_amount
  spot_strategy        = local.spot_strategy
}


resource "alicloud_instance" "ftestLinux2" {
  instance_name              = "FTest-Linux2-${terraform.workspace}"
  host_name                  = "FTest-Linux2-${terraform.workspace}"
  vswitch_id                 = alicloud_vswitch.vswFTest2.id
  security_groups            = alicloud_security_group.sgFTest2.*.id
  private_ip                 = var.ipAddrFTestVpc2
  internet_max_bandwidth_out = local.internet_max_bandwidth_out
  instance_type              = data.alicloud_instance_types.instanceTypeFTest2.instance_types.0.id
  spot_strategy              = data.alicloud_instance_types.instanceTypeFTest2.spot_strategy
  image_id                   = data.alicloud_images.imageFTestLinux.images.0.id
  instance_charge_type       = data.alicloud_instance_types.instanceTypeFTest2.instance_charge_type
  system_disk_category       = data.alicloud_instance_types.instanceTypeFTest2.system_disk_category
  system_disk_size           = 20

  user_data = var.cloudInitScriptPath != "" ? file(var.cloudInitScriptPath) : ""

  password = var.passwordFTest

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}


resource "alicloud_instance" "ftestLinux3" {
  instance_name              = "FTest-Linux3-${terraform.workspace}"
  host_name                  = "FTest-Linux3-${terraform.workspace}"
  vswitch_id                 = alicloud_vswitch.vswFTest3.id
  security_groups            = alicloud_security_group.sgFTest3.*.id
  private_ip                 = var.ipAddrFTestVpc3
  internet_max_bandwidth_out = local.internet_max_bandwidth_out
  instance_type              = data.alicloud_instance_types.instanceTypeFTest3.instance_types.0.id
  spot_strategy              = data.alicloud_instance_types.instanceTypeFTest3.spot_strategy
  image_id                   = data.alicloud_images.imageFTestLinux.images.0.id
  instance_charge_type       = data.alicloud_instance_types.instanceTypeFTest3.instance_charge_type
  system_disk_category       = data.alicloud_instance_types.instanceTypeFTest3.system_disk_category
  system_disk_size           = 20

  password = var.passwordFTest

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
