locals {
  nameSubnetLbAz1          = "subnet-nlb-public-az1"
  nameNlbPublic            = "nlb-public"
  nameEipNlbPublicAz1      = "eip-nlb-public-az1"
  nameRtbNlbPublic         = "rtb-nlb-public"
  targetGrpHealthCheckPort = "80"
}


#################### Subnet ####################
resource "aws_subnet" "subnetLbAz1" {
  count = var.isProvisionLb == true ? 1 : 0

  vpc_id            = aws_vpc.vpcFTest.id
  cidr_block        = var.cidrSubnetLbAz1
  availability_zone = var.azFtnt1

  tags = {
    Name      = local.nameSubnetLbAz1
    Terraform = true
    Project   = var.ProjectName
  }
}


#################### NLB-Public EIP ####################
resource "aws_eip" "eipNlbPublicAz1" {
  count = var.isProvisionLb == true ? 1 : 0

  vpc = true

  tags = {
    Name      = local.nameEipNlbPublicAz1
    Terraform = true
    Project   = var.ProjectName
  }
}


#################### NLB-Public ####################
resource "aws_lb" "nlbPublic" {
  count = var.isProvisionLb == true ? 1 : 0

  name               = local.nameNlbPublic
  load_balancer_type = "network"

  # If there is DNS load balancer present, 
  # and it's capable of health check,
  # then there is no need for nlb to load balance across zones.
  enable_cross_zone_load_balancing = false
  # enable_cross_zone_load_balancing = true

  subnet_mapping {
    subnet_id     = aws_subnet.subnetLbAz1[0].id
    allocation_id = aws_eip.eipNlbPublicAz1[0].id
  }

  tags = {
    Name      = local.nameNlbPublic
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_lb_target_group" "targetGrpNlbPublic" {
  for_each = {
    for key, value in var.portsListenerNlbPublic : key => value
    if var.isProvisionLb
  }

  name               = "${local.nameNlbPublic}-target-${each.key}"
  port               = each.key
  protocol           = each.value
  target_type        = "instance"
  vpc_id             = aws_vpc.vpcFTest.id
  preserve_client_ip = true

  health_check {
    interval = 30
    protocol = each.value
    port     = local.targetGrpHealthCheckPort
  }
}

resource "aws_lb_listener" "listenerNlbPublic" {
  for_each = {
    for key, value in var.portsListenerNlbPublic : key => value
    if var.isProvisionLb
  }

  load_balancer_arn = aws_lb.nlbPublic[0].arn

  port     = each.key
  protocol = each.value

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetGrpNlbPublic[each.key].arn
  }
}

resource "aws_lb_target_group_attachment" "targetGrpNlbPublicAttachAz1" {
  for_each = {
    for key, value in var.portsListenerNlbPublic : key => value
    if var.isProvisionLb
  }

  depends_on       = [aws_lb_target_group.targetGrpNlbPublic]
  target_group_arn = aws_lb_target_group.targetGrpNlbPublic[each.key].arn
  target_id        = aws_instance.ftestLinux.id
}


#################### RouteTable ####################
resource "aws_route_table" "rtbNlbPublic" {
  count = var.isProvisionLb == true ? 1 : 0

  vpc_id = aws_vpc.vpcFTest.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpcFTestIgw.id
  }

  tags = {
    Name      = local.nameRtbNlbPublic
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_route_table_association" "rtbNlbPublicAssocSubnetLbAz1" {
  count = var.isProvisionLb == true ? 1 : 0

  subnet_id      = aws_subnet.subnetLbAz1[0].id
  route_table_id = aws_route_table.rtbNlbPublic[0].id
}
