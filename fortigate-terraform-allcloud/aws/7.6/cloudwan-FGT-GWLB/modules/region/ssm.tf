# ─────────────────────────────────────────────────────────────────────────────────
# SSM Session Manager — allows connecting to spoke test instances without SSH
#
# The IAM role/profile is always created (it costs nothing and takes ~1s), but the
# 6 interface VPC endpoints are gated behind var.enable_ssm_endpoints. Each
# interface endpoint takes 2-4 minutes to become available, and with 3 endpoints
# per spoke VPC × 2 spokes × 2 regions that was 12 endpoints on the critical path
# of every apply — for a convenience feature on two t3.micro test boxes.
#
# Set enable_ssm_endpoints = true when you actually need Session Manager access.
# ─────────────────────────────────────────────────────────────────────────────────

locals {
  ssm_endpoint_count = var.enable_ssm_endpoints ? 1 : 0

  # ssm, ssmmessages and ec2messages are all required for a Session Manager
  # session to establish over a private endpoint.
  ssm_endpoint_services = ["ssm", "ssmmessages", "ec2messages"]

  spoke_ssm_endpoints = var.enable_ssm_endpoints ? {
    for pair in setproduct(["a", "b"], local.ssm_endpoint_services) :
    "${pair[0]}-${pair[1]}" => {
      spoke   = pair[0]
      service = pair[1]
    }
  } : {}

  spoke_vpc_ids = {
    for key in keys(local.spokes) : key => aws_vpc.spoke[key].id
  }

  spoke_endpoint_subnet_ids = {
    for key in keys(local.spokes) : key => aws_subnet.spoke["${key}-az1"].id
  }

  spoke_endpoint_cidrs = {
    for key, cfg in local.spokes : key => cfg.vpc_cidr
  }
}

# ── IAM Role for SSM ────────────────────────────────────────────────────────────
resource "aws_iam_role" "ssm" {
  name = "${local.name_prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ssm-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${local.name_prefix}-ssm-profile"
  role = aws_iam_role.ssm.name

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ssm-profile"
  })
}

# ── Security groups for the SSM endpoints (one per spoke VPC) ───────────────────
resource "aws_security_group" "ssm_vpce" {
  for_each = var.enable_ssm_endpoints ? local.spoke_vpc_ids : {}

  name        = "${local.name_prefix}-spoke-${each.key}-ssm-vpce-sg"
  description = "Allow HTTPS from spoke ${upper(each.key)} VPC to SSM endpoints"
  vpc_id      = each.value

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.spoke_endpoint_cidrs[each.key]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-spoke-${each.key}-ssm-vpce-sg"
  })
}

# ── Interface VPC Endpoints — 3 services × 2 spoke VPCs ────────────────────────
resource "aws_vpc_endpoint" "spoke_ssm" {
  for_each = local.spoke_ssm_endpoints

  vpc_id              = local.spoke_vpc_ids[each.value.spoke]
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value.service}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [local.spoke_endpoint_subnet_ids[each.value.spoke]]
  security_group_ids  = [aws_security_group.ssm_vpce[each.value.spoke].id]
  private_dns_enabled = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-spoke-${each.value.spoke}-${each.value.service}-vpce"
  })
}
