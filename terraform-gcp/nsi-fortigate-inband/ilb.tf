# =============================================================================
# Internal Passthrough Network Load Balancer (UDP 6081 - GENEVE)
# Per Fortinet NSI documentation
# =============================================================================

resource "google_compute_health_check" "fortigate_hc" {
  name = "fortigate-nsi-hc"

  http_health_check {
    port = 8008
  }
}

resource "google_compute_region_backend_service" "fortigate_bs" {
  name                  = "fortigate-nsi-bs"
  region                = var.region
  protocol              = "UDP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.fortigate_hc.id]

  backend {
    group          = google_compute_instance_group.fortigate_ig_a.id
    balancing_mode = "CONNECTION"
  }

  backend {
    group          = google_compute_instance_group.fortigate_ig_b.id
    balancing_mode = "CONNECTION"
  }
}

# Forwarding rule for Zone A
resource "google_compute_forwarding_rule" "fortigate_fwr_a" {
  name                  = "fortigate-nsi-fwr-a"
  region                = var.region
  network               = google_compute_network.producer_vpc.id
  subnetwork            = google_compute_subnetwork.producer_subnet.id
  backend_service       = google_compute_region_backend_service.fortigate_bs.id
  load_balancing_scheme = "INTERNAL"
  ports                 = ["6081"]
  ip_protocol           = "UDP"
  ip_address            = "10.10.0.10"
}

# Forwarding rule for Zone B
resource "google_compute_forwarding_rule" "fortigate_fwr_b" {
  name                  = "fortigate-nsi-fwr-b"
  region                = var.region
  network               = google_compute_network.producer_vpc.id
  subnetwork            = google_compute_subnetwork.producer_subnet.id
  backend_service       = google_compute_region_backend_service.fortigate_bs.id
  load_balancing_scheme = "INTERNAL"
  ports                 = ["6081"]
  ip_protocol           = "UDP"
  ip_address            = "10.10.0.11"
}
