# ─────────────────────────────────────────────────────────────────────────────────
# Cloud WAN Attachments
#
# Each region needs:
#   - 1 VPC attachment for the Security VPC on cwan-subnet (tagged inspection=true → NFG)
#   - 1 VPC attachment for each Spoke VPC (tagged domain=production)
#
# These were 6 hand-copied resource blocks (3 per region). They are now two
# for_each'd resources driven by local.region_modules, so adding a region means
# adding one map entry instead of three resource blocks.
#
# No Connect attachment or Connect Peer needed — FortiGate inspects via GWLB/GENEVE.
# ─────────────────────────────────────────────────────────────────────────────────

locals {
  # Region key → the specific module outputs the attachments need.
  #
  # Only individual outputs are listed, never the whole `module.<name>` object:
  # referencing a module as a value makes the dependency module-wide, which would
  # form a cycle (attachment → whole module → routes → policy → attachment).
  #
  # Because provider aliases must be static, the module blocks themselves stay in
  # main.tf; this map is what lets root-level resources iterate over regions.
  region_modules = {
    singapore = {
      sec_vpc_arn          = module.singapore.sec_vpc_arn
      sec_cwan_subnet_arns = module.singapore.sec_cwan_subnet_arns
      spoke_a_vpc_arn      = module.singapore.spoke_a_vpc_arn
      spoke_a_subnet_arns  = module.singapore.spoke_a_subnet_arns
      spoke_b_vpc_arn      = module.singapore.spoke_b_vpc_arn
      spoke_b_subnet_arns  = module.singapore.spoke_b_subnet_arns
    }
    tokyo = {
      sec_vpc_arn          = module.tokyo.sec_vpc_arn
      sec_cwan_subnet_arns = module.tokyo.sec_cwan_subnet_arns
      spoke_a_vpc_arn      = module.tokyo.spoke_a_vpc_arn
      spoke_a_subnet_arns  = module.tokyo.spoke_a_subnet_arns
      spoke_b_vpc_arn      = module.tokyo.spoke_b_vpc_arn
      spoke_b_subnet_arns  = module.tokyo.spoke_b_subnet_arns
    }
  }

  # Flattened {region, spoke} pairs for the spoke attachments.
  spoke_attachment_targets = merge([
    for key, mod in local.region_modules : {
      "${key}-a" = { region = key, spoke = "a", vpc_arn = mod.spoke_a_vpc_arn, subnet_arns = mod.spoke_a_subnet_arns }
      "${key}-b" = { region = key, spoke = "b", vpc_arn = mod.spoke_b_vpc_arn, subnet_arns = mod.spoke_b_subnet_arns }
    }
  ]...)

  # Route table IDs that need a 0.0.0.0/0 → core network route. Kept separate
  # from region_modules so the attachments do not depend on the route tables.
  region_route_targets = {
    singapore = {
      sec_gwlbe_route_table_id = module.singapore.sec_gwlbe_route_table_id
      spoke_a_route_table_id   = module.singapore.spoke_a_route_table_id
      spoke_b_route_table_id   = module.singapore.spoke_b_route_table_id
    }
    tokyo = {
      sec_gwlbe_route_table_id = module.tokyo.sec_gwlbe_route_table_id
      spoke_a_route_table_id   = module.tokyo.spoke_a_route_table_id
      spoke_b_route_table_id   = module.tokyo.spoke_b_route_table_id
    }
  }
}

# ── Security VPC attachments (one per region) → inspectionVpcs NFG ─────────────
resource "aws_networkmanager_vpc_attachment" "sec" {
  for_each = local.region_modules

  core_network_id = aws_networkmanager_core_network.main.id
  vpc_arn         = each.value.sec_vpc_arn
  subnet_arns     = each.value.sec_cwan_subnet_arns

  options {
    appliance_mode_support = true
    ipv6_support           = false
  }

  tags = merge(local.common_tags, {
    Name       = "${local.name_prefix}-${each.key}-sec-attachment"
    inspection = "true"
  })
}

# ── Spoke VPC attachments (two per region) → production segment ────────────────
resource "aws_networkmanager_vpc_attachment" "spoke" {
  for_each = local.spoke_attachment_targets

  core_network_id = local.live_core_network_id
  vpc_arn         = each.value.vpc_arn
  subnet_arns     = each.value.subnet_arns

  tags = merge(local.common_tags, {
    Name   = "${local.name_prefix}-${each.value.region}-spoke-${each.value.spoke}-attachment"
    domain = "production"
  })
}
