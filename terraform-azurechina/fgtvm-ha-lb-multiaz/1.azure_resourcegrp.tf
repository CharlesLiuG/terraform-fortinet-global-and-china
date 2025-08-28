resource "azurerm_resource_group" "resourceGrp" {
  name     = var.resourceGrp
  location = var.resourceGrpLocation

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
