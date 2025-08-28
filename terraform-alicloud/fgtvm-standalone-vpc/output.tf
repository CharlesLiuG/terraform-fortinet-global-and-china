#################### VPC ####################
output "VpcNgfwId" {
  value = alicloud_vpc.vpcNgfw.id
}

#################### Subnet Primary ####################
output "FortiGateId" {
  value = alicloud_instance.fgtStandalone.id
}

output "idVswPrivate" {
  value = alicloud_vswitch.vswPrivate.id
}

output "idSgFgtPrivate" {
  value = alicloud_security_group.sgFgtPrivate.id
}

output "azFortiGate" {
  value = alicloud_vswitch.vswPublic.availability_zone
}

output "FortiGateInstanceType" {
  value = var.instanceTypeFgtDesignated != "" ? var.instanceTypeFgtDesignated : data.alicloud_instance_types.instanceTypeFgt.instance_types.0.id
}

output "vswPublic" {
  value = alicloud_vswitch.vswPublic.cidr_block
}

output "vswPrivate" {
  value = alicloud_vswitch.vswPrivate.cidr_block
}


#################### EIPs ####################
output "EIP-FGT" {
  value = alicloud_eip_address.eipFgt.ip_address
}
