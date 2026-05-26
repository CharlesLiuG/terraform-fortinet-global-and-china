# =============================================================================
# Firewall rules - Per Fortinet NSI documentation
# Producer VPC: allow all ingress/egress for inspection traffic
# Management VPC: allow all for FortiGate management
# =============================================================================

# Producer VPC - Allow all ingress
resource "google_compute_firewall" "producer_allow_all_ingress" {
  name    = "nsi-producer-allow-all-in"
  network = google_compute_network.producer_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["fortigate-nsi"]
}

# Producer VPC - Allow all egress
resource "google_compute_firewall" "producer_allow_all_egress" {
  name      = "nsi-producer-allow-all-egr"
  network   = google_compute_network.producer_vpc.id
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["fortigate-nsi"]
}

# Consumer VPC - Allow external access to test VM
resource "google_compute_firewall" "consumer_allow_external" {
  name    = "nsi-consumer-allow-external"
  network = google_compute_network.consumer_vpc.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["test-vm"]
}

# Consumer VPC - Allow all egress from test VM
resource "google_compute_firewall" "consumer_allow_egress" {
  name      = "nsi-consumer-allow-egress"
  network   = google_compute_network.consumer_vpc.id
  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["test-vm"]
}

# Management VPC - Allow all ingress
resource "google_compute_firewall" "mgmt_allow_all_ingress" {
  name    = "nsi-mgmt-allow-all-in"
  network = google_compute_network.mgmt_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["fortigate-nsi"]
}

# Management VPC - Allow all egress
resource "google_compute_firewall" "mgmt_allow_all_egress" {
  name      = "nsi-mgmt-allow-all-egr"
  network   = google_compute_network.mgmt_vpc.id
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["fortigate-nsi"]
}
