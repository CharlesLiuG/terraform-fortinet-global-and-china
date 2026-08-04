output "core_network_id" {
  value = aws_networkmanager_core_network.main.id
}

output "core_network_arn" {
  value = local.core_network_arn_live
}

output "regions_deployed" {
  description = "List of region keys deployed"
  value       = local.region_keys
}

# ── Singapore ───────────────────────────────────────────────────────────────────
output "singapore_primary_mgmt_url" {
  description = "HTTPS management URL for Singapore primary FortiGate"
  value       = module.singapore.primary_mgmt_url
}

output "singapore_secondary_mgmt_url" {
  description = "HTTPS management URL for Singapore secondary FortiGate"
  value       = module.singapore.secondary_mgmt_url
}

output "singapore_primary_external_eip" {
  value = module.singapore.primary_external_eip
}

output "singapore_secondary_external_eip" {
  value = module.singapore.secondary_external_eip
}

output "singapore_gwlb_service_name" {
  description = "GWLB Endpoint Service name for Singapore"
  value       = module.singapore.gwlb_service_name
}

# ── Tokyo ───────────────────────────────────────────────────────────────────────
output "tokyo_primary_mgmt_url" {
  description = "HTTPS management URL for Tokyo primary FortiGate"
  value       = module.tokyo.primary_mgmt_url
}

output "tokyo_secondary_mgmt_url" {
  description = "HTTPS management URL for Tokyo secondary FortiGate"
  value       = module.tokyo.secondary_mgmt_url
}

output "tokyo_primary_external_eip" {
  value = module.tokyo.primary_external_eip
}

output "tokyo_secondary_external_eip" {
  value = module.tokyo.secondary_external_eip
}

output "tokyo_gwlb_service_name" {
  description = "GWLB Endpoint Service name for Tokyo"
  value       = module.tokyo.gwlb_service_name
}
