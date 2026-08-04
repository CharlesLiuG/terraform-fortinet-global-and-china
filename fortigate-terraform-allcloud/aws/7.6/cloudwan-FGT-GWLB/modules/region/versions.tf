terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # null is used by the GENEVE provisioning resources (geneve_provisioning.tf).
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
