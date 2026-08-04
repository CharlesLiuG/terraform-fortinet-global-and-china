# ─────────────────────────────────────────────────────────────────────────────────
# State migration for the refactor to for_each.
#
# Only same-type renames are covered here, so importing the previous state into
# this configuration will not destroy and recreate VPCs, subnets, instances or
# route tables. These blocks are no-ops on a fresh state.
#
# NOT covered (see README "Migrating existing state"):
#   - aws_route.spoke_{a,b}_default and aws_route.sec_gwlbe_to_cwan moved to the
#     root module as aws_route.cwan_default[...]; Terraform will destroy the old
#     addresses and create the new ones. Same route, same target, but there is a
#     brief window with no default route in those tables.
#   - aws_route.sec_public_default and aws_route.sec_cwan_to_gwlbe are now inline
#     in their route tables, so the standalone resources are destroyed and the
#     routes re-created as part of the table.
#   - aws_route_table.sec_ha is gone; HA subnets now share aws_route_table.sec_private.
#   - The spoke SSM endpoints are gated by var.enable_ssm_endpoints (default
#     false), so they are destroyed unless you set it to true.
# ─────────────────────────────────────────────────────────────────────────────────

# ── Spoke VPCs ──────────────────────────────────────────────────────────────────
moved {
  from = aws_vpc.spoke_a
  to   = aws_vpc.spoke["a"]
}

moved {
  from = aws_vpc.spoke_b
  to   = aws_vpc.spoke["b"]
}

moved {
  from = aws_subnet.spoke_a_az1
  to   = aws_subnet.spoke["a-az1"]
}

moved {
  from = aws_subnet.spoke_a_az2
  to   = aws_subnet.spoke["a-az2"]
}

moved {
  from = aws_subnet.spoke_b_az1
  to   = aws_subnet.spoke["b-az1"]
}

moved {
  from = aws_subnet.spoke_b_az2
  to   = aws_subnet.spoke["b-az2"]
}

moved {
  from = aws_route_table.spoke_a
  to   = aws_route_table.spoke["a"]
}

moved {
  from = aws_route_table.spoke_b
  to   = aws_route_table.spoke["b"]
}

moved {
  from = aws_route_table_association.spoke_a_az1
  to   = aws_route_table_association.spoke["a-az1"]
}

moved {
  from = aws_route_table_association.spoke_a_az2
  to   = aws_route_table_association.spoke["a-az2"]
}

moved {
  from = aws_route_table_association.spoke_b_az1
  to   = aws_route_table_association.spoke["b-az1"]
}

moved {
  from = aws_route_table_association.spoke_b_az2
  to   = aws_route_table_association.spoke["b-az2"]
}

moved {
  from = aws_security_group.spoke_test
  to   = aws_security_group.spoke_test["a"]
}

moved {
  from = aws_security_group.spoke_b_test
  to   = aws_security_group.spoke_test["b"]
}

moved {
  from = aws_instance.spoke_a_test
  to   = aws_instance.spoke_test["a"]
}

moved {
  from = aws_instance.spoke_b_test
  to   = aws_instance.spoke_test["b"]
}

# ── Security VPC route tables / associations ────────────────────────────────────
moved {
  from = aws_route_table.sec_internal
  to   = aws_route_table.sec_private
}

moved {
  from = aws_route_table_association.sec_external_az1
  to   = aws_route_table_association.sec["external_az1"]
}

moved {
  from = aws_route_table_association.sec_external_az2
  to   = aws_route_table_association.sec["external_az2"]
}

moved {
  from = aws_route_table_association.sec_mgmt_az1
  to   = aws_route_table_association.sec["mgmt_az1"]
}

moved {
  from = aws_route_table_association.sec_mgmt_az2
  to   = aws_route_table_association.sec["mgmt_az2"]
}

moved {
  from = aws_route_table_association.sec_internal_az1
  to   = aws_route_table_association.sec["internal_az1"]
}

moved {
  from = aws_route_table_association.sec_internal_az2
  to   = aws_route_table_association.sec["internal_az2"]
}

moved {
  from = aws_route_table_association.sec_ha_az1
  to   = aws_route_table_association.sec["ha_az1"]
}

moved {
  from = aws_route_table_association.sec_ha_az2
  to   = aws_route_table_association.sec["ha_az2"]
}

moved {
  from = aws_route_table_association.sec_cwan_az1
  to   = aws_route_table_association.sec["cwan_az1"]
}

moved {
  from = aws_route_table_association.sec_cwan_az2
  to   = aws_route_table_association.sec["cwan_az2"]
}

moved {
  from = aws_route_table_association.sec_gwlbe_az1
  to   = aws_route_table_association.sec["gwlbe_az1"]
}

moved {
  from = aws_route_table_association.sec_gwlbe_az2
  to   = aws_route_table_association.sec["gwlbe_az2"]
}
