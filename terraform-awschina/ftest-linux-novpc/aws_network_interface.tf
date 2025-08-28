locals {
  nameEniFTest = terraform.workspace == "default" ? "eni-ftest" : "eni-ftest-${terraform.workspace}"
}

resource "aws_network_interface" "eniFTestPublic" {
  description = local.nameEniFTest
  # subnet_id   = aws_subnet.subnetFTest.id
  subnet_id   = var.idSubnetFTest
  private_ips = [var.ipPrivateFTest]

  tags = {
    Name      = local.nameEniFTest
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "aws_network_interface_sg_attachment" "eniPublicFTestAttach" {
  depends_on = [aws_network_interface.eniFTestPublic]
  # security_group_id    = aws_security_group.sgFTest.id
  security_group_id    = var.idSecurityGroupFTest
  network_interface_id = aws_network_interface.eniFTestPublic.id
}
