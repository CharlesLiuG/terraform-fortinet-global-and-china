# =============================================================================
# Network Connectivity Center (NCC) - Hub and Spokes
# =============================================================================

resource "google_network_connectivity_hub" "ncc_hub" {
  name        = "nsi-ncc-hub"
  project     = var.project_id
  description = "NCC hub for inter-VPC connectivity"
}

resource "google_network_connectivity_spoke" "consumer_spoke" {
  name     = "consumer-vpc-spoke"
  project  = var.project_id
  location = "global"
  hub      = google_network_connectivity_hub.ncc_hub.id

  linked_vpc_network {
    uri = google_compute_network.consumer_vpc.self_link
  }
}

resource "google_network_connectivity_spoke" "standalone_spoke" {
  name     = "standalone-vpc-spoke"
  project  = var.project_id
  location = "global"
  hub      = google_network_connectivity_hub.ncc_hub.id

  linked_vpc_network {
    uri = google_compute_network.standalone_vpc.self_link
  }
}
