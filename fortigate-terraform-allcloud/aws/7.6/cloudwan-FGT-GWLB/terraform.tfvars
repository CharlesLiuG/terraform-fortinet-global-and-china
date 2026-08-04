cp  = "lg-vwan"
env = "demo"

regions = {
  singapore = {
    aws_region             = "ap-southeast-1"
    keypair                = "lg-vwan"
    fortiflex_sn_primary   = "A56xxxxxxxxxxxxxxxxx"
    fortiflex_sn_secondary = "657xxxxxxxxxxxxxxxxx"

    sec_vpc_cidr          = "10.1.0.0/16"
    sec_external_az1_cidr = "10.1.1.0/24"
    sec_external_az2_cidr = "10.1.2.0/24"
    sec_internal_az1_cidr = "10.1.3.0/24"
    sec_internal_az2_cidr = "10.1.4.0/24"
    sec_ha_az1_cidr       = "10.1.5.0/24"
    sec_ha_az2_cidr       = "10.1.6.0/24"
    sec_mgmt_az1_cidr     = "10.1.7.0/24"
    sec_mgmt_az2_cidr     = "10.1.8.0/24"
    sec_cwan_az1_cidr     = "10.1.9.0/24"
    sec_cwan_az2_cidr     = "10.1.10.0/24"
    sec_gwlbe_az1_cidr    = "10.1.11.0/24"
    sec_gwlbe_az2_cidr    = "10.1.12.0/24"

    spoke_a_vpc_cidr        = "10.2.0.0/16"
    spoke_a_subnet_az1_cidr = "10.2.1.0/24"
    spoke_a_subnet_az2_cidr = "10.2.2.0/24"
    spoke_b_vpc_cidr        = "10.3.0.0/16"
    spoke_b_subnet_az1_cidr = "10.3.1.0/24"
    spoke_b_subnet_az2_cidr = "10.3.2.0/24"
  }

  tokyo = {
    aws_region             = "ap-northeast-1"
    keypair                = "lg-vwan"
    fortiflex_sn_primary   = "40Cxxxxxxxxxxxxxxxxx"
    fortiflex_sn_secondary = "D71xxxxxxxxxxxxxxxxx"

    sec_vpc_cidr          = "10.11.0.0/16"
    sec_external_az1_cidr = "10.11.1.0/24"
    sec_external_az2_cidr = "10.11.2.0/24"
    sec_internal_az1_cidr = "10.11.3.0/24"
    sec_internal_az2_cidr = "10.11.4.0/24"
    sec_ha_az1_cidr       = "10.11.5.0/24"
    sec_ha_az2_cidr       = "10.11.6.0/24"
    sec_mgmt_az1_cidr     = "10.11.7.0/24"
    sec_mgmt_az2_cidr     = "10.11.8.0/24"
    sec_cwan_az1_cidr     = "10.11.9.0/24"
    sec_cwan_az2_cidr     = "10.11.10.0/24"
    sec_gwlbe_az1_cidr    = "10.11.11.0/24"
    sec_gwlbe_az2_cidr    = "10.11.12.0/24"

    spoke_a_vpc_cidr        = "10.12.0.0/16"
    spoke_a_subnet_az1_cidr = "10.12.1.0/24"
    spoke_a_subnet_az2_cidr = "10.12.2.0/24"
    spoke_b_vpc_cidr        = "10.13.0.0/16"
    spoke_b_subnet_az1_cidr = "10.13.1.0/24"
    spoke_b_subnet_az2_cidr = "10.13.2.0/24"
  }
}

fortigate_admin_password = "Fortinet@123.com"
ha_password              = "Fortinet@123.com"
fortigate_instance_type  = "c6i.xlarge"
fortios_version          = "7.6.7"
license_type             = "byol"
enable_ssm_endpoints = False
