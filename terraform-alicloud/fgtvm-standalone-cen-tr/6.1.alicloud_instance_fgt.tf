locals {
  amiFgtvm64          = var.imageVersion == "fgtvm64" ? var.licenseType == "byol" ? var.amiFgtBYOL64[var.region1Name] : var.amiFgtPAYG64[var.region1Name] : ""
  amiFgtvm70          = var.imageVersion == "fgtvm70" ? var.licenseType == "byol" ? var.amiFgtBYOL70[var.region1Name] : var.amiFgtPAYG70[var.region1Name] : ""
  amiFgtvm72          = var.imageVersion == "fgtvm72" ? var.licenseType == "byol" ? var.amiFgtBYOL72[var.region1Name] : var.amiFgtPAYG72[var.region1Name] : ""
  nameInstanceFgtFull = terraform.workspace == "default" ? var.hostnameFgt : "${var.hostnameFgt}-${terraform.workspace}"
  nameInternalSrv     = "WEB-SRV" # <- Modifiable
}

data "alicloud_instance_types" "instanceTypeFgt" {
  # availability_zone    = var.region1Name == "cn-shanghai" ? "" : alicloud_vswitch.vswPublic.availability_zone
  network_type         = "Vpc"
  system_disk_category = var.region1Name == "cn-qingdao" ? "cloud_ssd" : "cloud_essd"
  instance_type_family = var.region1Name == "cn-qingdao" ? "ecs.c6" : "ecs.c6e"
  instance_charge_type = "PostPaid"
  cpu_core_count       = 2        # <- Modifiable [c6.2xlarge = 8 | c6e.xlarge = 4]
  memory_size          = 4        # <- Modifiable [c6.2xlarge = 16 | c6e.xlarge = 8]
  eni_amount           = 2        # <- Modifiable [4: c6.2xlarge | c6e.xlarge]
  spot_strategy        = "NoSpot" # <- Modifiable [NoSpot | SpotAsPriceGo]
}

resource "alicloud_instance" "fgtStandalone" {
  depends_on           = [alicloud_ecs_network_interface.eniFgtPrivate]
  instance_name        = local.nameInstanceFgtFull
  security_groups      = alicloud_security_group.sgFgtPublic.*.id
  image_id             = local.amiFgtvm64 == "" ? local.amiFgtvm70 == "" ? local.amiFgtvm72 : local.amiFgtvm70 : local.amiFgtvm64
  instance_type        = var.instanceTypeFgtDesignated != "" ? var.instanceTypeFgtDesignated : data.alicloud_instance_types.instanceTypeFgt.instance_types.0.id
  system_disk_category = data.alicloud_instance_types.instanceTypeFgt.system_disk_category
  system_disk_size     = 40
  vswitch_id           = alicloud_vswitch.vswPublic.id
  private_ip           = var.ipAddrPublicFgt
  instance_charge_type = data.alicloud_instance_types.instanceTypeFgt.instance_charge_type

  user_data = templatefile(var.instanceBootstrapFgt,
    {
      licenseType           = var.licenseType
      licenseFile           = var.licenseFile
      adminsPort            = var.adminsPort
      ipAddrPublic          = var.ipAddrPublicFgt
      ipAddrPrivate         = var.ipAddrPrivateFgt
      fgtConfPort1Gw        = cidrhost(var.cidrVswPublic, -3)
      fgtConfPort2Gw        = cidrhost(var.cidrVswPrivate, -3)
      fgtConfHostname       = local.nameInstanceFgtFull
      fgtConfPort1Mask      = cidrnetmask(var.cidrVswPublic)
      fgtConfPort2Mask      = cidrnetmask(var.cidrVswPrivate)
      fgtConfVipSrcAddr     = var.ipAddrFTestVpc2
      fgtConfVipSrvPort     = var.fgtConfVipSrvPort
      fgtConfVipExtPort     = var.fgtConfVipExtPort
      fgtConfVipName        = "VIP-${local.nameInternalSrv}-${var.ipAddrFTestVpc2}"
      fgtConfPolicyDNATName = "to-vip-${lower(local.nameInternalSrv)}"
      cidrVpc2              = var.cidrVpc2
      cidrVpc3              = var.cidrVpc3
      fwAddrNameVpc2        = "${var.vpc2Name}-${var.cidrVpc2}"
      fwAddrNameVpc3        = "${var.vpc3Name}-${var.cidrVpc3}"
    }
  )

  data_disks {
    size                 = 30
    category             = data.alicloud_instance_types.instanceTypeFgt.system_disk_category
    delete_with_instance = true
  }

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}
