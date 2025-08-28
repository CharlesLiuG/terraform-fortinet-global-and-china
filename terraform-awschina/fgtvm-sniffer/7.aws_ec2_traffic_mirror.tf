locals {
  nameTrafficMirrorFilter            = "sniffer-filter-fgt"
  nameTrafficMirrorTarget            = "sniffer-target-fgt"
  descTrafficMirrorFilter            = "sniffer filter - ${var.ProjectName}"
  descTrafficMirrorFilterRuleEgress  = "sniffer rule: egress"
  descTrafficMirrorFilterRuleIngress = "sniffer rule: ingress"
  descTrafficMirrorTarget            = "sniffer target: FortiGate-VM"
}

resource "aws_ec2_traffic_mirror_filter" "trafficMirrorFilter" {
  depends_on = [aws_instance.fgtStandalone]

  description      = local.descTrafficMirrorFilter
  network_services = ["amazon-dns"]

  tags = {
    Name      = local.nameTrafficMirrorFilter
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_ec2_traffic_mirror_filter_rule" "trafficMirrorFilterRuleEgress" {
  description              = local.descTrafficMirrorFilterRuleEgress
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.trafficMirrorFilter.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "egress"
}

resource "aws_ec2_traffic_mirror_filter_rule" "trafficMirrorFilterRuleIngress" {
  description              = local.descTrafficMirrorFilterRuleIngress
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.trafficMirrorFilter.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "ingress"
}

resource "aws_ec2_traffic_mirror_target" "trafficMirrorTarget" {
  depends_on = [
    aws_instance.fgtStandalone,
    aws_network_interface.eniFgtPrivateAz1
  ]

  description          = local.descTrafficMirrorTarget
  network_interface_id = aws_network_interface.eniFgtPrivateAz1.id

  tags = {
    Name      = local.nameTrafficMirrorTarget
    Terraform = true
    Project   = var.ProjectName
  }
}
