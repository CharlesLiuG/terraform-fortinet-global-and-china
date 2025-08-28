output "vswAZ" {
  description = "FTest Instance Avaliability Zone"
  value       = data.alicloud_vswitches.vswFTest.vswitches.0.zone_id
}

output "imageId" {
  description = "FTest Instance Image"
  value       = data.alicloud_images.imageFTestLinux.images.0.id
}

output "instance_type" {
  description = "FTest Instance Type"
  value       = data.alicloud_instance_types.instanceTypeFTest.instance_types.0.id
  # value = data.alicloud_instance_types.instanceTypeFTest.instance_types.*.family
}

output "instanceChargeType" {
  description = "FTest Instance Charge Type"
  value       = data.alicloud_instance_types.instanceTypeFTest.instance_charge_type
}

output "spotStragtegy" {
  description = "FTest Instance Spot Stragtegy"
  value       = data.alicloud_instance_types.instanceTypeFTest.spot_strategy
}

output "ipPrivateFTest" {
  description = "FTest Instance Private IP Address"
  value       = alicloud_instance.ftestLinux.private_ip
}
