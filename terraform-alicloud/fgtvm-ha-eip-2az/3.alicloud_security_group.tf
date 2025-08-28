locals {
  nameSgFgtPublic  = "sg_fgt_public"
  nameSgFgtPrivate = "sg_fgt_private"
  nameSgFgtHAMgmt  = "sg_fgt_hamgmt"
}


#################### Security Group of FortiGate Public Interface [port1] ####################
resource "alicloud_security_group" "sgFgtPublic" {
  name        = local.nameSgFgtPublic
  description = "FortiGate public facing security group"
  vpc_id      = alicloud_vpc.vpcNgfw.id

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_security_group_rule" "sgRuleIngressICMP" {
  type              = "ingress"
  description       = "ICMP"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.sgFgtPublic.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressSSH" {
  type              = "ingress"
  description       = "SSH"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 10
  security_group_id = alicloud_security_group.sgFgtPublic.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressFGTHTTPS" {
  type              = "ingress"
  description       = "FGTHTTPS"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "${var.adminsPort}/${var.adminsPort}"
  priority          = 20
  security_group_id = alicloud_security_group.sgFgtPublic.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressVIP" {
  type              = "ingress"
  description       = "FGT-VIP"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "${var.fgtConfVipExtPort}/${var.fgtConfVipExtPort}"
  priority          = 25
  security_group_id = alicloud_security_group.sgFgtPublic.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressVPNIKE" {
  type              = "ingress"
  description       = "VPN-IKE"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "500/500"
  priority          = 30
  security_group_id = alicloud_security_group.sgFgtPublic.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressVPNNATT" {
  type              = "ingress"
  description       = "VPN-NATT"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "4500/4500"
  priority          = 40
  security_group_id = alicloud_security_group.sgFgtPublic.id
  cidr_ip           = "0.0.0.0/0"
}



#################### Security Group of FortiGate Private Interface [port2] ####################
resource "alicloud_security_group" "sgFgtPrivate" {
  name        = local.nameSgFgtPrivate
  description = "FortiGate Private facing security group"
  vpc_id      = alicloud_vpc.vpcNgfw.id

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_security_group_rule" "sgRuleIngressALL" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.sgFgtPrivate.id
  cidr_ip           = "0.0.0.0/0"
}


resource "alicloud_security_group_rule" "sgRuleEgressALL" {
  type              = "egress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.sgFgtPrivate.id
  cidr_ip           = "0.0.0.0/0"
}



#################### Security Group of FortiGate HAsync & Mgmt Interface [port3&4] ####################
resource "alicloud_security_group" "sgFgtHAMgmt" {
  name        = local.nameSgFgtHAMgmt
  description = "FortiGate HA & Mgmt facing security group"
  vpc_id      = alicloud_vpc.vpcNgfw.id

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_security_group_rule" "sgRuleIngressMgmtICMP" {
  type              = "ingress"
  description       = "ICMP"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.sgFgtHAMgmt.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressMgmtSSH" {
  type              = "ingress"
  description       = "SSH"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 10
  security_group_id = alicloud_security_group.sgFgtHAMgmt.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressMgmtHTTPS" {
  type              = "ingress"
  description       = "HTTPS"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 20
  security_group_id = alicloud_security_group.sgFgtHAMgmt.id
  cidr_ip           = "0.0.0.0/0"
}
