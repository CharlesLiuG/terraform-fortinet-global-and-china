# ─────────────────────────────────────────────────────────────────────────────────
# Spoke VPCs
#
# Spoke A and Spoke B are structurally identical, so they are driven by a single
# for_each over local.spokes instead of two hand-copied blocks. Default routes are
# declared inline in the route table rather than as separate aws_route resources,
# which removes 2 extra graph nodes and API round-trips per region.
# ─────────────────────────────────────────────────────────────────────────────────

locals {
  spokes = {
    a = {
      vpc_cidr        = local.spoke_a_vpc_cidr
      subnet_az1_cidr = local.spoke_a_subnet_az1_cidr
      subnet_az2_cidr = local.spoke_a_subnet_az2_cidr
    }
    b = {
      vpc_cidr        = local.spoke_b_vpc_cidr
      subnet_az1_cidr = local.spoke_b_subnet_az1_cidr
      subnet_az2_cidr = local.spoke_b_subnet_az2_cidr
    }
  }

  # Flattened {spoke, az} pairs for the per-AZ subnets and their associations.
  spoke_subnets = merge([
    for key, cfg in local.spokes : {
      "${key}-az1" = { spoke = key, az = local.az1, cidr = cfg.subnet_az1_cidr, az_label = "az1" }
      "${key}-az2" = { spoke = key, az = local.az2, cidr = cfg.subnet_az2_cidr, az_label = "az2" }
    }
  ]...)
}

resource "aws_vpc" "spoke" {
  for_each = local.spokes

  cidr_block           = each.value.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-spoke-${each.key}-vpc"
  })
}

resource "aws_subnet" "spoke" {
  for_each = local.spoke_subnets

  vpc_id            = aws_vpc.spoke[each.value.spoke].id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-spoke-${each.value.spoke}-subnet-${each.value.az_label}"
  })
}

# Route tables for the spokes. The 0.0.0.0/0 → Cloud WAN route is created in the
# root module (cloud_wan_routes.tf) so it can depend directly on this region's
# VPC attachments; the AWS provider does not accept a core-network route until
# the attachment is AVAILABLE.
resource "aws_route_table" "spoke" {
  for_each = local.spokes

  vpc_id = aws_vpc.spoke[each.key].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-spoke-${each.key}-rt"
  })
}

resource "aws_route_table_association" "spoke" {
  for_each = local.spoke_subnets

  subnet_id      = aws_subnet.spoke[each.key].id
  route_table_id = aws_route_table.spoke[each.value.spoke].id
}

# ── Security groups for spoke test instances ────────────────────────────────────
resource "aws_security_group" "spoke_test" {
  for_each = local.spokes

  name        = "${local.name_prefix}-spoke-${each.key}-test-sg"
  description = "Allow ICMP and SSH for connectivity testing"
  vpc_id      = aws_vpc.spoke[each.key].id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-spoke-${each.key}-test-sg"
  })
}

# ── Test instances (AZ1 of each spoke) ─────────────────────────────────────────
resource "aws_instance" "spoke_test" {
  for_each = local.spokes

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.spoke["${each.key}-az1"].id
  vpc_security_group_ids = [aws_security_group.spoke_test[each.key].id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name
  key_name               = local.keypair

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-spoke-${each.key}-test"
  })
}
