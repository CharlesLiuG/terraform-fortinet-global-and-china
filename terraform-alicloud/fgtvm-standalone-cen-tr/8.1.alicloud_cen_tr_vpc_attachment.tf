locals {
  # VPC1, by default, is 'VPC-NGFW' ${var.vpc1Name}
  centrLandingVpc1VswMasterName = "vswTRLanding1_${lower(var.vpc1Name)}"
  centrLandingVpc1VswSlaveName  = "vswTRLanding2_${lower(var.vpc1Name)}"
  centrLandingVpc2VswMasterName = "vswTRLanding1_${lower(var.vpc2Name)}"
  centrLandingVpc2VswSlaveName  = "vswTRLanding2_${lower(var.vpc2Name)}"
  centrLandingVpc3VswMasterName = "vswTRLanding1_${lower(var.vpc3Name)}"
  centrLandingVpc3VswSlaveName  = "vswTRLanding2_${lower(var.vpc3Name)}"
}

data "alicloud_cen_transit_router_available_resources" "centrLandingVsw" {

}


#################### [VPC1] CEN-TR-Landing-VSW + CEN-TR-VPC-ATTACHMENT ####################
resource "alicloud_vswitch" "vswTRLanding1Vpc1" {
  vswitch_name = local.centrLandingVpc1VswMasterName
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswTRLanding1Vpc1
  zone_id      = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswTRLanding2Vpc1" {
  vswitch_name = local.centrLandingVpc1VswSlaveName
  vpc_id       = alicloud_vpc.vpcNgfw.id
  cidr_block   = var.cidrVswTRLanding2Vpc1
  zone_id      = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_cen_transit_router_vpc_attachment" "centrVpc1Attachment" {
  ## LAB PROVED ONLY, NO terraform/help.aliyun.com DOCS SUPPORT.
  ## ecs instance creation, including network interface (eni) and eip association seems to
  ## lock vpc resources, therefore, resulting in cen-tr vpc attachment failure.
  # The following 'depends_on' will try to manually resolve the above issue.
  # eip associationg is the last activity related to vpc resource locking.
  depends_on        = [alicloud_eip_association.eipFgtAssociate]
  cen_id            = alicloud_cen_instance.cenInstance.id
  transit_router_id = alicloud_cen_transit_router.trRegion1.transit_router_id
  vpc_id            = alicloud_vpc.vpcNgfw.id
  zone_mappings {
    zone_id    = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
    vswitch_id = alicloud_vswitch.vswTRLanding1Vpc1.id
  }
  zone_mappings {
    zone_id    = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]
    vswitch_id = alicloud_vswitch.vswTRLanding2Vpc1.id
  }
  transit_router_attachment_name        = "TR-TO-${upper(var.vpc1Name)}"
  transit_router_attachment_description = "TR-TO-${upper(var.vpc1Name)}"
}


#################### [VPC2] CEN-TR-Landing-VSW + CEN-TR-VPC-ATTACHMENT ####################
resource "alicloud_vswitch" "vswTRLanding1Vpc2" {
  vswitch_name = local.centrLandingVpc2VswMasterName
  vpc_id       = alicloud_vpc.vpc2.id
  cidr_block   = var.cidrVswTRLanding1Vpc2
  zone_id      = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswTRLanding2Vpc2" {
  vswitch_name = local.centrLandingVpc2VswSlaveName
  vpc_id       = alicloud_vpc.vpc2.id
  cidr_block   = var.cidrVswTRLanding2Vpc2
  zone_id      = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_cen_transit_router_vpc_attachment" "centrVpc2Attachment" {
  depends_on        = [alicloud_instance.ftestLinux2]
  cen_id            = alicloud_cen_instance.cenInstance.id
  transit_router_id = alicloud_cen_transit_router.trRegion1.transit_router_id
  vpc_id            = alicloud_vpc.vpc2.id
  zone_mappings {
    zone_id    = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
    vswitch_id = alicloud_vswitch.vswTRLanding1Vpc2.id
  }
  zone_mappings {
    zone_id    = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]
    vswitch_id = alicloud_vswitch.vswTRLanding2Vpc2.id
  }
  transit_router_attachment_name        = "TR-TO-${upper(var.vpc2Name)}"
  transit_router_attachment_description = "TR-TO-${upper(var.vpc2Name)}"
}


#################### [VPC3] CEN-TR-Landing-VSW + CEN-TR-VPC-ATTACHMENT ####################
resource "alicloud_vswitch" "vswTRLanding1Vpc3" {
  vswitch_name = local.centrLandingVpc3VswMasterName
  vpc_id       = alicloud_vpc.vpc3.id
  cidr_block   = var.cidrVswTRLanding1Vpc3
  zone_id      = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_vswitch" "vswTRLanding2Vpc3" {
  vswitch_name = local.centrLandingVpc3VswSlaveName
  vpc_id       = alicloud_vpc.vpc3.id
  cidr_block   = var.cidrVswTRLanding2Vpc3
  zone_id      = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]

  tags = {
    Terraform = true
    Project   = var.ProjectName
  }
}

resource "alicloud_cen_transit_router_vpc_attachment" "centrVpc3Attachment" {
  depends_on        = [alicloud_instance.ftestLinux3]
  cen_id            = alicloud_cen_instance.cenInstance.id
  transit_router_id = alicloud_cen_transit_router.trRegion1.transit_router_id
  vpc_id            = alicloud_vpc.vpc3.id
  zone_mappings {
    zone_id    = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].master_zones[0]
    vswitch_id = alicloud_vswitch.vswTRLanding1Vpc3.id
  }
  zone_mappings {
    zone_id    = data.alicloud_cen_transit_router_available_resources.centrLandingVsw.resources[0].slave_zones[1]
    vswitch_id = alicloud_vswitch.vswTRLanding2Vpc3.id
  }
  transit_router_attachment_name        = "TR-TO-${upper(var.vpc3Name)}"
  transit_router_attachment_description = "TR-TO-${upper(var.vpc3Name)}"
}
