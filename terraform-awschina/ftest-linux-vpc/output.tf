#################### ID ####################
output "AZ-FTest" {
  value = aws_subnet.subnetFTestAz1.availability_zone
}

output "ID-VPC-NGFW" {
  value = aws_vpc.vpcFTest.id
}

output "ID-VPC-IGW" {
  value = aws_internet_gateway.vpcFTestIgw.id
}

output "ID-FTest" {
  value = aws_instance.ftestLinux.id
}

output "ID-Subnet-FTest" {
  value = aws_subnet.subnetFTestAz1.id
}

output "ID-SG-FTest" {
  value = aws_security_group.sgFTestPublic.id
}

#################### CIDR ####################
output "cidr-vpc-ftest" {
  value = var.cidrVpcFTest
}

output "cidr-subnet-ftest-az1" {
  value = aws_subnet.subnetFTestAz1.cidr_block
}

output "cidr-subnet-natgw-az1" {
  value = var.isProvisionNatgw == true ? aws_subnet.subnetNatgwAz1[0].cidr_block : null
}

output "cidr-subnet-nlb-az1" {
  value = var.isProvisionLb == true ? aws_subnet.subnetLbAz1[0].cidr_block : null
}

#################### FTest ####################
output "ssh-ftest" {
  value = var.isProvisionNatgw == true ? null : "ssh -i ~/.ssh/kpc_linux.pem ubuntu@${aws_eip.eipFTest[0].public_ip}"
}

output "url-ftest" {
  value = var.isProvisionLb == true ? "http://${aws_eip.eipNlbPublicAz1[0].public_ip}:${local.targetGrpHealthCheckPort}" : null
}
