# 'space' IS NOT ALLOWED for tags!!!
ProjectName = "ftntDEMO"

#################### resourceGrp ####################
resourceGrp           = "resourcegrp-LB-HA"
resourceGrpLocation   = "chinanorth3"
vnetLocation          = "chinanorth3"

azPrimary             = "3"
azSecondary           = "2"

#################### VPC ####################
vnetName              = "VNET_NGFW_LB_HA"
nameSubnetPublic      = "subnet-public"
nameSubnetPrivate     = "subnet-private"
nameSubnetHAsync      = "subnet-hasync"
nameSubnetMgmt        = "subnet-mgmt"
nameSubnetFTest       = "subnet-ftest"

cidrVpcNgfw           = "10.50.0.0/16"
cidrSubnetPublic      = "10.50.11.0/24"
cidrSubnetPrivate     = "10.50.12.0/24"
cidrSubnetHAsync      = "10.50.13.0/24"
cidrSubnetMgmt        = "10.50.14.0/24"
cidrSubnetApp         = "10.50.20.0/24"


#################### ENI IP Address ####################
ipAddrPublicFgt1       = "10.50.11.11"
ipAddrPrivateFgt1      = "10.50.12.11"
ipAddrHAsyncFgt1       = "10.50.13.11"
ipAddrMgmtFgt1         = "10.50.14.11"

ipAddrPublicFgt2       = "10.50.11.22"
ipAddrPrivateFgt2      = "10.50.12.22"
ipAddrHAsyncFgt2       = "10.50.13.22"
ipAddrMgmtFgt2         = "10.50.14.22"


#################### ILB IP Address ####################
privateIpAddr_ILB     = "10.50.12.100"


################### FTest-Linux ####################
instanceFTestLinux    = "FTest-Azure-Linux"
eniIpFTestLinux       = "10.50.20.11"
instanceTypeFTestLinux= "Standard_F1s"


#################### FGT ####################
instanceNameFGT1      = "FGT-Azure-Primary"
instanceNameFGT2      = "FGT-Azure-Secondary"
instanceType          = "Standard_F4s"

isAzureChinaCloud     = true
# imageVersion          = "fgtvm72"
# imageVersion          = "fgtvm70"
imageVersion          = "fgtvm64"

adminUsername         = "ftntuser"


#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for provisioning
instanceBootstrapFgt1 = "6.1.azure_linux_vm_fgt1.conf"
instanceBootstrapFgt2 = "6.2.azure_linux_vm_fgt2.conf"
adminsPort            = "443"
licenseFileFgt1       = "license1.lic"
licenseFileFgt2       = "license2.lic"
licenseType           = "byol"