locals {
  name_prefix = "${var.cp}-${var.env}-${var.region_name}"

  common_tags = {
    Environment = var.env
    Project     = "gwlb-cloudwan-apac"
    Terraform   = "true"
  }

  # ── Unpack var.region_config so the rest of the module keeps its flat names ────
  keypair                = var.region_config.keypair
  fortiflex_sn_primary   = var.region_config.fortiflex_sn_primary
  fortiflex_sn_secondary = var.region_config.fortiflex_sn_secondary

  sec_vpc_cidr          = var.region_config.sec_vpc_cidr
  sec_external_az1_cidr = var.region_config.sec_external_az1_cidr
  sec_external_az2_cidr = var.region_config.sec_external_az2_cidr
  sec_internal_az1_cidr = var.region_config.sec_internal_az1_cidr
  sec_internal_az2_cidr = var.region_config.sec_internal_az2_cidr
  sec_ha_az1_cidr       = var.region_config.sec_ha_az1_cidr
  sec_ha_az2_cidr       = var.region_config.sec_ha_az2_cidr
  sec_mgmt_az1_cidr     = var.region_config.sec_mgmt_az1_cidr
  sec_mgmt_az2_cidr     = var.region_config.sec_mgmt_az2_cidr
  sec_cwan_az1_cidr     = var.region_config.sec_cwan_az1_cidr
  sec_cwan_az2_cidr     = var.region_config.sec_cwan_az2_cidr
  sec_gwlbe_az1_cidr    = var.region_config.sec_gwlbe_az1_cidr
  sec_gwlbe_az2_cidr    = var.region_config.sec_gwlbe_az2_cidr

  spoke_a_vpc_cidr        = var.region_config.spoke_a_vpc_cidr
  spoke_a_subnet_az1_cidr = var.region_config.spoke_a_subnet_az1_cidr
  spoke_a_subnet_az2_cidr = var.region_config.spoke_a_subnet_az2_cidr
  spoke_b_vpc_cidr        = var.region_config.spoke_b_vpc_cidr
  spoke_b_subnet_az1_cidr = var.region_config.spoke_b_subnet_az1_cidr
  spoke_b_subnet_az2_cidr = var.region_config.spoke_b_subnet_az2_cidr
}

# ── Security VPC ────────────────────────────────────────────────────────────────
resource "aws_vpc" "sec" {
  cidr_block           = local.sec_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-vpc"
  })
}

resource "aws_internet_gateway" "sec" {
  vpc_id = aws_vpc.sec.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-igw"
  })
}

# ── External subnets (FortiGate port1 — public facing / mgmt) ──────────────────
resource "aws_subnet" "sec_external_az1" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_external_az1_cidr
  availability_zone = local.az1

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-external-az1"
  })
}

resource "aws_subnet" "sec_external_az2" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_external_az2_cidr
  availability_zone = local.az2

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-external-az2"
  })
}

# ── Internal subnets (FortiGate port2 — GWLB target, GENEVE) ───────────────────
resource "aws_subnet" "sec_internal_az1" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_internal_az1_cidr
  availability_zone = local.az1

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-internal-az1"
  })
}

resource "aws_subnet" "sec_internal_az2" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_internal_az2_cidr
  availability_zone = local.az2

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-internal-az2"
  })
}

# ── HA subnets (FortiGate port3 — HA heartbeat/sync) ───────────────────────────
resource "aws_subnet" "sec_ha_az1" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_ha_az1_cidr
  availability_zone = local.az1

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-ha-az1"
  })
}

resource "aws_subnet" "sec_ha_az2" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_ha_az2_cidr
  availability_zone = local.az2

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-ha-az2"
  })
}

# ── Management subnets (FortiGate port4 — dedicated management) ─────────────────
resource "aws_subnet" "sec_mgmt_az1" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_mgmt_az1_cidr
  availability_zone = local.az1

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-mgmt-az1"
  })
}

resource "aws_subnet" "sec_mgmt_az2" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_mgmt_az2_cidr
  availability_zone = local.az2

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-mgmt-az2"
  })
}

# ── Cloud WAN attachment subnets ────────────────────────────────────────────────
resource "aws_subnet" "sec_cwan_az1" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_cwan_az1_cidr
  availability_zone = local.az1

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-cwan-az1"
  })
}

