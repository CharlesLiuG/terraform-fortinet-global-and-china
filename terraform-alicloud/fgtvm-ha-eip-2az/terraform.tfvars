# 'space' IS NOT ALLOWED for tags!!!
ProjectName = "ftntDEMO"

# Current Support Limitations
# region1Name, region2Name, region3Name MUST BE the same region!!!!
# This is required for CEN-TR VPC attachment.
# Later release will handle CEN-TR PEER/VBR attachment, which regionName will be different.

# 'cn-shanghai-f' is designated as a cen-tr landing az,
# however, cn-shanghai-f is also a GPU only az,
# therefore no instance type is available for FG-VM in this az.
# CONCLUSION: FortiGate's AZ of cn-shanghai is not the same as CEN-TR Landing vsw AZ.

#################### VPC1 ####################
region1Name           = "cn-beijing"
vpc1Name              = "VPC-NGFW"
cidrVpcNgfw           = "192.168.0.0/16"

#################### Vsw FGT ####################
nameVswPublicFgt1     = "vsw-Public-Fgt1"
nameVswPrivateFgt1    = "vsw-Private-Fgt1"
nameVswHAsyncFgt1     = "vsw-HAsync-Fgt1"
nameVswMgmtFgt1       = "vsw-Mgmt-Fgt1"

cidrVswPublicFgt1     = "192.168.11.0/24"
cidrVswPrivateFgt1    = "192.168.12.0/24"
cidrVswHAsyncFgt1     = "192.168.13.0/24"
cidrVswMgmtFgt1       = "192.168.14.0/24"

nameVswPublicFgt2     = "vsw-Public-Fgt2"
nameVswPrivateFgt2    = "vsw-Private-Fgt2"
nameVswHAsyncFgt2     = "vsw-HAsync-Fgt2"
nameVswMgmtFgt2       = "vsw-Mgmt-Fgt2"

cidrVswPublicFgt2     = "192.168.21.0/24"
cidrVswPrivateFgt2    = "192.168.22.0/24"
cidrVswHAsyncFgt2     = "192.168.23.0/24"
cidrVswMgmtFgt2       = "192.168.24.0/24"


#################### EIP ####################
eipFgtChargeType  = "PayByBandwidth"
eipFgtPaymentType = "PayAsYouGo"

#################### ENI IP Address ####################
ipAddrPublicFgt1       = "192.168.11.11"
ipAddrPrivateFgt1      = "192.168.12.11"
ipAddrHAsyncFgt1       = "192.168.13.11"
ipAddrMgmtFgt1         = "192.168.14.11"

ipAddrPublicFgt2       = "192.168.21.11"
ipAddrPrivateFgt2      = "192.168.22.11"
ipAddrHAsyncFgt2       = "192.168.23.11"
ipAddrMgmtFgt2         = "192.168.24.11"

#################### VM-FortiGate ####################
hostnameFgt1               = "FGT-ALI-Primary"
hostnameFgt2               = "FGT-ALI-Secondary"
instanceTypeFgtDesignated  = ""

#################### FortiGate [SELECTION] ####################
# PAYG is not available in AliCloud
licenseType          = "byol"

# "fgtvm70" and "fgtvm72" is not available in AliCloud
# "fgtvm64" is is not available in cn-guangzhou
imageVersion          = "fgtvm64"


#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for provisioning
instanceBootstrapFgt1 = "6.1.alicloud_instance_fgt1.conf"
instanceBootstrapFgt2 = "6.2.alicloud_instance_fgt2.conf"

adminsPort            = "443"
license1File          = "license1.lic"
license2File          = "license2.lic"

fgtConfVipSrcAddr     = "192.168.12.40"
fgtConfVipSrvPort     = "80"
fgtConfVipExtPort     = "8080"