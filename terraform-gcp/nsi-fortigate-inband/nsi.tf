# =============================================================================
# NSI In-band Resources (Producer side)
# =============================================================================

# Intercept Deployment Group (global, associated with producer VPC)
resource "google_network_security_intercept_deployment_group" "nsi_dg" {
  provider                      = google-beta
  intercept_deployment_group_id = "fortigate-nsi-dg"
  location                      = "global"
  network                       = google_compute_network.producer_vpc.id
  description                   = "FortiGate NSI In-band Deployment Group"

  depends_on = [google_project_service.networksecurity]
}

# Intercept Deployment - Zone A
resource "google_network_security_intercept_deployment" "nsi_deploy_a" {
  provider                   = google-beta
  intercept_deployment_id    = "fortigate-nsi-deploy-a"
  location                   = var.zone_a
  forwarding_rule            = google_compute_forwarding_rule.fortigate_fwr_a.id
  intercept_deployment_group = google_network_security_intercept_deployment_group.nsi_dg.id
  description                = "FortiGate NSI deployment in ${var.zone_a}"
}

# Intercept Deployment - Zone B
resource "google_network_security_intercept_deployment" "nsi_deploy_b" {
  provider                   = google-beta
  intercept_deployment_id    = "fortigate-nsi-deploy-b"
  location                   = var.zone_b
  forwarding_rule            = google_compute_forwarding_rule.fortigate_fwr_b.id
  intercept_deployment_group = google_network_security_intercept_deployment_group.nsi_dg.id
  description                = "FortiGate NSI deployment in ${var.zone_b}"
}

# =============================================================================
# NSI In-band Resources (Consumer side)
# =============================================================================

# Intercept Endpoint Group (consumer references producer deployment group)
resource "google_network_security_intercept_endpoint_group" "nsi_eg" {
  provider                    = google-beta
  intercept_endpoint_group_id = "fortigate-nsi-eg"
  location                    = "global"
  intercept_deployment_group  = google_network_security_intercept_deployment_group.nsi_dg.id
  description                 = "NSI Endpoint Group for consumer VPC"
}

# Associate endpoint group with consumer VPC
resource "google_network_security_intercept_endpoint_group_association" "nsi_ega" {
  provider                                = google-beta
  intercept_endpoint_group_association_id = "fortigate-nsi-ega"
  location                                = "global"
  intercept_endpoint_group                = google_network_security_intercept_endpoint_group.nsi_eg.id
  network                                 = google_compute_network.consumer_vpc.id
}
