resource "alicloud_instance" "fgt2" {
  depends_on           = [alicloud_ecs_network_interface.eniPrivateFgt2, alicloud_ecs_network_interface.eniHAsyncFgt2, alicloud_ecs_network_interface.eniMgmtFgt2]
  instance_name        = local.nameInstanceFgt2Full
  security_groups      = alicloud_security_group.sgFgtPublic.*.id
  image_id             = local.amiFgtvm64 == "" ? local.amiFgtvm70 == "" ? local.amiFgtvm72 : local.amiFgtvm70 : local.amiFgtvm64
  instance_type        = var.instanceTypeFgtDesignated != "" ? var.instanceTypeFgtDesignated : data.alicloud_instance_types.instanceTypeFgt.instance_types.0.id
  system_disk_category = data.alicloud_instance_types.instanceTypeFgt.system_disk_category
  system_disk_size     = 40
  vswitch_id           = alicloud_vswitch.vswPublicFgt2.id
  private_ip           = var.ipAddrPublicFgt2
  instance_charge_type = data.alicloud_instance_types.instanceTypeFgt.instance_charge_type

  user_data = templatefile(var.instanceBootstrapFgt2,
    {
      licenseType      = var.licenseType
      licenseFile      = var.license2File
      adminsPort       = var.adminsPort
      cidrDestination  = var.cidrVswPrivateFgt2
      ipAddrPublic     = var.ipAddrPublicFgt2
      ipMaskPublic     = cidrnetmask(var.cidrVswPublicFgt2)
      ipAddrPrivate    = var.ipAddrPrivateFgt2
      ipMaskPrivate    = cidrnetmask(var.cidrVswPrivateFgt2)
      ipAddrHAsync     = var.ipAddrHAsyncFgt2
      ipMaskHAsync     = cidrnetmask(var.cidrVswHAsyncFgt2)
      ipAddrHAsyncPeer = var.ipAddrHAsyncFgt1
      ipAddrMgmt       = var.ipAddrMgmtFgt2
      ipMaskMgmt       = cidrnetmask(var.cidrVswMgmtFgt2)
      fgtConfPort1Gw   = cidrhost(var.cidrVswPublicFgt2, -3)
      fgtConfPort2Gw   = cidrhost(var.cidrVswPrivateFgt2, -3)
      fgtConfPort4Gw   = cidrhost(var.cidrVswMgmtFgt2, -3)
      fgtConfHostname  = local.nameInstanceFgt2Full
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
