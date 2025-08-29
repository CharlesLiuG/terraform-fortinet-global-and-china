// Alicloud configuration
variable "access_key" {}
variable "secret_key" {}


variable "region" {
  type    = string
  default = "cn-hangzhou" //Default Region
}


variable "vpc_cidr" {
  type    = string
  default = "172.16.0.0/16"
}

variable "vswitch_cidr_mgmt" {
  type    = string
  default = "172.16.0.0/24"
}

variable "vswitch_cidr_int" {
  type    = string
  default = "172.16.1.0/24"
}

variable "vswitch_cidr_ext" {
  type    = string
  default = "172.16.2.0/24"
}


//Default VPC Egress Route
variable "default_egress_route" {
  type    = string
  default = "0.0.0.0/0"
}

//If an AMI is specified it will be chosen
//Otherwise the ESS config will default to the latest Fortigate version
variable "instance_ami" {
  type    = string
  default = ""
}

variable "adminsport" {
  default = "8443"
}

//Define the instance family to be used.
//Different regions will contain various instance families
//Refer to: https://www.alibabacloud.com/help/en/elastic-compute-service/latest/instance-family#sn2ne
//default family : ecs.sn2ne
variable "instance" {
  type    = string
  default = "ecs.c7.large"
}

data "alicloud_account" "current" {
}

//Get Instance types with min requirements in the region.
//If left with no instance_type_family the return may include shared instances.
data "alicloud_instance_types" "types_ds" {
  cpu_core_count       = 2
  memory_size          = 4
  instance_type_family = var.instance
}

// license file for the fgt
variable "license" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "FGVM16TM24000358.lic"
}


// FortiGate Image.  Default is payg.
// Options are either payg or byol
variable "license_type" {
  default = "byol"
}

// FortiOS Version
variable "fosversion" {
  default = "7.6.2"
}

data "alicloud_images" "ecs_image" {
  owners      = "marketplace"
  most_recent = true
  name_regex  = var.license_type == "byol" ? "^【飞塔Fortinet官方镜像】FortiGate .*BYOL.*${var.fosversion}" : "^【飞塔Fortinet官方镜像】FortiGate.*PAYG.*4.*vCPUs.*${var.fosversion}"
}