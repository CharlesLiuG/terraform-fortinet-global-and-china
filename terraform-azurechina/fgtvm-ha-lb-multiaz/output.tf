#################### Resource Group ####################
output "resourceGrpName" {
  value = azurerm_resource_group.resourceGrp.name
}

output "resourceGrpLocation" {
  value = azurerm_resource_group.resourceGrp.location
}

output "vnetLocation" {
  value = azurerm_virtual_network.vnetNgfw.location
}

##################### FGT ####################
output "IP-Private-FGT1" {
  value = azurerm_linux_virtual_machine.fgt1.private_ip_addresses
}

# output "IP-Pub-FGT1-port1" {
#   value = azurerm_public_ip.eipFgt1.ip_address
# }

output "IP-Pub-FGT1-Mgmt" {
  value = azurerm_public_ip.eipFgt1Mgmt.ip_address
}

output "IP-Private-FGT2" {
  value = azurerm_linux_virtual_machine.fgt2.private_ip_addresses
}

# output "IP-Pub-FGT2-port1" {
#   value = azurerm_public_ip.eipFgt2.ip_address
# }

output "IP-Pub-FGT2-Mgmt" {
  value = azurerm_public_ip.eipFgt2Mgmt.ip_address
}

##################### ELB ####################
output "IP-Pub-ELB" {
  value = azurerm_public_ip.eipElb.ip_address
}

##################### ILB ####################
output "IP-Private-ILB" {
  value = azurerm_lb.ilb.frontend_ip_configuration[0].private_ip_address
}
