#################### ID ####################
output "AZ-FGT-Standalone" {
  value = aws_subnet.subnetFgtPublicAz1.availability_zone
}

output "ID-VPC-NGFW" {
  value = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
}

output "ID-FGT-Standalone" {
  value = aws_instance.fgtStandalone.id
}

#################### CIDR ####################
output "cidr-subnet-fgt-port1" {
  value = aws_subnet.subnetFgtPublicAz1.cidr_block
}

output "cidr-subnet-fgt-port2" {
  value = aws_subnet.subnetFgtPrivateAz1.cidr_block
}

#################### IP Public ####################
output "url-fgt-az1" {
  value = "https://${aws_eip.eipFgtPublicAz1.public_ip}:${var.portFgtHttps}"
}

#################### FTest ####################
output "url-ftest" {
  value = var.isProvisionDnatWebSrv == true ? "http://${aws_eip.eipFgtPublicAz1.public_ip}:${var.portFgtDnatWebsrvExt}" : null
}
