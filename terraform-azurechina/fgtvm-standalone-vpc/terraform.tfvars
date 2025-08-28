# 'space' IS NOT ALLOWED for tags!!!
ProjectName = "ftntDEMO"

#################### resourceGrp ####################
resourceGrp           = "rgrp-ngfw"
resourceGrpLocation   = "chinanorth3"
vnetLocation          = "chinanorth3"

azFgt                 = "3"

#################### VPC ####################
vnetName              = "VNET-NGFW"
nameSubnetPublic      = "subnet_public"
nameSubnetPrivate     = "subnet_private"

cidrVpcNgfw           = "10.40.0.0/16"
cidrSubnetPublic      = "10.40.11.0/24"
cidrSubnetPrivate     = "10.40.12.0/24"


#################### ENI IP Address ####################
ipAddrPublicFgt       = "10.40.11.11"
ipAddrPrivateFgt      = "10.40.12.11"


#################### FortiGate ####################
hostnameFgt           = "FGT-Azure-Standalone"
instanceType          = "Standard_F4s"

# licenseType          = "payg"
licenseType          = "byol"

isAzureChinaCloud     = true
# imageVersion          = "fgtvm72"
imageVersion          = "fgtvm70"
# imageVersion          = "fgtvm64"

adminUsername         = "ftntuser"


#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for provisioning
instanceBootstrapFgt = "6.azure_linux_vm_fgt.conf"

adminsPort           = "443"
licenseFile          = "license.lic"

fgtConfVipSrcAddr     = "10.40.12.40"
fgtConfVipSrvPort     = "80"
fgtConfVipExtPort     = "8080"