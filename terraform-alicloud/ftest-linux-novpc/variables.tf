################################ VPC ################################
variable "regionName" {
  description = "Region Name"
  type        = string
}

variable "idVswFTest" {
  description = "ID of vSwitch"
  type        = string
}

variable "idSecurityGroupFTest" {
  description = "ID of Security Group"
  type        = string
}

variable "ipPrivateFTest" {
  description = "Private IP of the Instance"
  type        = string
}

variable "passwordFTest" {
  description = "Instance Password"
  type        = string
}

variable "cloudInitScriptPath" {
  description = "Bootstrap Script"
  type        = string
}
