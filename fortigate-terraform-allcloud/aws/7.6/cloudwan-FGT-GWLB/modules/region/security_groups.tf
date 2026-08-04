resource "aws_security_group" "fgt_external" {
  name        = "${local.name_prefix}-fgt-external-sg"
  description = "FortiGate port1 (external) - allow all (FortiGate enforces policy)"
  vpc_id      = aws_vpc.sec.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-external-sg"
  })
}

resource "aws_security_group" "fgt_internal" {
  name        = "${local.name_prefix}-fgt-internal-sg"
  description = "FortiGate port2 (internal) - allow all from VPC and Cloud WAN"
  vpc_id      = aws_vpc.sec.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-internal-sg"
  })
}

resource "aws_security_group" "fgt_ha" {
  name        = "${local.name_prefix}-fgt-ha-sg"
  description = "FortiGate port3 (HA heartbeat/sync)"
  vpc_id      = aws_vpc.sec.id

  # HA heartbeat
  ingress {
    from_port   = 703
    to_port     = 703
    protocol    = "udp"
    cidr_blocks = [local.sec_vpc_cidr]
  }

  # HA sync (session)
  ingress {
    from_port   = 702
    to_port     = 702
    protocol    = "tcp"
    cidr_blocks = [local.sec_vpc_cidr]
  }

  # HA sync (config) - FGSP config-sync uses TCP 703
  ingress {
    from_port   = 703
    to_port     = 703
    protocol    = "tcp"
    cidr_blocks = [local.sec_vpc_cidr]
  }

  # ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.sec_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-ha-sg"
  })
}

resource "aws_security_group" "fgt_mgmt" {
  name        = "${local.name_prefix}-fgt-mgmt-sg"
  description = "FortiGate port4 (management) - HTTPS, SSH, FGFM"
  vpc_id      = aws_vpc.sec.id

  # HTTPS management
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # FGFM (FortiManager)
  ingress {
    from_port   = 541
    to_port     = 541
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-fgt-mgmt-sg"
  })
}
