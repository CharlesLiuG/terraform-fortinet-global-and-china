#################### FortiGate BYOL AMI ####################
locals {
  nameFgtvm64Byol = {
    CHINA  = "FortiGate-AWS-6.4.6_BYOL-Release-58cf8e81-bdca-4f2f-bc9d-5b6bfc23b8*"
    GLOBAL = "FortiGate-VM64-AWS build2030 (6.4.11) GA*"
  }
  nameFgtvm70Byol = {
    CHINA  = "FGT_VM64_AWS-v7.0.7.F-build0367-99e30f52-276e-49d9-9fc8*"
    GLOBAL = "FortiGate-VM64-AWS build0444 (7.0.9) GA*"
  }
  nameFgtvm72Byol = {
    CHINA  = "FGT7.2.2-58cf8e81-bdca-4f2f-bc9d-5b6bfc23b86b*"
    GLOBAL = "FortiGate-VM64-AWS build1262 (7.2.3) GA*"
  }
}

#################### FortiGate PAYG AMI ####################
locals {
  nameFgtvm64Payg = {
    CHINA  = "FGT_VM64_AWS-v7.2.2.F-build1255-FORTINET-PAYG*"
    GLOBAL = "FortiGate-VM64-AWSONDEMAND build2030 (6.4.11) GA*"
  }
  nameFgtvm70Payg = {
    CHINA  = "FGT_VM64_AWS-v7.2.2.F-build1255-FORTINET-PAYG*"
    GLOBAL = "FortiGate-VM64-AWSONDEMAND build0444 (7.0.9) GA*"
  }
  nameFgtvm72Payg = {
    CHINA  = "FGT_VM64_AWS-v7.2.2.F-build1255-FORTINET-PAYG*"
    GLOBAL = "FortiGate-VM64-AWSONDEMAND build1262 (7.2.3) GA*"
  }
}

#################### FortiGate OWNER ID ####################
locals {
  amiOwnerIdFtnt = {
    cn-north-1     = "336777782633" # '336777782633' WestCloud Digital, China
    cn-northwest-1 = "336777782633" # '336777782633' WestCloud Digital, China
    ap-east-1      = "211372476111" # Fortinet Inc. (HongKong)
    us-west-2      = "679593333241"
    us-west-1      = "679593333241"
    us-east-1      = "679593333241"
    us-east-2      = "679593333241"
    ap-south-1     = "679593333241"
    ap-northeast-3 = "679593333241"
    ap-northeast-2 = "679593333241"
    ap-southeast-1 = "679593333241"
    ap-southeast-2 = "679593333241"
    ap-northeast-1 = "679593333241"
    ca-central-1   = "679593333241"
    eu-central-1   = "679593333241"
    eu-west-1      = "679593333241"
    eu-west-2      = "679593333241"
    eu-west-3      = "679593333241"
    eu-north-1     = "679593333241"
    sa-east-1      = "679593333241"
  }
}

#################### AWS CHINA or AWS GLOBAL ####################
locals {
  nameAwsLocation = var.regionName == "cn-north-1" || var.regionName == "cn-northwest-1" ? "CHINA" : "GLOBAL"
}



######################## FG-VM64 ########################
data "aws_ami" "amiFgtvm64" {
  most_recent = true

  filter {
    name   = "name"
    values = var.licenseType == "byol" ? [local.nameFgtvm64Byol[local.nameAwsLocation]] : [local.nameFgtvm64Payg[local.nameAwsLocation]]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [local.amiOwnerIdFtnt[var.regionName]]
}



######################## FG-VM70 ########################
data "aws_ami" "amiFgtvm70" {
  most_recent = true

  filter {
    name   = "name"
    values = var.licenseType == "byol" ? [local.nameFgtvm70Byol[local.nameAwsLocation]] : [local.nameFgtvm70Payg[local.nameAwsLocation]]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [local.amiOwnerIdFtnt[var.regionName]]
}



######################## FG-VM72 ########################
data "aws_ami" "amiFgtvm72" {
  most_recent = true

  filter {
    name   = "name"
    values = var.licenseType == "byol" ? [local.nameFgtvm72Byol[local.nameAwsLocation]] : [local.nameFgtvm72Payg[local.nameAwsLocation]]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [local.amiOwnerIdFtnt[var.regionName]]
}
