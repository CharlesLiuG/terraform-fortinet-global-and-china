locals {
  # Pre-compute network/mask pairs for FortiOS syntax
  # Port1 - external
  external_az1_gw   = cidrhost(local.sec_external_az1_cidr, 1)
  external_az2_gw   = cidrhost(local.sec_external_az2_cidr, 1)
  external_az1_mask = cidrnetmask(local.sec_external_az1_cidr)
  external_az2_mask = cidrnetmask(local.sec_external_az2_cidr)

  # Port2 - internal (GWLB target)
  internal_az1_gw   = cidrhost(local.sec_internal_az1_cidr, 1)
  internal_az2_gw   = cidrhost(local.sec_internal_az2_cidr, 1)
  internal_az1_mask = cidrnetmask(local.sec_internal_az1_cidr)
  internal_az2_mask = cidrnetmask(local.sec_internal_az2_cidr)

  # Port3 - ha
  ha_az1_gw   = cidrhost(local.sec_ha_az1_cidr, 1)
  ha_az2_gw   = cidrhost(local.sec_ha_az2_cidr, 1)
  ha_az1_mask = cidrnetmask(local.sec_ha_az1_cidr)
  ha_az2_mask = cidrnetmask(local.sec_ha_az2_cidr)

  # Port4 - mgmt
  mgmt_az1_gw   = cidrhost(local.sec_mgmt_az1_cidr, 1)
  mgmt_az2_gw   = cidrhost(local.sec_mgmt_az2_cidr, 1)
  mgmt_az1_mask = cidrnetmask(local.sec_mgmt_az1_cidr)
  mgmt_az2_mask = cidrnetmask(local.sec_mgmt_az2_cidr)

  # Local spoke CIDRs for static routes
  spoke_a_net  = cidrhost(local.spoke_a_vpc_cidr, 0)
  spoke_a_mask = cidrnetmask(local.spoke_a_vpc_cidr)
  spoke_b_net  = cidrhost(local.spoke_b_vpc_cidr, 0)
  spoke_b_mask = cidrnetmask(local.spoke_b_vpc_cidr)

  # Remote spoke CIDRs — routes via GENEVE tunnels
  remote_spokes = [
    for cidr in var.remote_spoke_cidrs : {
      net  = cidrhost(cidr, 0)
      mask = cidrnetmask(cidr)
    }
  ]

  primary_userdata = templatefile("${path.module}/templates/fgt_primary.tpl", {
    hostname       = "${local.name_prefix}-fgt-1"
    admin_password = var.fortigate_admin_password
    ha_password    = var.ha_password

    port1_ip   = local.primary_external_ip
    port1_mask = local.external_az1_mask
    port1_gw   = local.external_az1_gw
    port2_ip   = local.primary_internal_ip
    port2_mask = local.internal_az1_mask
    port2_gw   = local.internal_az1_gw
    port3_ip   = local.primary_ha_ip
    port3_mask = local.ha_az1_mask
    port3_gw   = local.ha_az1_gw
    port4_ip   = local.primary_mgmt_ip
    port4_mask = local.mgmt_az1_mask
    port4_gw   = local.mgmt_az1_gw

    # FGSP peer IP — secondary's port3 IP for session-sync and config-sync
    peer_ip = local.secondary_ha_ip

    spoke_a_net  = local.spoke_a_net
    spoke_a_mask = local.spoke_a_mask
    spoke_b_net  = local.spoke_b_net
    spoke_b_mask = local.spoke_b_mask

    remote_spokes = local.remote_spokes
    fortiflex_sn  = local.fortiflex_sn_primary
  })

  secondary_userdata = templatefile("${path.module}/templates/fgt_secondary.tpl", {
    hostname       = "${local.name_prefix}-fgt-2"
    admin_password = var.fortigate_admin_password
    ha_password    = var.ha_password

    port1_ip   = local.secondary_external_ip
    port1_mask = local.external_az2_mask
    port1_gw   = local.external_az2_gw
    port2_ip   = local.secondary_internal_ip
    port2_mask = local.internal_az2_mask
    port2_gw   = local.internal_az2_gw
    port3_ip   = local.secondary_ha_ip
    port3_mask = local.ha_az2_mask
    port3_gw   = local.ha_az2_gw
    port4_ip   = local.secondary_mgmt_ip
    port4_mask = local.mgmt_az2_mask
    port4_gw   = local.mgmt_az2_gw

    # FGSP peer IP — primary's port3 IP for session-sync and config-sync
    peer_ip = local.primary_ha_ip

    spoke_a_net  = local.spoke_a_net
    spoke_a_mask = local.spoke_a_mask
    spoke_b_net  = local.spoke_b_net
    spoke_b_mask = local.spoke_b_mask

    remote_spokes = local.remote_spokes
    fortiflex_sn  = local.fortiflex_sn_secondary
  })
}
