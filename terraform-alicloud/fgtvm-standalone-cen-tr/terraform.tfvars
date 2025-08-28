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

#################### VPC2 ####################
region2Name           = "cn-beijing"
vpc2Name              = "VPC2-APP"
cidrVpc2              = "172.16.0.0/16"

#################### VPC3 ####################
region3Name           = "cn-beijing"
vpc3Name              = "VPC3-DB"
cidrVpc3              = "172.18.0.0/16"

#################### Vsw FGT ####################
nameVswPublic     = "vsw_Public"
nameVswPrivate    = "vsw_Private"
cidrVswPublic     = "192.168.11.0/24"
cidrVswPrivate    = "192.168.12.0/24"

#################### Vsw FTest-ECS ####################
nameVswFTestVpc2  = "vsw_FTest_VPC2"
nameVswFTestVpc3  = "vsw_FTest_VPC3"
cidrVswFTestVpc2  = "172.16.11.0/24"
cidrVswFTestVpc3  = "172.18.11.0/24"
cloudInitScriptPath  = "../../bootstrap-scripts/bootstrap_nginx_simple_indexpage.sh"
# cloudInitScriptPath  = ""

#################### Vsw CEN-TR-Landings ####################
cidrVswTRLanding1Vpc1 = "192.168.1.0/29"
cidrVswTRLanding2Vpc1 = "192.168.1.8/29"
cidrVswTRLanding1Vpc2 = "172.16.1.0/29"
cidrVswTRLanding2Vpc2 = "172.16.1.8/29"
cidrVswTRLanding1Vpc3 = "172.18.1.0/29"
cidrVswTRLanding2Vpc3 = "172.18.1.8/29"

#################### EIP ####################
eipFgtChargeType  = "PayByBandwidth"
eipFgtPaymentType = "PayAsYouGo"

#################### ENI IP Address ####################
ipAddrPublicFgt       = "192.168.11.11"
ipAddrPrivateFgt      = "192.168.12.11"
ipAddrFTestVpc2       = "172.16.11.11"
ipAddrFTestVpc3       = "172.18.11.11"

#################### VM-FortiGate ####################
hostnameFgt          = "FGT-ALI-Standalone"
instanceTypeFgtDesignated  = ""

#################### FortiGate [SELECTION] ####################
# PAYG is not available in AliCloud
licenseType          = "byol"

# "fgtvm70" and "fgtvm72" is not available in AliCloud
# "fgtvm64" is is not available in cn-guangzhou
imageVersion          = "fgtvm64"


#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for provisioning
instanceBootstrapFgt = "6.1.alicloud_instance_fgt.conf"
adminsPort           = "443"
licenseFile          = "license.lic"
fgtConfVipSrvPort    = "80"
fgtConfVipExtPort    = "8080"