locals {
  common_tags = {
    Environment = var.env
    Project     = "gwlb-cloudwan"
    Terraform   = "true"
  }

  name_prefix = "${var.cp}-${var.env}"

  # Build region keys list for cross-reference
  region_keys = keys(var.regions)

  # For each region, compute the "remote" spoke CIDRs (all other regions' spokes)
  remote_spoke_cidrs = {
    for k, v in var.regions : k => flatten([
      for rk, rv in var.regions : [rv.spoke_a_vpc_cidr, rv.spoke_b_vpc_cidr]
      if rk != k
    ])
  }

  # Both derive from the policy attachment so resources implicitly wait for policy to be live
  live_core_network_id  = aws_networkmanager_core_network_policy_attachment.main.core_network_id
  core_network_arn_live = "arn:aws:networkmanager::${split(":", aws_networkmanager_core_network.main.arn)[4]}:core-network/${aws_networkmanager_core_network_policy_attachment.main.core_network_id}"
}
