# =============================================================================
# Test VM in Consumer VPC (for NSI traffic validation)
# =============================================================================

resource "google_compute_address" "vm01_a_eip" {
  name   = "vm01-a-eip"
  region = var.region
}

resource "google_compute_instance" "test_vm" {
  name         = "vm01-a"
  zone         = var.zone_a
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.consumer_subnet.id
    access_config {
      nat_ip = google_compute_address.vm01_a_eip.address
    }
  }

  metadata = {
    startup-script = "apt-get update && apt-get install -y nginx"
  }

  tags = ["test-vm"]
}


