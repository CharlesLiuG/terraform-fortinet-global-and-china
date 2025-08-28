variable "ProjectName" {
  type = string
}

#################### VPC1 ####################
variable "region1Name" {
  type = string
}

variable "vpc1Name" {
  type = string
}

variable "cidrVpcNgfw" {
  type = string
}

#################### vsw FGT ####################
variable "nameVswPublicFgt1" {
  type = string
}

variable "nameVswPrivateFgt1" {
  type = string
}

variable "nameVswHAsyncFgt1" {
  type = string
}

variable "nameVswMgmtFgt1" {
  type = string
}

variable "cidrVswPublicFgt1" {
  type = string
}

variable "cidrVswPrivateFgt1" {
  type = string
}

variable "cidrVswHAsyncFgt1" {
  type = string
}

variable "cidrVswMgmtFgt1" {
  type = string
}

variable "nameVswPublicFgt2" {
  type = string
}

variable "nameVswPrivateFgt2" {
  type = string
}

variable "nameVswHAsyncFgt2" {
  type = string
}

variable "nameVswMgmtFgt2" {
  type = string
}

variable "cidrVswPublicFgt2" {
  type = string
}

variable "cidrVswPrivateFgt2" {
  type = string
}

variable "cidrVswHAsyncFgt2" {
  type = string
}

variable "cidrVswMgmtFgt2" {
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

#################### VM-FortiGate ####################
variable "licenseType" {
  type = string
}

variable "hostnameFgt1" {
  type = string
}

variable "hostnameFgt2" {
  type = string
}

variable "instanceTypeFgtDesignated" {
  type = string
}

variable "imageVersion" {
  type    = string
  default = "fgtvm64"
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
variable "instanceBootstrapFgt1" {
  type = string
}

variable "instanceBootstrapFgt2" {
  type = string
}

variable "adminsPort" {
  type = string
}

variable "license1File" {
  type = string
}

variable "license2File" {
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

