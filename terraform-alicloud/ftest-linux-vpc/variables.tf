variable "ProjectName" {
  type = string
}

################################ VPC ################################
variable "regionName" {
  description = "Region Name"
  type        = string
}

variable "vpcName" {
  type = string
}

variable "cidrVpcFTest" {
  type = string
}

variable "nameVswFTest" {
  type = string
}

variable "cidrVswFTest" {
  type = string
}

#################### EIP ####################
variable "eipFTestChargeType" {
  type    = string
  default = "PayByBandwidth"
}

variable "eipFTestPaymentType" {
  type    = string
  default = "PayAsYouGo"
}

#################### FTest ####################
variable "ipPrivateFTest" {
  description = "Private IP of the Instance"
  type        = string
}

variable "passwordFTest" {
  description = "Instance Password"
  type        = string
}

variable "keyNameFTest" {
  description = "Instance KeyPair (override password)"
  type        = string
}

variable "cloudInitScriptPath" {
  description = "Bootstrap Script"
  type        = string
}

variable "instanceTypeFgtDesignated" {
  type = string
}

variable "spotStrategyDesignated" {
  type = string
}

variable "vCpuDesignated" {
  type = string
}

variable "ramDesignated" {
  type = string
}

variable "ecsFamilyDesignated" {
  type = string
}


