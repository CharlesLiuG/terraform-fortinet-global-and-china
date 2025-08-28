#################### ID ####################
output "AZ-ResourceGrp" {
  value = azurerm_resource_group.resourceGrp.location
}

output "ID-VPC-NGFW" {
  value = azurerm_virtual_network.vnetNgfw.id
}

output "ID-FGT-Standalone" {
  value = azurerm_linux_virtual_machine.fgtStandalone.id
}

output "AZ-FGT-Standalone" {
  value = azurerm_virtual_network.vnetNgfw.location
}

#################### CIDR ####################
output "cidr-subnet-fgt-port1" {
  value = azurerm_subnet.subnetPublic.address_prefixes
}

output "cidr-subnet-fgt-port2" {
  value = azurerm_subnet.subnetPrivate.address_prefixes
}


#################### IP Public ####################
output "EIP-FGT" {
  value = azurerm_public_ip.eipFgt.ip_address
}


#################### FTest ####################
output "FTest-ID-SG" {
  value = ""
}

output "FTest-ID-Subnet" {
  value = ""
}

output "FTest-IP-Private" {
  value = var.fgtConfVipSrcAddr
}

output "FTest-VIP-TCP-Port" {
  value = var.fgtConfVipExtPort
}
