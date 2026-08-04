# ─────────────────────────────────────────────────────────────────────────────────
# Region Modules
#
# Terraform still requires provider aliases in a module block to be static
# (provider for_each is not available in the installed Terraform), so there is
# one module block per region. Everything else is now passed as a single
# var.regions[key] object, so each block is ~10 lines instead of ~55 and adding a
# region no longer means copying 22 argument assignments.
#
# To add a new region:
#   1. Add the region to var.regions in terraform.tfvars
#   2. Add a provider alias in providers.tf
#   3. Copy a module block below, changing the key and the provider alias
#   4. Add the region to cloud_wan_attachments.tf's local.region_modules map
# ─────────────────────────────────────────────────────────────────────────────────

module "singapore" {
  source = "./modules/region"

  providers = {
    aws = aws.singapore
  }

  cp            = var.cp
  env           = var.env
  region_name   = "singapore"
  region_config = var.regions["singapore"]

  # Remote spoke CIDRs — FortiGate needs static routes for return traffic
  remote_spoke_cidrs = local.remote_spoke_cidrs["singapore"]

  # FortiGate config
  fortigate_admin_password = var.fortigate_admin_password
  ha_password              = var.ha_password
  fortigate_instance_type  = var.fortigate_instance_type
  fortios_version          = var.fortios_version
  license_type             = var.license_type

  enable_ssm_endpoints = var.enable_ssm_endpoints
  fortigate_boot_wait  = var.fortigate_boot_wait
}

module "tokyo" {
  source = "./modules/region"

  providers = {
    aws = aws.tokyo
  }

  cp            = var.cp
  env           = var.env
  region_name   = "tokyo"
  region_config = var.regions["tokyo"]

  remote_spoke_cidrs = local.remote_spoke_cidrs["tokyo"]

  fortigate_admin_password = var.fortigate_admin_password
  ha_password              = var.ha_password
  fortigate_instance_type  = var.fortigate_instance_type
  fortios_version          = var.fortios_version
  license_type             = var.license_type

  enable_ssm_endpoints = var.enable_ssm_endpoints
  fortigate_boot_wait  = var.fortigate_boot_wait
}
