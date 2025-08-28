#################### VPC ####################
output "VpcNgfwId" {
  value = alicloud_vpc.vpcNgfw.id
}

#################### FortiGate ####################
output "FortiGateId" {
  value = alicloud_instance.fgtStandalone.id
}

output "FortiGateInstanceType" {
  value = var.instanceTypeFgtDesignated != "" ? var.instanceTypeFgtDesignated : data.alicloud_instance_types.instanceTypeFgt.instance_types.0.id
}

output "azFortiGate" {
  value = alicloud_vswitch.vswPublic.availability_zone
}

output "vswPublic" {
  value = alicloud_vswitch.vswPublic.cidr_block
}

output "vswPrivate" {
  value = alicloud_vswitch.vswPrivate.cidr_block
}

#################### FTest ####################
output "ipAddrFTest2" {
  value = alicloud_instance.ftestLinux2.private_ip
}

output "ipAddrFTest3" {
  value = alicloud_instance.ftestLinux3.private_ip
}

#################### Vsw CEN-TR-Landings ####################
output "azCenTRLanding1" {
  value = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
}

output "azCenTRLanding2" {
  value = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]
}


#################### EIPs ####################
output "EIP-FGT" {
  value = alicloud_eip_address.eipFgt.ip_address
}


