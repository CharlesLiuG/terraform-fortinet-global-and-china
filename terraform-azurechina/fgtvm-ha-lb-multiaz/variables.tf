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
variable "azPrimary" {
  type = string
}

variable "azSecondary" {
  type = string
}

variable "nameSubnetPublic" {
  type = string
}

variable "nameSubnetPrivate" {
  type = string
}

variable "nameSubnetHAsync" {
  type = string
}

variable "nameSubnetMgmt" {
  type = string
}

variable "nameSubnetFTest" {
  type = string
}

variable "cidrSubnetPublic" {
  type = string
}

variable "cidrSubnetPrivate" {
  type = string
}

variable "cidrSubnetHAsync" {
  type = string
}

variable "cidrSubnetMgmt" {
  type = string
}

variable "cidrSubnetApp" {
  type = string
}

#################### FGT Primary Private IP ####################
variable "ipAddrPublicFgt1" {
  type = string
}

variable "ipAddrPrivateFgt1" {
  type = string
}

variable "ipAddrHAsyncFgt1" {
  type = string
}

variable "ipAddrMgmtFgt1" {
  type = string
}


################### FGT Secondary Private IP ####################
variable "ipAddrPublicFgt2" {
  type = string
}

variable "ipAddrPrivateFgt2" {
  type = string
}

variable "ipAddrHAsyncFgt2" {
  type = string
}

variable "ipAddrMgmtFgt2" {
  type = string
}



################### FTest-Linux ####################
variable "instanceFTestLinux" {
  type = string
}

variable "eniIpFTestLinux" {
  type = string
}

variable "instanceTypeFTestLinux" {
  type = string
}

################### FGT ####################
variable "instanceNameFGT1" {
  type = string
}

variable "instanceNameFGT2" {
  type = string
}

variable "instanceType" {
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

variable "adminUsername" {
  type = string
}

variable "adminPassword" {
  type = string
}


################### ILB ####################
variable "privateIpAddr_ILB" {
  type = string
}


#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for AWS provisioning
variable "instanceBootstrapFgt1" {
  type = string
}

variable "instanceBootstrapFgt2" {
  type = string
}

variable "adminsPort" {
  type = string
}

variable "licenseFileFgt1" {
  type = string
}

variable "licenseFileFgt2" {
  type = string
}

variable "licenseType" {
  type = string
}
