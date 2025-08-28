variable "ProjectName" {
  type        = string
  description = "'space' IS NOT ALLOWED for tags!!!"
}

#################### VPC ####################
variable "regionName" {
  type = string
}

variable "vpcName" {
  type = string
}

variable "cidrVpcNgfw" {
  type = string
}

#################### vsw FGT ####################
variable "vswPublicName" {
  type = string
}

variable "vswPrivateName" {
  type = string
}

variable "cidrVswPublic" {
  type = string
}

variable "cidrVswPrivate" {
  type = string
}

#################### EIP ####################
variable "eipFgtChargeType" {
  type = string
}

variable "eipFgtPaymentType" {
  type = string
}

#################### ENI IP Address ####################
variable "ipAddrPublicFgt" {
  type = string
}

variable "ipAddrPrivateFgt" {
  type = string
}

#################### FortiGate ####################
variable "licenseType" {
  type = string
}

variable "hostnameFgt" {
  type = string
}

variable "instanceTypeFgtDesignated" {
  type = string
}

variable "instanceBootstrapFgt" {
  type = string
}

variable "adminsPort" {
  type = string
}

variable "licenseFile" {
  type = string
}

variable "imageVersion" {
  type = string
}

variable "amiFgtBYOL64" { # FGT AliCloud (BYOL) - 6.4.5, cn-guangzhou is not available
  type = map(any)
  default = {
    cn-beijing     = "m-2zec5gpamoc7qaxzrx8x"
    cn-qingdao     = "m-m5ehlb1cpce22j0kyx1n"
    cn-zhangjiakou = "m-8vbcna7q8l6358yrsger"
    cn-huhehaote   = "m-hp3axqqvvr1s5dmtnxb1"
    cn-hangzhou    = "m-bp1bvdqhwetqmleaftfd"
    cn-shanghai    = "m-uf6cir5blv91vxt767p6"
    cn-shenzhen    = "m-wz92vsyvci6bm5pvmc3d"
    cn-heyuan      = "m-f8zffftdq6fymo9jbe3z"
    cn-chengdu     = "m-2vc5sn5ijz2ig88eyi52"
    cn-hongkong    = "m-j6c34y880spxo829x00e"
    ap-southeast-1 = "m-t4n8sc5yn5rwfzq4yqul"
    ap-southeast-2 = "m-p0w3o3anhh0qmab5jrug"
    ap-southeast-3 = "m-8psdkppcbb4ixmd7jylx"
    ap-southeast-5 = "m-k1a7crj6n4quw4jzlhiy"
    ap-northeast-1 = "m-6we9nwgq2cei4snuac6z"
    us-west-1      = "m-rj956dl5fwiwdiifk1wp"
    us-east-1      = "m-0xi6ede2a25ip585xt62"
    eu-central-1   = "m-gw84w9kn647ybzw8at2d"
    eu-west-1      = "m-d7o00pz6jt4s9omqpnbq"
    me-east-1      = "m-eb3bnvzgoxej3fkv9ndd"
    ap-south-1     = "m-a2d3nkfid1a2h3wcmg8a"
  }
}


variable "amiFgtPAYG64" { # FGT AliCloud (BYOL) - 6.4.5, PAYG is not available in AliCloud
  type = map(any)
  default = {
    cn-beijing     = "m-2zec5gpamoc7qaxzrx8x"
    cn-qingdao     = "m-m5ehlb1cpce22j0kyx1n"
    cn-zhangjiakou = "m-8vbcna7q8l6358yrsger"
    cn-huhehaote   = "m-hp3axqqvvr1s5dmtnxb1"
    cn-hangzhou    = "m-bp1bvdqhwetqmleaftfd"
    cn-shanghai    = "m-uf6cir5blv91vxt767p6"
    cn-shenzhen    = "m-wz92vsyvci6bm5pvmc3d"
    cn-heyuan      = "m-f8zffftdq6fymo9jbe3z"
    cn-chengdu     = "m-2vc5sn5ijz2ig88eyi52"
    cn-hongkong    = "m-j6c34y880spxo829x00e"
    ap-southeast-1 = "m-t4n8sc5yn5rwfzq4yqul"
    ap-southeast-2 = "m-p0w3o3anhh0qmab5jrug"
    ap-southeast-3 = "m-8psdkppcbb4ixmd7jylx"
    ap-southeast-5 = "m-k1a7crj6n4quw4jzlhiy"
    ap-northeast-1 = "m-6we9nwgq2cei4snuac6z"
    us-west-1      = "m-rj956dl5fwiwdiifk1wp"
    us-east-1      = "m-0xi6ede2a25ip585xt62"
    eu-central-1   = "m-gw84w9kn647ybzw8at2d"
    eu-west-1      = "m-d7o00pz6jt4s9omqpnbq"
    me-east-1      = "m-eb3bnvzgoxej3fkv9ndd"
    ap-south-1     = "m-a2d3nkfid1a2h3wcmg8a"
  }
}

