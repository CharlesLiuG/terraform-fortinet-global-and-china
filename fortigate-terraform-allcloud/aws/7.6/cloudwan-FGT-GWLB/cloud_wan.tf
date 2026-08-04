# ─────────────────────────────────────────────────────────────────────────────────
# Cloud WAN Policy — GWLB Service Insertion (FortiGate Inspection)
#
# Architecture:
#   - "production" segment: Spoke VPC attachments (isolate-attachments = true)
#   - Network Function Group "inspectionVpcs": Security VPC attachments (tagged inspection=true)
#   - segment-actions "send-via": spoke-to-spoke in production forced through FortiGate
#   - segment-actions "send-to": intra-segment traffic also inspected
#
# Traffic flow:
#   Spoke A → Cloud WAN → cwan-subnet → GWLBE → GWLB → FortiGate port2 (GENEVE)
#   → GWLB → GWLBE → cwan-subnet → Cloud WAN → Spoke B
# ─────────────────────────────────────────────────────────────────────────────────

resource "aws_networkmanager_global_network" "main" {
  description = "${local.name_prefix} GWLB Cloud WAN"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-global-network"
  })
}

# ── Base policy (required for initial core network creation before attachments) ──
data "aws_networkmanager_core_network_policy_document" "base" {
  core_network_configuration {
    vpn_ecmp_support   = true
    asn_ranges         = ["64520-65534"]
    inside_cidr_blocks = ["172.31.0.0/16"]

    dynamic "edge_locations" {
      for_each = var.regions
      content {
        location = edge_locations.value.aws_region
        asn      = 64520 + index(local.region_keys, edge_locations.key)
      }
    }
  }

  segments {
    name                          = "production"
    description                   = "Production spoke traffic"
    require_attachment_acceptance = false
    isolate_attachments           = true
  }

  network_function_groups {
    name                          = "inspectionVpcs"
    description                   = "Network Function Group with FortiGate GWLB inspection"
    require_attachment_acceptance = false
  }

  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "inspection"
      value    = "true"
    }

    action {
      add_to_network_function_group = "inspectionVpcs"
    }
  }

  attachment_policies {
    rule_number     = 200
    condition_logic = "or"

    conditions {
      type = "tag-exists"
      key  = "domain"
    }

    action {
      association_method = "tag"
      tag_value_of_key   = "domain"
    }
  }
}

# ── Full policy (JSON template - required because with_edge_overrides is not
#    supported in the aws_networkmanager_core_network_policy_document data source) ─
locals {
  # Build edge_locations dynamically for the JSON policy
  policy_edge_locations = [
    for idx, key in local.region_keys : {
      location = var.regions[key].aws_region
      asn      = 64520 + idx
    }
  ]

  full_policy_json = jsonencode({
    version = "2021.12"

    "core-network-configuration" = {
      "vpn-ecmp-support"   = true
      "asn-ranges"         = ["64520-65534"]
      "inside-cidr-blocks" = ["172.31.0.0/16"]
      "edge-locations" = [
        for loc in local.policy_edge_locations : {
          location = loc.location
          asn      = loc.asn
        }
      ]
    }

    segments = [
      {
        name                            = "production"
        description                     = "Production spoke traffic"
        "require-attachment-acceptance" = false
        "isolate-attachments"           = true
      }
    ]

    "network-function-groups" = [
      {
        name                            = "inspectionVpcs"
        description                     = "Network Function Group with FortiGate GWLB inspection"
        "require-attachment-acceptance" = false
      }
    ]

    "segment-actions" = [
      {
        action  = "send-via"
        segment = "production"
        mode    = "single-hop"
        "when-sent-to" = {
          segments = "*"
        }
        via = {
          "network-function-groups" = ["inspectionVpcs"]
          "with-edge-overrides" = [
            {
              "edge-sets"         = [["ap-southeast-1", "ap-northeast-1"]]
              "use-edge-location" = "ap-northeast-1"
            },
            {
              "edge-sets"         = [["ap-northeast-1", "ap-southeast-1"]]
              "use-edge-location" = "ap-southeast-1"
            }
          ]
        }
      },
      {
        action  = "send-to"
        segment = "production"
        via = {
          "network-function-groups" = ["inspectionVpcs"]
        }
      }
    ]

    "attachment-policies" = [
      {
        "rule-number"     = 100
        "condition-logic" = "or"
        conditions = [
          {
            type     = "tag-value"
            operator = "equals"
            key      = "inspection"
            value    = "true"
          }
        ]
        action = {
          "add-to-network-function-group" = "inspectionVpcs"
        }
      },
      {
        "rule-number"     = 200
        "condition-logic" = "or"
        conditions = [
          {
            type = "tag-exists"
            key  = "domain"
          }
        ]
        action = {
          "association-method" = "tag"
          "tag-value-of-key"   = "domain"
        }
      }
    ]
  })
}

# ── Core Network ────────────────────────────────────────────────────────────────
resource "aws_networkmanager_core_network" "main" {
  global_network_id    = aws_networkmanager_global_network.main.id
  description          = "${local.name_prefix} core network"
  create_base_policy   = true
  base_policy_document = data.aws_networkmanager_core_network_policy_document.base.json

  timeouts {
    create = "30m"
    delete = "30m"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-core-network"
  })
}

resource "aws_networkmanager_core_network_policy_attachment" "main" {
  core_network_id = aws_networkmanager_core_network.main.id
  policy_document = local.full_policy_json

  # The send-via / send-to actions reference the inspectionVpcs NFG, so every
  # Security VPC attachment must exist before the full policy is applied.
  depends_on = [aws_networkmanager_vpc_attachment.sec]
}
