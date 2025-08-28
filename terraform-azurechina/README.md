# Fortinet-Azure

## NOTICES!!!
* FortiGate-VM automation is available for `Azure.China` and `Azure.Global`.  
* For FortiGate version deatils, please refer to `Distribution Release Note`!!!  
* Pay-as-you-go (`PAYG`) is NOT available in `Azure.China`.  

## INSTALL Azure CLI
[Azure Documentation for Installing Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows)

## INSTALL PowerShell 7
[Azure Documentation for Installing PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows)

## INSTALL Terraform for Windows
[Azure Documentation for Installing Terraform for Windows](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell?tabs=bash)

## Authenticating using the Azure CLI
[How to Authenticate via Azure CLI](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)  
``` sh
az cloud set --name AzureChinaCloud
az login
```
## QUERY image SKU/OFFER
``` sh
# FortiGate
## List all offers
az vm image list-offers --publisher fortinet-cn --location chinanorth2 -o table
## List all versions
az vm image list --all --publisher fortinet-cn --location chinanorth2 --offer fortinet_fortigate-vm_v7_2 --sku fortinet_fg-vm_7_2 -o table
Architecture    Offer                       Publisher    Sku                 Urn                                                              Version
--------------  --------------------------  -----------  ------------------  ---------------------------------------------------------------  ---------
x64             fortinet_fortigate-vm_v7_2  fortinet-cn  fortinet_fg-vm_7_2  fortinet-cn:fortinet_fortigate-vm_v7_2:fortinet_fg-vm_7_2:6.4.9  6.4.9
x64             fortinet_fortigate-vm_v7_2  fortinet-cn  fortinet_fg-vm_7_2  fortinet-cn:fortinet_fortigate-vm_v7_2:fortinet_fg-vm_7_2:7.0.6  7.0.6
x64             fortinet_fortigate-vm_v7_2  fortinet-cn  fortinet_fg-vm_7_2  fortinet-cn:fortinet_fortigate-vm_v7_2:fortinet_fg-vm_7_2:7.2.0  7.2.0

# Ubuntu Linux
az vm image list-offers --publisher Canonical --location chinanorth3 -o table
az vm image list-skus --publisher Canonical --location chinanorth3 --offer 0001-com-ubuntu-server-focal-daily -o table
az vm image list --all --publisher Canonical --location chinanorth3 --offer 0001-com-ubuntu-server-focal-daily --sku 20_04-daily-lts -o table
```

## Terraform configuration
[Terraform Registry Documentation for Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)  
* init  
`terraform init`

* plan  
MODIFY AS NEEDED > `terraform.tfvars`  
`terraform plan -out=tfplan`

* apply  
`terraform apply "tfplan"`

* destroy  
`terraform destroy`

* import  
``` sh
terraform import -input=false -var "adminPassword=****" azurerm_resource_group.resourceGrp /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegrp-ngfw
terraform import -input=false -var "adminPassword=****" azurerm_virtual_network.vnetNgfw /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegrp-ngfw/providers/Microsoft.Network/virtualNetworks/VNET-SECURITY
terraform import -input=false -var "adminPassword=****" azurerm_subnet.subnetPublic /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegrp-ngfw/providers/Microsoft.Network/virtualNetworks/VNET-SECURITY/subnets/subnet_public
terraform import -input=false -var "adminPassword=****" azurerm_subnet.subnetInternal /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegrp-ngfw/providers/Microsoft.Network/virtualNetworks/VNET-SECURITY/subnets/subnet_internal
terraform import -input=false -var "adminPassword=****" azurerm_network_security_group.nsgFgtPublic /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegrp-ngfw/providers/Microsoft.Network/networkSecurityGroups/nsg-fgt-public
terraform import -input=false -var "adminPassword=****" azurerm_network_security_group.nsgFgtInternal /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourcegrp-ngfw/providers/Microsoft.Network/networkSecurityGroups/nsg-fgt-internal
```

* destroy  
`terraform apply -destroy -var-file="variables.tfvars" -var "adminPassword=*****`

## Known Error
* PublicIPCountLimitReached  
```
╷
│ Error: creating/updating Public Ip Address: (Name "eip-fgt2-mgmt" / Resource Group "resourcegrp-LB-HA"): network.PublicIPAddressesClient#CreateOrUpdate: Failure sending request: StatusCode=400 -- Original Error: Code="PublicIPCountLimitReached" Message="Cannot create more than 10 public IP addresses for this subscription in this region." Details=[]
│
│   with azurerm_public_ip.eipFgt2Mgmt,
│   on 4.azure_public_ip.tf line 18, in resource "azurerm_public_ip" "eipFgt2Mgmt":
│   18: resource "azurerm_public_ip" "eipFgt2Mgmt" {
│
╵
```

## Terraformer CLI
[Terraformer for Azure](https://github.com/GoogleCloudPlatform/terraformer/blob/master/docs/azure.md)  