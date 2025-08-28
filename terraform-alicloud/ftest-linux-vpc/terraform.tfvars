ProjectName = "ftntDEMO"

#################### VPC ####################
regionName           = "cn-beijing"
vpcName              = "VPC-FTest"
cidrVpcFTest         = "192.168.0.0/16"
cidrVswFTest         = "192.168.12.0/24"
nameVswFTest         = "vsw_Ftest"

#################### EIP ####################
eipFTestChargeType   = "PayByBandwidth"
eipFTestPaymentType  = "PayAsYouGo"

#################### FTest ####################
instanceTypeFgtDesignated = ""
spotStrategyDesignated    = ""
vCpuDesignated            = ""
ramDesignated             = ""
ecsFamilyDesignated       = ""

ipPrivateFTest       = "192.168.12.40"
# cloudInitScriptPath  = "../../bootstrap-scripts/bootstrap_nginx_simple_indexpage.sh"
cloudInitScriptPath  = "../../bootstrap-scripts/bootstrap_shadowsocks_privoxy_ubuntu1804.sh"
# cloudInitScriptPath  = ""