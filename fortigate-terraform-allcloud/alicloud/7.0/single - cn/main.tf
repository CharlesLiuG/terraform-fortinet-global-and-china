
data "alicloud_regions" "current_region_ds" {
  current = true
}

data "alicloud_zones" "default" {
}

//Random 3 char string appended to the ened of each name to avoid conflicts
resource "random_string" "random_name_post" {
  length           = 5
  special          = true
  override_special = ""
  min_lower        = 5
}

resource "alicloud_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  vpc_name   = "${random_string.random_name_post.result}-vpc"
}

resource "alicloud_vswitch" "vsw_mgmt" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = var.vswitch_cidr_mgmt
  zone_id      = data.alicloud_zones.default.zones[0].id
  vswitch_name = "terraform-mgmt"
}

resource "alicloud_vswitch" "vsw_internal" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = var.vswitch_cidr_int
  zone_id      = data.alicloud_zones.default.zones[0].id
  vswitch_name = "terraform-int"
}

resource "alicloud_vswitch" "vsw_external" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = var.vswitch_cidr_ext
  zone_id      = data.alicloud_zones.default.zones[0].id
  vswitch_name = "terraform-ext"
}

//Security Group
resource "alicloud_security_group" "SecGroup" {
  name        = "SecGroup-${random_string.random_name_post.result}"
  description = "New security group"
  vpc_id      = alicloud_vpc.vpc.id
}

//Allow All TCP Ingress for Firewall
resource "alicloud_security_group_rule" "allow_all_tcp_ingress" {
  type              = "ingress"
  description       = "ingress sg"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.SecGroup.id
  cidr_ip           = "0.0.0.0/0"
}

//Allow All TCP Egress Traffic - ESS
resource "alicloud_security_group_rule" "allow_all_tcp_egress" {
  type              = "egress"
  description       = "egress sg"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.SecGroup.id
  cidr_ip           = "0.0.0.0/0"
}

data "template_file" "setupfgt" {
  template = file("${path.module}/fgtconfig.conf")
  vars = {
    region          = "${var.region}",
    type            = "${var.license_type}"
    license_file    = "${var.license}"
    adminsport      = "${var.adminsport}"
  }
}


resource "alicloud_instance" "Fortigate" {
  depends_on           = [alicloud_ecs_network_interface.FortiGateInterface]
  availability_zone    = data.alicloud_zones.default.zones.0.id
  security_groups      = alicloud_security_group.SecGroup.*.id
  image_id             = length(var.instance_ami) > 1 ? var.instance_ami : data.alicloud_images.ecs_image.images.0.id
  instance_type        = data.alicloud_instance_types.types_ds.instance_types.0.id
  system_disk_category = "cloud_essd"
  instance_name        = "FortiGate-${random_string.random_name_post.result}-A"
  vswitch_id           = alicloud_vswitch.vsw_mgmt.id
  user_data            = data.template_file.setupfgt.rendered
  internet_max_bandwidth_out = 5


  //Logging Disk
  data_disks {
    size                 = 30
    category             = "cloud_essd"
    delete_with_instance = true
  }
}

// internal port 
resource "alicloud_ecs_network_interface" "FortiGateInterface" {
  description            = "fgta internal port"
  network_interface_name = "fgtaint-${random_string.random_name_post.result}"
  vswitch_id             = alicloud_vswitch.vsw_internal.id
  security_group_ids     = ["${alicloud_security_group.SecGroup.id}"]
}

// attachment
resource "alicloud_ecs_network_interface_attachment" "Fortigateattachment" {
  instance_id          = alicloud_instance.Fortigate.id
  network_interface_id = alicloud_ecs_network_interface.FortiGateInterface.id
}

// external port 
resource "alicloud_ecs_network_interface" "FortiGateInterfaceext" {
  description            = "fgta sync port"
  network_interface_name = "fgtasync-${random_string.random_name_post.result}"
  vswitch_id             = alicloud_vswitch.vsw_external.id
  security_group_ids     = ["${alicloud_security_group.SecGroup.id}"]
}

// attachment
resource "alicloud_ecs_network_interface_attachment" "Fortigateattachmentext" {
  depends_on           = [alicloud_ecs_network_interface_attachment.Fortigateattachment]
  instance_id          = alicloud_instance.Fortigate.id
  network_interface_id = alicloud_ecs_network_interface.FortiGateInterfaceext.id
}