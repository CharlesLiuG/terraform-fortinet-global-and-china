# =============================================================================
# Standalone VM in separate VPC (same region, for east-west traffic testing)
# =============================================================================

resource "google_compute_network" "standalone_vpc" {
  name                    = "nsi-standalone-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "standalone_subnet" {
  name          = "nsi-standalone-subnet"
  region        = var.region
  ip_cidr_range = "10.40.0.0/24"
  network       = google_compute_network.standalone_vpc.id
}

# =============================================================================
# NSI Association & Firewall Policy for standalone VPC
# =============================================================================

resource "google_network_security_intercept_endpoint_group_association" "standalone_ega" {
  provider                              = google-beta
  intercept_endpoint_group_association_id = "standalone-nsi-ega"
  location                              = "global"
  intercept_endpoint_group              = google_network_security_intercept_endpoint_group.nsi_eg.id
  network                               = google_compute_network.standalone_vpc.id
}

resource "google_compute_network_firewall_policy" "standalone_policy" {
  name        = "standalone-nsi-intercept-policy"
  project     = var.project_id
  description = "Firewall policy for NSI interception on standalone VPC"
}

resource "google_compute_network_firewall_policy_association" "standalone_policy_assoc" {
  name              = "standalone-nsi-policy-assoc"
  firewall_policy   = google_compute_network_firewall_policy.standalone_policy.name
  attachment_target = google_compute_network.standalone_vpc.id
  project           = var.project_id
}

resource "google_compute_network_firewall_policy_rule" "standalone_intercept_egress" {
  firewall_policy = google_compute_network_firewall_policy.standalone_policy.name
  project         = var.project_id
  priority        = 1000
  direction       = "EGRESS"
  action          = "apply_security_profile_group"
  description     = "Send all egress traffic to FortiGate for inspection"

  security_profile_group = google_network_security_security_profile_group.nsi_spg.id

  match {
    dest_ip_ranges = ["0.0.0.0/0"]
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "standalone_intercept_ingress" {
  firewall_policy = google_compute_network_firewall_policy.standalone_policy.name
  project         = var.project_id
  priority        = 1001
  direction       = "INGRESS"
  action          = "apply_security_profile_group"
  description     = "Send all ingress traffic to FortiGate for inspection"

  security_profile_group = google_network_security_security_profile_group.nsi_spg.id

  match {
    src_ip_ranges = ["0.0.0.0/0"]
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

resource "google_compute_address" "vm02_b_eip" {
  name   = "vm02-b-eip"
  region = var.region
}

resource "google_compute_instance" "standalone_vm" {
  name         = "vm02-b"
  zone         = var.zone_b
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.standalone_subnet.id
    access_config {
      nat_ip = google_compute_address.vm02_b_eip.address
    }
  }

  tags = ["standalone-vm"]
}
