# ─────────────────────────────────────────────────────────────────────────────────
# Cloud WAN default routes (0.0.0.0/0 → core network)
#
# These live in the root module, not in modules/region, because they must be
# ordered after the region's Cloud WAN VPC attachments — and the attachments are
# built from the module's VPC ARNs, so the module cannot depend on them without
# creating a cycle.
#
# IMPORTANT: Because Terraform does not support dynamic provider selection in a
# for_each resource, routes MUST be split per region so each uses the correct
# provider alias. A route table in ap-northeast-1 cannot be looked up via an
# API call to ap-southeast-1.
#
# The attachment_id value is unused by the API call itself; it exists purely to
# create the dependency edge — the route is attempted only after the attachment
# reports AVAILABLE.
# ─────────────────────────────────────────────────────────────────────────────────

locals {
  # One core-network default route per route table that needs to reach Cloud WAN:
  # the two spoke route tables plus the Security VPC's gwlbe route table (which
  # carries post-inspection return traffic).
  cwan_default_routes = merge([
    for key, mod in local.region_route_targets : {
      "${key}-spoke-a" = {
        route_table_id = mod.spoke_a_route_table_id
        attachment_id  = aws_networkmanager_vpc_attachment.spoke["${key}-a"].id
      }
      "${key}-spoke-b" = {
        route_table_id = mod.spoke_b_route_table_id
        attachment_id  = aws_networkmanager_vpc_attachment.spoke["${key}-b"].id
      }
      "${key}-sec-gwlbe" = {
        route_table_id = mod.sec_gwlbe_route_table_id
        attachment_id  = aws_networkmanager_vpc_attachment.sec[key].id
      }
    }
  ]...)

  # Per-region subsets for provider-specific resource blocks
  cwan_routes_singapore = {
    for k, v in local.cwan_default_routes : k => v if startswith(k, "singapore-")
  }
  cwan_routes_tokyo = {
    for k, v in local.cwan_default_routes : k => v if startswith(k, "tokyo-")
  }
}

# ── Singapore routes (ap-southeast-1) ──────────────────────────────────────────
resource "aws_route" "cwan_default_singapore" {
  for_each = local.cwan_routes_singapore
  provider = aws.singapore

  route_table_id         = each.value.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = local.core_network_arn_live

  lifecycle {
    precondition {
      condition     = each.value.attachment_id != ""
      error_message = "Cloud WAN attachment must exist before its core-network route is created."
    }
  }
}

# ── Tokyo routes (ap-northeast-1) ──────────────────────────────────────────────
resource "aws_route" "cwan_default_tokyo" {
  for_each = local.cwan_routes_tokyo
  provider = aws.tokyo

  route_table_id         = each.value.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  core_network_arn       = local.core_network_arn_live

  lifecycle {
    precondition {
      condition     = each.value.attachment_id != ""
      error_message = "Cloud WAN attachment must exist before its core-network route is created."
    }
  }
}

# ── Moved blocks — preserve existing Singapore routes in state ─────────────────
moved {
  from = aws_route.cwan_default["singapore-spoke-a"]
  to   = aws_route.cwan_default_singapore["singapore-spoke-a"]
}

moved {
  from = aws_route.cwan_default["singapore-spoke-b"]
  to   = aws_route.cwan_default_singapore["singapore-spoke-b"]
}

moved {
  from = aws_route.cwan_default["singapore-sec-gwlbe"]
  to   = aws_route.cwan_default_singapore["singapore-sec-gwlbe"]
}

# Tokyo routes never successfully created, so no moved blocks needed for them.
