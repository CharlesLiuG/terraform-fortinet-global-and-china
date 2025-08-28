ProjectName                = "ftnt-sniffer"
regionName                 = "cn-northwest-1"
azFtnt1                    = "cn-northwest-1a"

#################### VPC-FGT ####################
vpcNameNgfw                = "VPC-FG-SNIFFER"
cidrVpcNgfw                = "172.31.0.0/16"

# VPC-FGT - Subnets AZ1
cidrSubnetFgtPublicAz1     = "172.31.254.0/28"
cidrSubnetFgtPrivateAz1    = "172.31.254.16/28"

ipAddrFgtPublicAz1         = "172.31.254.11"
ipAddrFgtPrivateAz1        = "172.31.254.21"

#################### FortiGate ####################
instanceTypeFgt            = "c5.large"
hostnameFgtAz1             = "FG-SNIFFER"
dataDiskSzFgt              = "128"         # '40' is the minimum size, and it's recommended to link up with FortiAnalyzer

#################### FortiGate [SELECTION] ####################
# licenseType                = "payg"
licenseType                = "byol"

# imageVersion               = "fgtvm72"
imageVersion               = "fgtvm70"
# imageVersion               = "fgtvm64"

#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for AWS provisioning
instanceBootstrapFile      = "fgt-az1.conf"

portFgtHttps               = "8443"
licenseFile                = "license.lic"


#################### Optional Arguments ####################
# when 'isProvisionVpcSniffer = false', you must specific the following variable, for example
# terraform plan -out=tfplan -var "paramVpcCustomerId=vpc-049a1deda8161a407" -var "paramIgwId=igw-0b951c8cf77c2318f"
isProvisionVpcSniffer      = false