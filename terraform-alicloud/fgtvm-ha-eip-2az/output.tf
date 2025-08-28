#################### VPC ####################
output "VpcNgfwId" {
  value = alicloud_vpc.vpcNgfw.id
}

#################### FortiGate ####################
output "FGT1-Id" {
  value = alicloud_instance.fgt1.id
}

output "FGT2-Id" {
  value = alicloud_instance.fgt2.id
}

output "AZ-FGT1" {
  value = alicloud_vswitch.vswPublicFgt1.availability_zone
}

output "AZ-FGT2" {
  value = alicloud_vswitch.vswPublicFgt2.availability_zone
}

output "FGT-InstanceType" {
  value = var.instanceTypeFgtDesignated != "" ? var.instanceTypeFgtDesignated : data.alicloud_instance_types.instanceTypeFgt.instance_types.0.id
}

output "FGT1-port1" {
  value = alicloud_vswitch.vswPublicFgt1.cidr_block
}

output "FGT1-port2" {
  value = alicloud_vswitch.vswPrivateFgt1.cidr_block
}

output "FGT1-port3" {
  value = alicloud_vswitch.vswHAsyncFgt1.cidr_block
}

output "FGT1-port4" {
  value = alicloud_vswitch.vswMgmtFgt1.cidr_block
}

output "FGT2-port1" {
  value = alicloud_vswitch.vswPublicFgt2.cidr_block
}

output "FGT2-port2" {
  value = alicloud_vswitch.vswPrivateFgt2.cidr_block
}

output "FGT2-port3" {
  value = alicloud_vswitch.vswHAsyncFgt2.cidr_block
}

output "FGT2-port4" {
  value = alicloud_vswitch.vswMgmtFgt2.cidr_block
}


#################### EIPs ####################
output "EIP-FGT-HA" {
  value = alicloud_eip_address.eipFgt.ip_address
}

output "EIP-FGT1-Mgmt" {
  value = alicloud_eip_address.eipMgmtFgt1.ip_address
}

output "EIP-FGT2-Mgmt" {
  value = alicloud_eip_address.eipMgmtFgt2.ip_address
}


#################### FTest ####################
output "LAN-FTest-vsw-ID" {
  value = alicloud_vswitch.vswPrivateFgt1.id
}

output "LAN-FTest-SG-ID" {
  value = alicloud_security_group.sgFgtPrivate.id
}
