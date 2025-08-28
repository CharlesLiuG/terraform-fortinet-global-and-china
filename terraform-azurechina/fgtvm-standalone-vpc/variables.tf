variable "ProjectName" {
  type        = string
  description = "'space' IS NOT ALLOWED for tags!!!"
}

#################### Resource Group ####################
variable "vnetLocation" {
  type = string
}

variable "resourceGrpLocation" {
  type = string
}

variable "resourceGrp" {
  type = string
}

#################### VNET ####################
variable "vnetName" {
  type = string
}

variable "cidrVpcNgfw" {
  type = string
}

#################### Subnets ####################
variable "azFgt" {
  type = string
}

variable "nameSubnetPublic" {
  type = string
}

variable "nameSubnetPrivate" {
  type = string
}

variable "cidrSubnetPublic" {
  type = string
}

variable "cidrSubnetPrivate" {
  type = string
}


#################### FGT Private IP ####################
variable "ipAddrPublicFgt" {
  type = string
}

variable "ipAddrPrivateFgt" {
  type = string
}

################### FGT ####################
variable "adminUsername" {
  type = string
}

variable "adminPassword" {
  type = string
}

variable "hostnameFgt" {
  type = string
}

variable "instanceType" {
  type = string
}

variable "licenseType" {
  type = string
}

variable "isAzureChinaCloud" {
  type = bool
}

variable "imageVersion" {
  type = string
}


variable "imageVersionChina" {
  type = map(any)
  default = {
    fgtvm72 = "latest"
    fgtvm70 = "7.0.9"
    fgtvm64 = "6.4.9"
  }
}

variable "imageVersionGlobal" {
  type = map(any)
  default = {
    fgtvm72 = "7.2.0"
    fgtvm70 = "7.0.5"
    fgtvm64 = "6.4.3"
  }
}

variable "imagePublisher" {
  type = map(any)
  default = {
    china    = "fortinet-cn"
    global   = "fortinet"
    global72 = "fortinet"
  }
}

variable "imageOffer" {
  type = map(any)
  default = {
    china    = "fortinet_fortigate-vm_v7_2"
    global   = "fortinet_fortigate-vm_v5"
    global72 = "fortinet_fortigate-vm_v5"
  }
}

variable "skuFgtBYOL" {
  type = map(any)
  default = {
    china    = "fortinet_fg-vm_7_2"
    global   = "fortinet_fg-vm"
    global72 = "fortinet_fg-vm"
  }
}

variable "skuFgtPAYG" { # Azure.China doesn't provide PAYG
  type = map(any)
  default = {
    china    = "fortinet_fg-vm_7_2"
    global   = "fortinet_fg-vm_payg_20190624"
    global72 = "fortinet_fg-vm_payg_2022"
  }
}


#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for AWS provisioning
variable "instanceBootstrapFgt" {
  type = string
}

variable "adminsPort" {
  type = string
}

variable "licenseFile" {
  type = string
}

variable "fgtConfVipSrcAddr" {
  type = string
}

variable "fgtConfVipSrvPort" {
  type = string
}

variable "fgtConfVipExtPort" {
  type = string
}
