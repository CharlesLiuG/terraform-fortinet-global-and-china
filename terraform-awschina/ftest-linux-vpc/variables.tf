variable "ProjectName" {
  type        = string
  description = "'space' IS NOT ALLOWED for tags!!!"
}

#################### VPC ####################
variable "regionName" { type = string }
variable "azFtnt1" { type = string }
variable "vpcName" { type = string }
variable "cidrVpcFTest" { type = string }

#################### Subnet ####################
variable "cidrSubnetFTestAz1" { type = string }
variable "cidrSubnetLbAz1" { type = string }
variable "cidrSubnetNatgwAz1" { type = string }

#################### ENI IP Address ####################
variable "hostnameFTest" { type = string }
variable "keyName" { type = string }
variable "instanceType" { type = string }

variable "fgtConfVipSrcAddr" { type = string }
variable "cloudInitScriptPath" { type = string }

#################### Toggle true/false ####################
variable "isProvisionLb" { type = bool }
variable "isProvisionNatgw" { type = bool }

variable "portsListenerNlbPublic" {}
