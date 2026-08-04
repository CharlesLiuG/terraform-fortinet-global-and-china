# ── Naming ──────────────────────────────────────────────────────────────────────
variable "cp" {
  description = "Customer prefix — used in all resource names"
  type        = string
  default     = "acme"
}

variable "env" {
  description = "Environment tag"
  type        = string
  default     = "demo"
}

# ── Region 定義 (核心参数化变量) ────────────────────────────────────────────────
# 通過此 map 定義需要互聯的 Region，增減 Region 只需修改此變量
variable "regions" {
  description = <<-EOT
    Map of regions to deploy. Each key is a short name (e.g. "singapore", "tokyo").
    Modify this map to add/remove/change interconnected regions.
  EOT

  type = map(object({
    aws_region = string # AWS region code, e.g. "ap-southeast-1"

    keypair                = string # EC2 key pair name in this region
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
  }))

  default = {
    singapore = {
      aws_region = "ap-southeast-1"
      keypair    = "my-sg-keypair"

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
      aws_region = "ap-northeast-1"
      keypair    = "my-tky-keypair"

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
}

# ── FortiGate credentials ───────────────────────────────────────────────────────
variable "fortigate_admin_password" {
  description = "FortiGate admin password"
  type        = string
  sensitive   = true
}

variable "ha_password" {
  description = "FortiGate HA cluster password"
  type        = string
  sensitive   = true
}

# ── FortiGate instance config ───────────────────────────────────────────────────
variable "fortigate_instance_type" {
  description = "EC2 instance type for FortiGate"
  type        = string
  default     = "c5n.xlarge"
}

variable "fortios_version" {
  description = "FortiOS major.minor version used to select the latest AMI of that branch"
  type        = string
  default     = "7.6"
}

variable "license_type" {
  description = "FortiGate license type: payg or byol"
  type        = string
  default     = "payg"

  validation {
    condition     = contains(["payg", "byol"], var.license_type)
    error_message = "license_type must be payg or byol"
  }
}

variable "ha_group_name" {
  description = "FortiGate HA group name"
  type        = string
  default     = "cloudwan-ha"
}

# ── Deployment behaviour toggles ────────────────────────────────────────────────
variable "enable_ssm_endpoints" {
  description = <<-EOT
    Create SSM interface VPC endpoints in the spoke VPCs (3 per spoke, 6 per
    region, 12 in total for two regions) so the test instances are reachable via
    Session Manager. Each endpoint takes 2-4 minutes to provision and sits on the
    critical path of the apply, so this defaults to false. Turn it on only when
    you need Session Manager; SSH over Cloud WAN with the region keypair still
    works either way.
  EOT
  type        = bool
  default     = false
}

variable "fortigate_boot_wait" {
  description = <<-EOT
    Seconds the GENEVE provisioner waits before its first SSH probe against a
    freshly booted FortiGate. BYOL with FortiFlex needs time to activate the
    license and reboot; lower this if your image comes up faster.
  EOT
  type        = number
  default     = 600
}
