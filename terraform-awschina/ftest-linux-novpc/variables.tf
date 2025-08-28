variable "ProjectName" {
  type        = string
  description = "'space' IS NOT RECOMMEDED for tags!!!"
}

################################ VPC ################################
variable "regionName" {
  description = "Region Name"
  type        = string
}

variable "azFtnt1" {
  type = string
}

variable "idSubnetFTest" {
  description = "ID of Subnet FTest"
  type        = string
}

variable "idSecurityGroupFTest" {
  description = "ID of FTest eth0 Security Group"
  type        = string
}

variable "ipPrivateFTest" {
  description = "Private IP of the Instance"
  type        = string
}

variable "keyName" {
  type = string
}

variable "cloudInitScriptPath" {
  description = "Bootstrap Script"
  type        = string
}

variable "hostnameFTest" {
  type = string
}

variable "instanceType" {
  type = string
}

variable "amiUbuntu1804LTS" {
  type = map(any)
  default = {
    cn-north-1     = "ami-05248307900d52e3a"
    cn-northwest-1 = "ami-075c9f159ee0bdc1c"
    us-west-2      = ""
    us-west-1      = ""
    us-east-1      = ""
    us-east-2      = ""
    ap-east-1      = ""
    ap-south-1     = ""
    ap-northeast-3 = ""
    ap-northeast-2 = ""
    ap-southeast-1 = ""
    ap-southeast-2 = ""
    ap-northeast-1 = ""
    ca-central-1   = ""
    eu-central-1   = ""
    eu-west-1      = ""
    eu-west-2      = ""
    eu-south-1     = ""
    eu-west-3      = ""
    eu-north-1     = ""
    me-south-1     = ""
    sa-east-1      = ""
  }
}
