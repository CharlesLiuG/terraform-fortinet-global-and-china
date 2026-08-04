variable "cp" {
  type = string
}

variable "env" {
  type = string
}

variable "region_name" {
  description = "Short name for this region used in resource names (e.g. singapore, tokyo)"
  type        = string
}

# ─────────────────────────────────────────────────────────────────────────────────
# Region configuration — a single object matching one entry of the root
# var.regions map. Collapsing 22 individual variables into one object removes the
# per-region copy/paste in the root module (see main.tf).
# ─────────────────────────────────────────────────────────────────────────────────
variable "region_config" {
  description = "Full configuration object for this region, passed straight from root var.regions[key]"

  type = object({
    aws_region = string

    keypair                = string
    fortiflex_sn_primary   = optional(string, "")
    fortiflex_sn_secondary = optional(string, "")

    # Security VPC CIDRs
    sec_vpc_cidr          = string
    sec_external_az1_cidr = string
    sec_external_az2_cidr = string
    sec_internal_az1_cidr = string
    sec_internal_az2_cidr = string
    sec_ha_az1_cidr       = string
    sec_ha_az2_cidr       = string
    sec_mgmt_az1_cidr     = string
    sec_mgmt_az2_cidr     = string
    sec_cwan_az1_cidr     = string
    sec_cwan_az2_cidr     = string
    sec_gwlbe_az1_cidr    = string
    sec_gwlbe_az2_cidr    = string

    # Spoke VPC CIDRs
    spoke_a_vpc_cidr        = string
    spoke_a_subnet_az1_cidr = string
    spoke_a_subnet_az2_cidr = string
    spoke_b_vpc_cidr        = string
    spoke_b_subnet_az1_cidr = string
    spoke_b_subnet_az2_cidr = string
  })
}

# ── Cloud WAN ───────────────────────────────────────────────────────────────────
variable "remote_spoke_cidrs" {
  description = "List of spoke CIDRs from all other regions — FortiGate routes to these via GENEVE tunnels"
  type        = list(string)
  default     = []
}

# ── FortiGate ───────────────────────────────────────────────────────────────────
variable "fortigate_admin_password" {
  type      = string
  sensitive = true
}

variable "ha_password" {
  description = "FGSP HA cluster password — must match on both peers"
  type        = string
  sensitive   = true
}

variable "fortigate_instance_type" {
  type = string
}

variable "fortios_version" {
  type = string
}

variable "license_type" {
  type = string
}

# ── Deployment behaviour toggles ────────────────────────────────────────────────
variable "enable_ssm_endpoints" {
  description = <<-EOT
    Create the 6 SSM interface VPC endpoints (3 per spoke VPC) used to reach the
    spoke test instances via Session Manager. Each endpoint takes 2-4 minutes to
    create, so this is off by default. With it off the test instances are still
    reachable by SSH over Cloud WAN using var.region_config.keypair.
  EOT
  type        = bool
  default     = false
}

variable "fortigate_boot_wait" {
  description = "Seconds to wait before the first SSH probe against a freshly booted FortiGate"
  type        = number
  default     = 600
}
