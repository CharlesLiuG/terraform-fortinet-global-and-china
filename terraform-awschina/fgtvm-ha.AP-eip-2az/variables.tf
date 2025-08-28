variable "ProjectName" { type = string }
variable "regionName" { type = string }

variable "azFtnt1" { type = string }
variable "azFtnt2" { type = string }

#################### VPC-FGT ####################
variable "vpcName" { type = string }
variable "cidrVpcNgfw" { type = string }

variable "cidrSubnetFgtPublicAz1" { type = string }
variable "cidrSubnetFgtPrivateAz1" { type = string }
variable "cidrSubnetFgtHAsyncAz1" { type = string }
variable "cidrSubnetFgtMgmtAz1" { type = string }
variable "cidrSubnetFgtTgwAz1" { type = string }

variable "cidrSubnetFgtPublicAz2" { type = string }
variable "cidrSubnetFgtPrivateAz2" { type = string }
variable "cidrSubnetFgtHAsyncAz2" { type = string }
variable "cidrSubnetFgtMgmtAz2" { type = string }
variable "cidrSubnetFgtTgwAz2" { type = string }

#################### ENI IP Address ####################
variable "ipAddrFgtPublicAz1" { type = string }
variable "ipAddrFgtPrivateAz1" { type = string }
variable "ipAddrFgtHAsyncAz1" { type = string }
variable "ipAddrFgtMgmtAz1" { type = string }

variable "ipAddrFgtPublicAz2" { type = string }
variable "ipAddrFgtPrivateAz2" { type = string }
variable "ipAddrFgtHAsyncAz2" { type = string }
variable "ipAddrFgtMgmtAz2" { type = string }

#################### EIP ####################
variable "isProvisionFgtEips" { type = bool }
variable "eipIdCluster" {
  type    = string
  default = ""
}
variable "eipIdFgtMgmtAz1" {
  type    = string
  default = ""
}
variable "eipIdFgtMgmtAz2" {
  type    = string
  default = ""
}

#################### FortiGate ####################
# variable "fgtIamProfile" { type = string }
variable "hostnameFgtAz1" { type = string }
variable "hostnameFgtAz2" { type = string }
variable "instanceTypeFgtDesignated" { type = string }
variable "licenseType" { type = string }
variable "imageVersion" { type = string }

#################### Features [toggle true/false] ####################
variable "isProvisionFgtTgwLandingSubnets" { type = bool }
variable "isProvision3PortsHA" { type = bool }
variable "isProvisionIPsec" { type = bool }

variable "isProvisionVpcNgfw" { type = bool }
variable "paramVpcCustomerId" {
  type    = string
  default = ""
}
variable "paramIgwId" {
  type    = string
  default = ""
}

#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for AWS provisioning
variable "instanceBootstrapFgt1" { type = string }
variable "instanceBootstrapFgt2" { type = string }

variable "portFgtHttps" { type = string }
variable "license1File" { type = string }
variable "license2File" { type = string }

variable "isProvisionDnatWebSrv" { type = bool }
variable "ipAddrVipWebSrv" { type = string }
variable "portFgtDnatWebsrvInt" { type = string }
variable "portFgtDnatWebsrvExt" { type = string }
