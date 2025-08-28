ProjectName = "ftntDEMO"

#################### VPC ####################
regionName            = "cn-northwest-1"
azFtnt1               = "cn-northwest-1a"
vpcName               = "VPC-FTest"
cidrVpcFTest          = "172.29.0.0/16"

#################### Subnet ####################
cidrSubnetFTestAz1    = "172.29.100.0/24"
cidrSubnetLbAz1       = "172.29.1.0/24"
cidrSubnetNatgwAz1    = "172.29.2.0/24"

# instanceType          = "c4.large"
instanceType          = "t2.micro"      # t2 can't work with traffic mirror, refer to aws-docs for complete guidance.
hostnameFTest         = "FTest-Linux"
keyName               = "kpc_linux"

fgtConfVipSrcAddr     = "172.29.100.40"

# cloudInitScriptPath  = "../../bootstrap-scripts/bootstrap_nginx_simple_indexpage.sh"
cloudInitScriptPath  = "../../bootstrap-scripts/bootstrap_nginx_php-fpm.sh"
# cloudInitScriptPath  = ""


#################### Toggle true/false ####################
isProvisionLb         = false        # deploy one NLB
isProvisionNatgw      = false

portsListenerNlbPublic = {
    80  = "TCP"    # real webserver port
    443 = "TCP"    # no service behind, demo purpose only, adjust as needed, no sg adjustment required
}