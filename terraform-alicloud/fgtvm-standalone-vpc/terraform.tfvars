ProjectName = "ftntDEMO"

#################### VPC ####################
regionName           = "cn-huhehaote"
vpcName              = "VPC-NGFW"
cidrVpcNgfw          = "192.168.0.0/16"

#################### Vsw FGT ####################
vswPublicName     = "vsw_Public"
vswPrivateName    = "vsw_Private"
cidrVswPublic     = "192.168.11.0/24"
cidrVswPrivate    = "192.168.12.0/24"

#################### EIP ####################
eipFgtChargeType  = "PayByBandwidth"
eipFgtPaymentType = "PayAsYouGo"

#################### ENI IP Address ####################
ipAddrPublicFgt       = "192.168.11.11"
ipAddrPrivateFgt      = "192.168.12.11"

#################### FortiGate ####################
hostnameFgt                = "FGT-ALI-Standalone"
instanceTypeFgtDesignated  = ""

#################### FortiGate [SELECTION] ####################
# PAYG is not available in AliCloud
licenseType          = "byol"

# "fgtvm70" and "fgtvm72" is not available in AliCloud
# "fgtvm64" is is not available in cn-guangzhou
imageVersion          = "fgtvm64"

#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for provisioning
instanceBootstrapFgt = "6.alicloud_instance_fgt.conf"
adminsPort           = "443"
licenseFile          = "license.lic"
fgtConfVipSrcAddr    = "192.168.12.40"
fgtConfVipSrvPort    = "80"
fgtConfVipExtPort    = "8080"