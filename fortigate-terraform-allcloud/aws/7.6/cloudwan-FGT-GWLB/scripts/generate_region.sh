#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────────
# generate_region.sh — 生成新 Region 的 Terraform 代码片段
#
# 用法: ./scripts/generate_region.sh <region_key> <aws_region_code>
# 示例: ./scripts/generate_region.sh sydney ap-southeast-2
#
# 生成的代码需要手动复制到对应文件中
# ─────────────────────────────────────────────────────────────────────────────────

set -e

if [ $# -ne 2 ]; then
    echo "用法: $0 <region_key> <aws_region_code>"
    echo "示例: $0 sydney ap-southeast-2"
    exit 1
fi

REGION_KEY="$1"
AWS_REGION="$2"

cat <<EOF

╔══════════════════════════════════════════════════════════════════════════════════╗
║  新增 Region: ${REGION_KEY} (${AWS_REGION})
║  请将以下代码片段分别添加到对应文件中
╚══════════════════════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. providers.tf — 添加 provider alias:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

provider "aws" {
  alias  = "${REGION_KEY}"
  region = "${AWS_REGION}"
}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2. main.tf — 添加 module block:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

module "${REGION_KEY}" {
  source = "./modules/region"

  providers = {
    aws = aws.${REGION_KEY}
  }

  cp          = var.cp
  env         = var.env
  region_name = "${REGION_KEY}"

  sec_vpc_cidr          = var.regions["${REGION_KEY}"].sec_vpc_cidr
  sec_external_az1_cidr = var.regions["${REGION_KEY}"].sec_external_az1_cidr
  sec_external_az2_cidr = var.regions["${REGION_KEY}"].sec_external_az2_cidr
  sec_internal_az1_cidr = var.regions["${REGION_KEY}"].sec_internal_az1_cidr
  sec_internal_az2_cidr = var.regions["${REGION_KEY}"].sec_internal_az2_cidr
  sec_ha_az1_cidr       = var.regions["${REGION_KEY}"].sec_ha_az1_cidr
  sec_ha_az2_cidr       = var.regions["${REGION_KEY}"].sec_ha_az2_cidr
  sec_mgmt_az1_cidr     = var.regions["${REGION_KEY}"].sec_mgmt_az1_cidr
  sec_mgmt_az2_cidr     = var.regions["${REGION_KEY}"].sec_mgmt_az2_cidr

  spoke_a_vpc_cidr        = var.regions["${REGION_KEY}"].spoke_a_vpc_cidr
  spoke_a_subnet_az1_cidr = var.regions["${REGION_KEY}"].spoke_a_subnet_az1_cidr
  spoke_a_subnet_az2_cidr = var.regions["${REGION_KEY}"].spoke_a_subnet_az2_cidr
  spoke_b_vpc_cidr        = var.regions["${REGION_KEY}"].spoke_b_vpc_cidr
  spoke_b_subnet_az1_cidr = var.regions["${REGION_KEY}"].spoke_b_subnet_az1_cidr
  spoke_b_subnet_az2_cidr = var.regions["${REGION_KEY}"].spoke_b_subnet_az2_cidr

  core_network_arn          = local.core_network_arn_live
  cne_inside_cidr_primary   = var.regions["${REGION_KEY}"].cne_inside_cidr_primary
  cne_inside_cidr_secondary = var.regions["${REGION_KEY}"].cne_inside_cidr_secondary
  cne_bgp_ip_primary        = local.cne_bgp_ips["${REGION_KEY}"].primary
  cne_bgp_ip_secondary      = local.cne_bgp_ips["${REGION_KEY}"].secondary
  cne_asn                   = var.regions["${REGION_KEY}"].cne_asn

  remote_spoke_cidrs = local.remote_spoke_cidrs["${REGION_KEY}"]

  keypair                  = var.regions["${REGION_KEY}"].keypair
  fortigate_admin_password = var.fortigate_admin_password
  ha_password              = var.ha_password
  ha_group_name            = var.ha_group_name
  fortigate_instance_type  = var.fortigate_instance_type
  fortios_version          = var.fortios_version
  license_type             = var.license_type
  fgt_asn                  = var.fgt_asn
  fortiflex_sn_primary     = var.regions["${REGION_KEY}"].fortiflex_sn_primary
  fortiflex_sn_secondary   = var.regions["${REGION_KEY}"].fortiflex_sn_secondary
}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3. cloud_wan_attachments.tf — 添加 attachment 资源:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

resource "aws_networkmanager_vpc_attachment" "${REGION_KEY}_sec" {
  core_network_id = local.live_core_network_id
  vpc_arn         = module.${REGION_KEY}.sec_vpc_arn
  subnet_arns     = module.${REGION_KEY}.sec_internal_subnet_arns

  options {
    appliance_mode_support = true
    ipv6_support           = false
  }

  tags = merge(local.common_tags, {
    Name = "\${local.name_prefix}-${REGION_KEY}-sec-attachment"
  })
}

resource "aws_networkmanager_vpc_attachment" "${REGION_KEY}_spoke_a" {
  core_network_id = local.live_core_network_id
  vpc_arn         = module.${REGION_KEY}.spoke_a_vpc_arn
  subnet_arns     = module.${REGION_KEY}.spoke_a_subnet_arns

  tags = merge(local.common_tags, {
    Name = "\${local.name_prefix}-${REGION_KEY}-spoke-a-attachment"
  })
}

resource "aws_networkmanager_vpc_attachment" "${REGION_KEY}_spoke_b" {
  core_network_id = local.live_core_network_id
  vpc_arn         = module.${REGION_KEY}.spoke_b_vpc_arn
  subnet_arns     = module.${REGION_KEY}.spoke_b_subnet_arns

  tags = merge(local.common_tags, {
    Name = "\${local.name_prefix}-${REGION_KEY}-spoke-b-attachment"
  })
}

resource "aws_networkmanager_connect_attachment" "${REGION_KEY}" {
  core_network_id        = local.live_core_network_id
  transport_attachment_id = aws_networkmanager_vpc_attachment.${REGION_KEY}_sec.id
  edge_location          = var.regions["${REGION_KEY}"].aws_region

  options {
    protocol = "NO_ENCAP"
  }

  tags = merge(local.common_tags, {
    Name = "\${local.name_prefix}-${REGION_KEY}-connect-attachment"
  })
}

resource "aws_networkmanager_connect_peer" "${REGION_KEY}_primary" {
  connect_attachment_id = aws_networkmanager_connect_attachment.${REGION_KEY}.id
  peer_address          = module.${REGION_KEY}.primary_internal_ip
  subnet_arn            = module.${REGION_KEY}.sec_internal_az1_subnet_arn

  bgp_options {
    peer_asn = var.fgt_asn
  }

  tags = merge(local.common_tags, {
    Name = "\${local.name_prefix}-${REGION_KEY}-fgt-primary-peer"
  })
}

resource "aws_networkmanager_connect_peer" "${REGION_KEY}_secondary" {
  connect_attachment_id = aws_networkmanager_connect_attachment.${REGION_KEY}.id
  peer_address          = module.${REGION_KEY}.secondary_internal_ip
  subnet_arn            = module.${REGION_KEY}.sec_internal_az2_subnet_arn

  bgp_options {
    peer_asn = var.fgt_asn
  }

  tags = merge(local.common_tags, {
    Name = "\${local.name_prefix}-${REGION_KEY}-fgt-secondary-peer"
  })
}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4. outputs.tf — 添加输出:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

output "${REGION_KEY}_primary_mgmt_url" {
  value = module.${REGION_KEY}.primary_mgmt_url
}

output "${REGION_KEY}_secondary_mgmt_url" {
  value = module.${REGION_KEY}.secondary_mgmt_url
}

output "${REGION_KEY}_cluster_eip" {
  value = module.${REGION_KEY}.cluster_eip
}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
5. terraform.tfvars — 在 regions map 中添加:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ${REGION_KEY} = {
    aws_region = "${AWS_REGION}"
    cne_asn    = XXXXX   # 选择一个唯一的 ASN
    keypair    = "my-${REGION_KEY}-keypair"

    sec_vpc_cidr          = "10.X.0.0/16"
    sec_external_az1_cidr = "10.X.1.0/24"
    sec_external_az2_cidr = "10.X.2.0/24"
    sec_internal_az1_cidr = "10.X.3.0/24"
    sec_internal_az2_cidr = "10.X.4.0/24"
    sec_ha_az1_cidr       = "10.X.5.0/24"
    sec_ha_az2_cidr       = "10.X.6.0/24"
    sec_mgmt_az1_cidr     = "10.X.7.0/24"
    sec_mgmt_az2_cidr     = "10.X.8.0/24"

    spoke_a_vpc_cidr        = "10.Y.0.0/16"
    spoke_a_subnet_az1_cidr = "10.Y.1.0/24"
    spoke_a_subnet_az2_cidr = "10.Y.2.0/24"
    spoke_b_vpc_cidr        = "10.Z.0.0/16"
    spoke_b_subnet_az1_cidr = "10.Z.1.0/24"
    spoke_b_subnet_az2_cidr = "10.Z.2.0/24"

    cne_inside_cidr_primary   = "169.254.X.0/29"
    cne_inside_cidr_secondary = "169.254.X.8/29"
  }

══════════════════════════════════════════════════════════════════════════════════════
注意: Cloud WAN policy 的 edge-locations 会自动从 var.regions map 生成，无需手动修改。
      remote_spoke_cidrs 也会自动计算所有其他 Region 的 spoke CIDR。
══════════════════════════════════════════════════════════════════════════════════════

EOF
