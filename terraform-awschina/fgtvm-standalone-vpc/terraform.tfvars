ProjectName                = "ftntDEMO"
regionName                 = "cn-northwest-1"
azFtnt1                    = "cn-northwest-1a"

#################### VPC-FGT ####################
vpcNameNgfw                = "VPC-NGFW"
cidrVpcNgfw                = "172.31.0.0/16"

# VPC-FGT - Subnets AZ1
cidrSubnetFgtPublicAz1     = "172.31.11.0/24"
cidrSubnetFgtPrivateAz1    = "172.31.12.0/24"

ipAddrFgtPublicAz1         = "172.31.11.11"
ipAddrFgtPrivateAz1        = "172.31.12.11"

#################### FortiGate ####################
instanceTypeFgt            = "c5.large"
hostnameFgtAz1             = "FGT-AWS-Standalone"

#################### FortiGate [SELECTION] ####################
# licenseType                = "payg"
licenseType                = "byol"

# imageVersion               = "fgtvm72"
imageVersion               = "fgtvm70"
# imageVersion               = "fgtvm64"

#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for AWS provisioning
instanceBootstrapFile  = "fgt-az1.conf"

portFgtHttps           = "8443"
licenseFile            = "license.lic"

#################### Optional Arguments ####################
isProvisionIPsec         = true

isProvisionDnatWebSrv    = false
ipAddrFgtDnatWebsrv      = "172.31.12.40"
portFgtDnatWebsrvInt     = "80"
portFgtDnatWebsrvExt     = "8080"
cloudInitScriptPath      = "../../bootstrap-scripts/bootstrap_nginx_php-fpm.sh"
keyName                  = "kpc_linux"

# when 'isProvisionVpcNgfw = false', you must specific the following variable, for example
# terraform plan -out=tfplan -var "paramVpcCustomerId=vpc-049a1deda8161a407" -var "paramIgwId=igw-0b951c8cf77c2318f"
# cidrVpcNgfw, cidrSubnetFgtPublicAz1, cidrSubnetFgtPrivateAz1 need change accordingly as well,
# ipAddrFgtPublicAz1, ipAddrFgtPrivateAz1 need change accordingly too.
isProvisionVpcNgfw       = true