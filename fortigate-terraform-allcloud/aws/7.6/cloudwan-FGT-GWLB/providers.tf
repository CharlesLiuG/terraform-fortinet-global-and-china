terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Default provider — used for aws_networkmanager_* (global service)
# Uses the first region in the map as default
provider "aws" {
  region = var.regions[local.region_keys[0]].aws_region
}

# ─────────────────────────────────────────────────────────────────────────────────
# Provider aliases — one per region in the regions map.
# When adding a new region to var.regions, add a corresponding provider alias here.
# ─────────────────────────────────────────────────────────────────────────────────
provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

# ── Add more providers below when extending to new regions ──────────────────────
# provider "aws" {
#   alias  = "sydney"
#   region = "ap-southeast-2"
# }
#
# provider "aws" {
#   alias  = "mumbai"
#   region = "ap-south-1"
# }
#
# provider "aws" {
#   alias  = "frankfurt"
#   region = "eu-central-1"
# }
