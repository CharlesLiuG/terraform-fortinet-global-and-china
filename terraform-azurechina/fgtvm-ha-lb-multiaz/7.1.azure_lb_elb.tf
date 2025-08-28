locals {
  elbName    = "ELB"
  eipElbName = "eip-elb"
}

resource "azurerm_public_ip" "eipElb" {
  name                = local.eipElbName
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  allocation_method   = "Static"
  sku                 = "Standard"
  # https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
  # zones = azurerm_virtual_network.vnetNgfw.location == "chinanorth3" ? [var.azPrimary, var.azSecondary] : []
}

resource "azurerm_lb" "elb" {
  name                = local.elbName
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = local.eipElbName
    public_ip_address_id = azurerm_public_ip.eipElb.id
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_lb_probe" "elbprobe" {
  loadbalancer_id = azurerm_lb.elb.id
  name            = "elbprobe"
  protocol        = "Tcp"
  port            = 8008
}

resource "azurerm_lb_rule" "elbRuleVpnIke" {
  loadbalancer_id                = azurerm_lb.elb.id
  name                           = "LBRule-VPN-IKE"
  protocol                       = "Udp"
  frontend_port                  = 500
  backend_port                   = 500
  frontend_ip_configuration_name = local.eipElbName
  disable_outbound_snat          = true
  probe_id                       = azurerm_lb_probe.elbprobe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.elbBackendAddrPool.id]
}

resource "azurerm_lb_rule" "elbRuleVpnNatt" {
  loadbalancer_id                = azurerm_lb.elb.id
  name                           = "LBRule-VPN-NATT"
  protocol                       = "Udp"
  frontend_port                  = 4500
  backend_port                   = 4500
  frontend_ip_configuration_name = local.eipElbName
  disable_outbound_snat          = true
  probe_id                       = azurerm_lb_probe.elbprobe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.elbBackendAddrPool.id]
}

resource "azurerm_lb_backend_address_pool" "elbBackendAddrPool" {
  loadbalancer_id = azurerm_lb.elb.id
  name            = "FGT-HA-Cluster"
}

resource "azurerm_network_interface_backend_address_pool_association" "eniFgt1WithElbBackendAddrPool" {
  network_interface_id    = azurerm_network_interface.eniFgt1Public.id
  ip_configuration_name   = local.ipAddrPublicFgt1Name
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbBackendAddrPool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "eniFgt2WithElbBackendAddrPool" {
  network_interface_id    = azurerm_network_interface.eniFgt2Public.id
  ip_configuration_name   = local.ipAddrPublicFgt2Name
  backend_address_pool_id = azurerm_lb_backend_address_pool.elbBackendAddrPool.id
}
