# =============================================================================
# Producer VPC - FortiGate appliances (data/GENEVE plane)
# =============================================================================

resource "google_compute_network" "producer_vpc" {
  name                    = "nsi-producer-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "producer_subnet" {
  name                     = "nsi-producer-subnet"
  region                   = var.region
  ip_cidr_range            = "10.10.0.0/24"
  network                  = google_compute_network.producer_vpc.id
  private_ip_google_access = true
}

# =============================================================================
# Management VPC - FortiGate management interface
# =============================================================================

resource "google_compute_network" "mgmt_vpc" {
  name                    = "nsi-mgmt-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "mgmt_subnet" {
  name                     = "nsi-mgmt-subnet"
  region                   = var.region
  ip_cidr_range            = "10.30.0.0/24"
  network                  = google_compute_network.mgmt_vpc.id
  private_ip_google_access = true
}

# =============================================================================
# Consumer VPC - Workloads
# =============================================================================

resource "google_compute_network" "consumer_vpc" {
  name                    = "nsi-consumer-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "consumer_subnet" {
  name          = "nsi-consumer-subnet"
  region        = var.region
  ip_cidr_range = "10.20.0.0/24"
  network       = google_compute_network.consumer_vpc.id
}


