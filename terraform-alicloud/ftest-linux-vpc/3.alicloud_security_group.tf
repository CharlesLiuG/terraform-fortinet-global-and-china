locals {
  nameSgFgtPublic = "sg_ftest"
}

#################### Security Group of FTest ####################
resource "alicloud_security_group" "sgFTest" {
  name        = local.nameSgFgtPublic
  description = "FTest public facing security group"
  vpc_id      = alicloud_vpc.vpcFTest.id

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
  security_group_id = alicloud_security_group.sgFTest.id
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
  security_group_id = alicloud_security_group.sgFTest.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressHTTPS" {
  type              = "ingress"
  description       = "HTTPS"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 20
  security_group_id = alicloud_security_group.sgFTest.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressHTTP" {
  type              = "ingress"
  description       = "HTTP"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 30
  security_group_id = alicloud_security_group.sgFTest.id
  cidr_ip           = "0.0.0.0/0"
}


#### LDAP ####
resource "alicloud_security_group_rule" "sgRuleIngressLDAP" {
  type              = "ingress"
  description       = "LDAP"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "389/389"
  priority          = 40
  security_group_id = alicloud_security_group.sgFTest.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressLDAPssl" {
  type              = "ingress"
  description       = "LDAPssl"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "636/636"
  priority          = 41
  security_group_id = alicloud_security_group.sgFTest.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressLDAPadmin" {
  type              = "ingress"
  description       = "LDAPadmin"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "9830/9830"
  priority          = 42
  security_group_id = alicloud_security_group.sgFTest.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "sgRuleIngressShadowProxy" {
  type              = "ingress"
  description       = "LDAPadmin"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "44404/44405"
  priority          = 50
  security_group_id = alicloud_security_group.sgFTest.id
  cidr_ip           = "0.0.0.0/0"
}
