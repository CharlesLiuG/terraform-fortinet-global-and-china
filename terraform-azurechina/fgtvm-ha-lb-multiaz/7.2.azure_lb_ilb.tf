locals {
  ilbName   = "ILB"
  ipIlbName = "ip-ilb"
}

resource "azurerm_lb" "ilb" {
  name                = local.ilbName
  resource_group_name = azurerm_resource_group.resourceGrp.name
  location            = azurerm_virtual_network.vnetNgfw.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = local.ipIlbName
    subnet_id                     = azurerm_subnet.subnetInternal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.privateIpAddr_ILB
    # https://docs.microsoft.com/en-us/azure/availability-zones/az-overview
    # zones = azurerm_virtual_network.vnetNgfw.location == "chinanorth3" ? [var.azPrimary, var.azSecondary] : []
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "azurerm_lb_probe" "ilbprobe" {
  loadbalancer_id = azurerm_lb.ilb.id
  name            = "ilbprobe"
  protocol        = "Tcp"
  port            = 8008
}

resource "azurerm_lb_rule" "ilbRulePassthrough" {
  loadbalancer_id                = azurerm_lb.ilb.id
  name                           = "LBRule-passthrough"
  frontend_ip_configuration_name = local.ipIlbName
  probe_id                       = azurerm_lb_probe.ilbprobe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.ilbBackendAddrPool.id]
  # a.k.a. 'HA Port'
  protocol      = "All"
  frontend_port = 0
  backend_port  = 0
}

resource "azurerm_lb_backend_address_pool" "ilbBackendAddrPool" {
  loadbalancer_id = azurerm_lb.ilb.id
  name            = "FGT-HA-Cluster"
}

resource "azurerm_network_interface_backend_address_pool_association" "eniFgt1WithIlbBackendAddrPool" {
  network_interface_id    = azurerm_network_interface.eniPrivateFgt1.id
  ip_configuration_name   = local.ipAddrPrivateFgt1Name
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilbBackendAddrPool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "eniFgt2WithIlbBackendAddrPool" {
  network_interface_id    = azurerm_network_interface.eniPrivateFgt2.id
  ip_configuration_name   = local.ipAddrPrivateFgt2Name
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilbBackendAddrPool.id
}