resource "aws_subnet" "sec_cwan_az2" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_cwan_az2_cidr
  availability_zone = local.az2

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-cwan-az2"
  })
}

# ── GWLB Endpoint subnets ──────────────────────────────────────────────────────
resource "aws_subnet" "sec_gwlbe_az1" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_gwlbe_az1_cidr
  availability_zone = local.az1

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-gwlbe-az1"
  })
}

resource "aws_subnet" "sec_gwlbe_az2" {
  vpc_id            = aws_vpc.sec.id
  cidr_block        = local.sec_gwlbe_az2_cidr
  availability_zone = local.az2

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-gwlbe-az2"
  })
}

# ── Route tables ────────────────────────────────────────────────────────────────
#
# Routes are declared inline in the route table instead of as separate aws_route
# resources. Each aws_route is its own create/read round-trip that Terraform has
# to schedule after the table exists; folding them in removes those extra graph
# nodes and API calls. The internal and HA subnets previously had one empty route
# table each — they have identical (local-only) routing, so they now share one.

# Public route table — internet access via IGW (external + mgmt subnets)
resource "aws_route_table" "sec_public" {
  vpc_id = aws_vpc.sec.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sec.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-public-rt"
  })
}

# Private route table — internal (GWLB dataplane) + HA subnets.
# No default route: GENEVE traffic is local to the VPC and HA is heartbeat only.
resource "aws_route_table" "sec_private" {
  vpc_id = aws_vpc.sec.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-private-rt"
  })
}

# Cloud WAN subnet route table — 0.0.0.0/0 → GWLBE (traffic from Cloud WAN goes to GWLB for inspection)
resource "aws_route_table" "sec_cwan" {
  vpc_id = aws_vpc.sec.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.gwlbe_az1.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-cwan-rt"
  })
}

# GWLBE subnet route table — 0.0.0.0/0 → Cloud WAN (return traffic after inspection).
# The core-network default route itself is created in the root module
# (cloud_wan_routes.tf) because it must be ordered after this region's Cloud WAN
# VPC attachments, which are root-level resources.
resource "aws_route_table" "sec_gwlbe" {
  vpc_id = aws_vpc.sec.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sec-gwlbe-rt"
  })
}

# ── Route table associations ────────────────────────────────────────────────────
locals {
  sec_rt_associations = {
    external_az1 = { subnet_id = aws_subnet.sec_external_az1.id, route_table_id = aws_route_table.sec_public.id }
    external_az2 = { subnet_id = aws_subnet.sec_external_az2.id, route_table_id = aws_route_table.sec_public.id }
    mgmt_az1     = { subnet_id = aws_subnet.sec_mgmt_az1.id, route_table_id = aws_route_table.sec_public.id }
    mgmt_az2     = { subnet_id = aws_subnet.sec_mgmt_az2.id, route_table_id = aws_route_table.sec_public.id }
    internal_az1 = { subnet_id = aws_subnet.sec_internal_az1.id, route_table_id = aws_route_table.sec_private.id }
    internal_az2 = { subnet_id = aws_subnet.sec_internal_az2.id, route_table_id = aws_route_table.sec_private.id }
    ha_az1       = { subnet_id = aws_subnet.sec_ha_az1.id, route_table_id = aws_route_table.sec_private.id }
    ha_az2       = { subnet_id = aws_subnet.sec_ha_az2.id, route_table_id = aws_route_table.sec_private.id }
    cwan_az1     = { subnet_id = aws_subnet.sec_cwan_az1.id, route_table_id = aws_route_table.sec_cwan.id }
    cwan_az2     = { subnet_id = aws_subnet.sec_cwan_az2.id, route_table_id = aws_route_table.sec_cwan.id }
    gwlbe_az1    = { subnet_id = aws_subnet.sec_gwlbe_az1.id, route_table_id = aws_route_table.sec_gwlbe.id }
    gwlbe_az2    = { subnet_id = aws_subnet.sec_gwlbe_az2.id, route_table_id = aws_route_table.sec_gwlbe.id }
  }
}

resource "aws_route_table_association" "sec" {
  for_each = local.sec_rt_associations

  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id
}
