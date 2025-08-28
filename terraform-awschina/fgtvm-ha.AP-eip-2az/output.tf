#################### ID ####################
output "AZ1" {
  value = aws_subnet.subnetFgtPublicAz1.availability_zone
}

output "AZ2" {
  value = aws_subnet.subnetFgtPublicAz2.availability_zone
}

output "ID-VPC-NGFW" {
  value = var.isProvisionVpcNgfw == true ? aws_vpc.vpcNgfw[0].id : var.paramVpcCustomerId
}

output "ID-FGT1" {
  value = aws_instance.fgt1.id
}

output "ID-FGT2" {
  value = aws_instance.fgt2.id
}

#################### CIDR ####################
output "cidr-VPC-NGFW" {
  value = var.cidrVpcNgfw
}

output "cidr-subnet-fgt1-port1" {
  value = aws_subnet.subnetFgtPublicAz1.cidr_block
}

output "cidr-subnet-fgt1-port2" {
  value = aws_subnet.subnetFgtPrivateAz1.cidr_block
}

output "cidr-subnet-fgt1-port3" {
  value = aws_subnet.subnetFgtHAsyncAz1.cidr_block
}

output "cidr-subnet-fgt1-port4" {
  value = var.isProvision3PortsHA == true ? null : aws_subnet.subnetFgtMgmtAz1[0].cidr_block
}

output "cidr-subnet-fgt2-port1" {
  value = aws_subnet.subnetFgtPublicAz2.cidr_block
}

output "cidr-subnet-fgt2-port2" {
  value = aws_subnet.subnetFgtPrivateAz2.cidr_block
}

output "cidr-subnet-fgt2-port3" {
  value = aws_subnet.subnetFgtHAsyncAz2.cidr_block
}

output "cidr-subnet-fgt2-port4" {
  value = var.isProvision3PortsHA == true ? null : aws_subnet.subnetFgtMgmtAz2[0].cidr_block
}


#################### URLs ####################
output "url-fgt-cluster" {
  value = var.isProvisionFgtEips == true ? "https://${aws_eip.eipCluster[0].public_ip}:${var.portFgtHttps}" : "https://${data.aws_eip.eipIdClusterByData[0].public_ip}:${var.portFgtHttps}"
}

output "url-fgt-byol-az1" {
  value = var.isProvisionFgtEips == true ? "https://${aws_eip.eipFgtMgmtAz1[0].public_ip}:${var.portFgtHttps}" : "https://${data.aws_eip.eipIdFgtMgmtAz1ByData[0].public_ip}:${var.portFgtHttps}"
}

output "url-fgt-byol-az2" {
  value = var.isProvisionFgtEips == true ? "https://${aws_eip.eipFgtMgmtAz2[0].public_ip}:${var.portFgtHttps}" : "https://${data.aws_eip.eipIdFgtMgmtAz2ByData[0].public_ip}:${var.portFgtHttps}"
}


#################### FTest ####################
output "FTest-ID-SG" {
  value = var.isProvisionDnatWebSrv == true ? aws_security_group.sgFgtPrivate.id : null
}

output "FTest-ID-Subnet" {
  value = var.isProvisionDnatWebSrv == true ? aws_subnet.subnetFgtPrivateAz1.id : null
}

output "FTest-URL" {
  value = var.isProvisionDnatWebSrv == true ? var.isProvisionFgtEips == true ? "http://${aws_eip.eipCluster[0].public_ip}:${var.portFgtDnatWebsrvExt}" : "http://${data.aws_eip.eipIdClusterByData[0].public_ip}:${var.portFgtDnatWebsrvExt}" : null
}

output "FTest-IP-Private" {
  value = var.isProvisionDnatWebSrv == true ? var.ipAddrVipWebSrv : null
}
