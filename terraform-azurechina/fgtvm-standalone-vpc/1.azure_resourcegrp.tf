resource "azurerm_resource_group" "resourceGrp" {
  name     = terraform.workspace == "default" ? var.resourceGrp : "${var.resourceGrp}-${terraform.workspace}"
  location = var.resourceGrpLocation

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
