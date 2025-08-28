locals {
  nameSgFTestPublic = "sg_ftest_public"
}

#################### Security Group ####################
resource "aws_security_group" "sgFTestPublic" {
  name        = local.nameSgFTestPublic
  description = local.nameSgFTestPublic
  vpc_id      = aws_vpc.vpcFTest.id

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
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = local.nameSgFTestPublic
    Terraform = true
    Project   = var.ProjectName
  }
}