variable "amiFgtBYOL70" { # FGT AliCloud (BYOL) - 6.4.5, FortiGate 7.0 & 7.2 is not available
  type = map(any)
  default = {
    cn-beijing     = "m-2zec5gpamoc7qaxzrx8x"
    cn-qingdao     = "m-m5ehlb1cpce22j0kyx1n"
    cn-zhangjiakou = "m-8vbcna7q8l6358yrsger"
    cn-huhehaote   = "m-hp3axqqvvr1s5dmtnxb1"
    cn-hangzhou    = "m-bp1bvdqhwetqmleaftfd"
    cn-shanghai    = "m-uf6cir5blv91vxt767p6"
    cn-shenzhen    = "m-wz92vsyvci6bm5pvmc3d"
    cn-heyuan      = "m-f8zffftdq6fymo9jbe3z"
    cn-chengdu     = "m-2vc5sn5ijz2ig88eyi52"
    cn-hongkong    = "m-j6c34y880spxo829x00e"
    ap-southeast-1 = "m-t4n8sc5yn5rwfzq4yqul"
    ap-southeast-2 = "m-p0w3o3anhh0qmab5jrug"
    ap-southeast-3 = "m-8psdkppcbb4ixmd7jylx"
    ap-southeast-5 = "m-k1a7crj6n4quw4jzlhiy"
    ap-northeast-1 = "m-6we9nwgq2cei4snuac6z"
    us-west-1      = "m-rj956dl5fwiwdiifk1wp"
    us-east-1      = "m-0xi6ede2a25ip585xt62"
    eu-central-1   = "m-gw84w9kn647ybzw8at2d"
    eu-west-1      = "m-d7o00pz6jt4s9omqpnbq"
    me-east-1      = "m-eb3bnvzgoxej3fkv9ndd"
    ap-south-1     = "m-a2d3nkfid1a2h3wcmg8a"
  }
}

variable "amiFgtPAYG70" { # FGT AliCloud (BYOL) - 6.4.5, PAYG is not available in AliCloud
  type = map(any)
  default = {
    cn-beijing     = "m-2zec5gpamoc7qaxzrx8x"
    cn-qingdao     = "m-m5ehlb1cpce22j0kyx1n"
    cn-zhangjiakou = "m-8vbcna7q8l6358yrsger"
    cn-huhehaote   = "m-hp3axqqvvr1s5dmtnxb1"
    cn-hangzhou    = "m-bp1bvdqhwetqmleaftfd"
    cn-shanghai    = "m-uf6cir5blv91vxt767p6"
    cn-shenzhen    = "m-wz92vsyvci6bm5pvmc3d"
    cn-heyuan      = "m-f8zffftdq6fymo9jbe3z"
    cn-chengdu     = "m-2vc5sn5ijz2ig88eyi52"
    cn-hongkong    = "m-j6c34y880spxo829x00e"
    ap-southeast-1 = "m-t4n8sc5yn5rwfzq4yqul"
    ap-southeast-2 = "m-p0w3o3anhh0qmab5jrug"
    ap-southeast-3 = "m-8psdkppcbb4ixmd7jylx"
    ap-southeast-5 = "m-k1a7crj6n4quw4jzlhiy"
    ap-northeast-1 = "m-6we9nwgq2cei4snuac6z"
    us-west-1      = "m-rj956dl5fwiwdiifk1wp"
    us-east-1      = "m-0xi6ede2a25ip585xt62"
    eu-central-1   = "m-gw84w9kn647ybzw8at2d"
    eu-west-1      = "m-d7o00pz6jt4s9omqpnbq"
    me-east-1      = "m-eb3bnvzgoxej3fkv9ndd"
    ap-south-1     = "m-a2d3nkfid1a2h3wcmg8a"
  }
}

