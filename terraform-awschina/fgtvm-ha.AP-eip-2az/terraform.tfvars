ProjectName = "ftnt-demo-ha"

#################### VPC ####################
regionName           = "cn-northwest-1"
azFtnt1              = "cn-northwest-1a"
azFtnt2              = "cn-northwest-1b"
vpcName              = "VPC-SECURITY"
cidrVpcNgfw          = "172.29.0.0/16"

#################### Subnet FGT ####################
cidrSubnetFgtPublicAz1     = "172.29.254.0/28"
cidrSubnetFgtPrivateAz1    = "172.29.254.16/28"
cidrSubnetFgtHAsyncAz1     = "172.29.254.32/28"
cidrSubnetFgtMgmtAz1       = "172.29.254.48/28"
cidrSubnetFgtTgwAz1        = "172.29.254.64/28"

cidrSubnetFgtPublicAz2     = "172.29.254.80/28"
cidrSubnetFgtPrivateAz2    = "172.29.254.96/28"
cidrSubnetFgtHAsyncAz2     = "172.29.254.112/28"
cidrSubnetFgtMgmtAz2       = "172.29.254.128/28"
cidrSubnetFgtTgwAz2        = "172.29.254.144/28"

#################### ENI IP Address ####################
ipAddrFgtPublicAz1     = "172.29.254.5"
ipAddrFgtPrivateAz1    = "172.29.254.21"
ipAddrFgtHAsyncAz1     = "172.29.254.37"
ipAddrFgtMgmtAz1       = "172.29.254.53"

ipAddrFgtPublicAz2     = "172.29.254.85"
ipAddrFgtPrivateAz2    = "172.29.254.101"
ipAddrFgtHAsyncAz2     = "172.29.254.117"
ipAddrFgtMgmtAz2       = "172.29.254.133"

#################### VM-FortiGate ####################
hostnameFgtAz1         = "FG-AWS-Primary"
hostnameFgtAz2         = "FG-AWS-Secondary"

#################### FortiGate [SELECTION] ####################
# fgtIamProfile        = "FGT-HA"

# licenseType          = "payg"
licenseType          = "byol"

# imageVersion          = "fgtvm72"
imageVersion          = "fgtvm70"
# imageVersion          = "fgtvm64"

#################### Features [toggle true/false] ####################
isProvisionFgtTgwLandingSubnets = false

isProvision3PortsHA             = false      # For 3-port-HA, minimun instance type cloud be lowered to c5.large
instanceTypeFgtDesignated       = "c5.xlarge"

# when 'isProvisionIPsec = false', no security group containing udp-500, udp-4500 will be created.
isProvisionIPsec                = true

# when 'isProvisionFgtEips = false', you must specific the following variable, for example
# terraform plan -out=tfplan -var "eipIdCluster=eipalloc-0590f5d283ca7bb76" -var "eipIdFgtMgmtAz1=eipalloc-03457596337c9f8dd" -var "eipIdFgtMgmtAz2=eipalloc-0c0d119b6737333c8"
# -var variables are stackable
isProvisionFgtEips = true


# when 'isProvisionVpcNgfw = false', you must specific the following variable, for example
# terraform plan -out=tfplan -var "paramVpcCustomerId=vpc-049a1deda8161a407" -var "paramIgwId=igw-0b951c8cf77c2318f"
# cidrs and ipAddrs need change accordingly as well,
# -var variables are stackable
isProvisionVpcNgfw = true


#################### FortiGate Configuration File Variables ####################
# For configuration template file only, NOT for AWS provisioning
instanceBootstrapFgt1 = "fgt-az1.conf"
instanceBootstrapFgt2 = "fgt-az2.conf"

portFgtHttps          = "8443"
license1File          = "license1.lic"
license2File          = "license2.lic"

isProvisionDnatWebSrv    = false
ipAddrVipWebSrv          = "172.29.254.24"
portFgtDnatWebsrvInt     = "80"
portFgtDnatWebsrvExt     = "8080"
