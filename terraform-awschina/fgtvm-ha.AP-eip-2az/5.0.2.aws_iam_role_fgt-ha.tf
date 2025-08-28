locals {
  idVpcNgfw        = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
  nameIamRoleFgtHA = "FGT-HA-${substr(local.idVpcNgfw, -8, -1)}"
}

resource "aws_iam_instance_profile" "iamInstanceProfileFgtHA" {
  name = "${local.nameIamRoleFgtHA}-instance-profile"
  role = aws_iam_role.iamRoleFgtHA.name

  tags = {
    Name      = "${local.nameIamRoleFgtHA}-instance-profile"
    Terraform = true
    Project   = var.ProjectName
  }
}


resource "aws_iam_role" "iamRoleFgtHA" {
  name               = local.nameIamRoleFgtHA
  path               = "/"
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com.cn"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  inline_policy {
    name = "${local.nameIamRoleFgtHA}-inline-policy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "ec2:Describe*",
            "ec2:AssociateAddress",
            "ec2:AssignPrivateIpAddresses",
            "ec2:UnassignPrivateIpAddresses",
            "ec2:ReplaceRoute"
          ],
          "Resource" : "*",
          "Effect" : "Allow"
        }
      ]
    })
  }

  tags = {
    Name      = local.nameIamRoleFgtHA
    Terraform = true
    Project   = var.ProjectName
  }
}