variable "amiFgtBYOL72" { # FGT AliCloud (BYOL) - 6.4.5, FortiGate 7.0 & 7.2 is not available
  type = map(any)
  default = {
    cn-beijing     = "m-2zec5gpamoc7qaxzrx8x"
    cn-qingdao     = "m-m5ehlb1cpce22j0kyx1n"
    cn-zhangjiakou = "m-8vbcna7q8l6358yrsger"
    cn-huhehaote   = "m-hp3axqqvvr1s5dmtnxb1"
    cn-hangzhou    = "m-bp1bvdqhwetqmleaftfd"
    cn-shanghai    = "m-uf6cir5blv91vxt767p6"
    cn-shenzhen    = "m-wz92vsyvci6bm5pvmc3d"
    cn-heyuan      = "m-f8zffftdq6fymo9jbe3z"
    cn-chengdu     = "m-2vc5sn5ijz2ig88eyi52"
    cn-hongkong    = "m-j6c34y880spxo829x00e"
    ap-southeast-1 = "m-t4n8sc5yn5rwfzq4yqul"
    ap-southeast-2 = "m-p0w3o3anhh0qmab5jrug"
    ap-southeast-3 = "m-8psdkppcbb4ixmd7jylx"
    ap-southeast-5 = "m-k1a7crj6n4quw4jzlhiy"
    ap-northeast-1 = "m-6we9nwgq2cei4snuac6z"
    us-west-1      = "m-rj956dl5fwiwdiifk1wp"
    us-east-1      = "m-0xi6ede2a25ip585xt62"
    eu-central-1   = "m-gw84w9kn647ybzw8at2d"
    eu-west-1      = "m-d7o00pz6jt4s9omqpnbq"
    me-east-1      = "m-eb3bnvzgoxej3fkv9ndd"
    ap-south-1     = "m-a2d3nkfid1a2h3wcmg8a"
  }
}

variable "amiFgtPAYG72" { # FGT AliCloud (BYOL) - 6.4.5, FortiGate 7.0 & 7.2 is not available, PAYG is not available in AliCloud
  type = map(any)
  default = {
    cn-beijing     = "m-2zec5gpamoc7qaxzrx8x"
    cn-qingdao     = "m-m5ehlb1cpce22j0kyx1n"
    cn-zhangjiakou = "m-8vbcna7q8l6358yrsger"
    cn-huhehaote   = "m-hp3axqqvvr1s5dmtnxb1"
    cn-hangzhou    = "m-bp1bvdqhwetqmleaftfd"
    cn-shanghai    = "m-uf6cir5blv91vxt767p6"
    cn-shenzhen    = "m-wz92vsyvci6bm5pvmc3d"
    cn-heyuan      = "m-f8zffftdq6fymo9jbe3z"
    cn-chengdu     = "m-2vc5sn5ijz2ig88eyi52"
    cn-hongkong    = "m-j6c34y880spxo829x00e"
    ap-southeast-1 = "m-t4n8sc5yn5rwfzq4yqul"
    ap-southeast-2 = "m-p0w3o3anhh0qmab5jrug"
    ap-southeast-3 = "m-8psdkppcbb4ixmd7jylx"
    ap-southeast-5 = "m-k1a7crj6n4quw4jzlhiy"
    ap-northeast-1 = "m-6we9nwgq2cei4snuac6z"
    us-west-1      = "m-rj956dl5fwiwdiifk1wp"
    us-east-1      = "m-0xi6ede2a25ip585xt62"
    eu-central-1   = "m-gw84w9kn647ybzw8at2d"
    eu-west-1      = "m-d7o00pz6jt4s9omqpnbq"
    me-east-1      = "m-eb3bnvzgoxej3fkv9ndd"
    ap-south-1     = "m-a2d3nkfid1a2h3wcmg8a"
  }
}


#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for AWS provisioning
variable "fgtConfVipSrcAddr" {
  type = string
}

variable "fgtConfVipSrvPort" {
  type = string
}

variable "fgtConfVipExtPort" {
  type = string
}
