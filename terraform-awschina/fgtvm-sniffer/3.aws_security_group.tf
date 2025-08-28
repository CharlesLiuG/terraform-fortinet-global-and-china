locals {
  nameSgFgtPublic  = "sg_fgt_public"
  nameSgFgtPrivate = "sg_fgt_private"
}

#################### FortiGate Public [port1] ####################
resource "aws_security_group" "sgFgtPublic" {
  name        = local.nameSgFgtPublic
  description = "FortiGate public facing security group"
  vpc_id      = var.isProvisionVpcSniffer == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "FGTHTTPS"
    from_port   = var.portFgtHttps
    to_port     = var.portFgtHttps
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = local.nameSgFgtPublic
    Terraform = true
    Project   = var.ProjectName
  }
}


#################### FortiGate Private [port2] ####################
resource "aws_security_group" "sgFgtPrivate" {
  name        = local.nameSgFgtPrivate
  description = "FortiGate Private facing security group"
  vpc_id      = var.isProvisionVpcSniffer == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = local.nameSgFgtPrivate
    Terraform = true
    Project   = var.ProjectName
  }
}
