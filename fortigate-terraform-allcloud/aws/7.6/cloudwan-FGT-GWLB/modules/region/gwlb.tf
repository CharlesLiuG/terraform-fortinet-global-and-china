# ─────────────────────────────────────────────────────────────────────────────────
# Gateway Load Balancer (GWLB) — FortiGate GENEVE Inspection
#
# Traffic flow:
#   Cloud WAN → cwan-subnet → GWLBE (gwlbe-subnet) → GWLB (internal-subnet)
#   → FortiGate port2 (GENEVE 6081) → GWLB → GWLBE → cwan-subnet → Cloud WAN
# ─────────────────────────────────────────────────────────────────────────────────

# ── Gateway Load Balancer ───────────────────────────────────────────────────────
resource "aws_lb" "gwlb" {
  name               = "${var.cp}-${var.env}-${var.region_name}-gwlb"
  load_balancer_type = "gateway"

  enable_cross_zone_load_balancing = true

  subnet_mapping {
    subnet_id = aws_subnet.sec_internal_az1.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.sec_internal_az2.id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-gwlb"
  })
}

# ── Target Group (GENEVE port 6081, health check on port 8008) ──────────────────
resource "aws_lb_target_group" "fgt" {
  name        = "${var.cp}-${var.env}-${var.region_name}-fgt-tg"
  port        = 6081
  protocol    = "GENEVE"
  target_type = "ip"
  vpc_id      = aws_vpc.sec.id

  health_check {
    port     = 8008
    protocol = "TCP"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-gwlb-tg"
  })
}

# ── Listener ────────────────────────────────────────────────────────────────────
resource "aws_lb_listener" "fgt" {
  load_balancer_arn = aws_lb.gwlb.arn

  default_action {
    target_group_arn = aws_lb_target_group.fgt.arn
    type             = "forward"
  }
}

# ── Target Group Attachments (both FortiGate port2 IPs) ─────────────────────────
resource "aws_lb_target_group_attachment" "fgt_primary" {
  target_group_arn = aws_lb_target_group.fgt.arn
  target_id        = local.primary_internal_ip
  port             = 6081

  depends_on = [aws_instance.fortigate_primary]
}

resource "aws_lb_target_group_attachment" "fgt_secondary" {
  target_group_arn = aws_lb_target_group.fgt.arn
  target_id        = local.secondary_internal_ip
  port             = 6081

  depends_on = [aws_instance.fortigate_secondary]
}

# ── GWLB Endpoint Service ──────────────────────────────────────────────────────
resource "aws_vpc_endpoint_service" "gwlb" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-gwlb-service"
  })
}

# ── GWLB Endpoints (one per AZ in gwlbe-subnet) ────────────────────────────────
resource "aws_vpc_endpoint" "gwlbe_az1" {
  service_name      = aws_vpc_endpoint_service.gwlb.service_name
  subnet_ids        = [aws_subnet.sec_gwlbe_az1.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.gwlb.service_type
  vpc_id            = aws_vpc.sec.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-gwlbe-az1"
  })
}

resource "aws_vpc_endpoint" "gwlbe_az2" {
  service_name      = aws_vpc_endpoint_service.gwlb.service_name
  subnet_ids        = [aws_subnet.sec_gwlbe_az2.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.gwlb.service_type
  vpc_id            = aws_vpc.sec.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-gwlbe-az2"
  })
}
