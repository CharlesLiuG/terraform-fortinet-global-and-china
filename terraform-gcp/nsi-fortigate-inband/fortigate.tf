# =============================================================================
# Static Public IPs for FortiGate management
# =============================================================================

resource "google_compute_address" "fortigate_mgmt_a" {
  name   = "fortigate-mgmt-ip-a"
  region = var.region
}

resource "google_compute_address" "fortigate_mgmt_b" {
  name   = "fortigate-mgmt-ip-b"
  region = var.region
}

# Static Public IPs for FortiGate port1 (data plane)
resource "google_compute_address" "fortigate_data_a" {
  name   = "fortigate-data-ip-a"
  region = var.region
}

resource "google_compute_address" "fortigate_data_b" {
  name   = "fortigate-data-ip-b"
  region = var.region
}

# =============================================================================
# Log disks for FortiGate (20GB each)
# =============================================================================

resource "google_compute_disk" "fortigate_log_a" {
  name = "fortigate-log-disk-a"
  zone = var.zone_a
  size = 20
  type = "pd-ssd"
}

resource "google_compute_disk" "fortigate_log_b" {
  name = "fortigate-log-disk-b"
  zone = var.zone_b
  size = 20
  type = "pd-ssd"
}

# =============================================================================
# FortiGate VM instances - Cross-AZ deployment (Zone A & Zone B)
# =============================================================================

resource "google_compute_instance" "fortigate_a" {
  name         = "fortigate-nsi-a"
  zone         = var.zone_a
  machine_type = var.fortigate_machine_type

  boot_disk {
    initialize_params {
      image = local.fortigate_image
    }
  }

  attached_disk {
    source = google_compute_disk.fortigate_log_a.self_link
  }

  # port1 - Data/GENEVE interface (NSI traffic)
  network_interface {
    subnetwork = google_compute_subnetwork.producer_subnet.id
    network_ip = "10.10.0.2"
    access_config {
      nat_ip = google_compute_address.fortigate_data_a.address
    }
  }

  # port2 - Management interface
  network_interface {
    subnetwork = google_compute_subnetwork.mgmt_subnet.id
    access_config {
      nat_ip = google_compute_address.fortigate_mgmt_a.address
    }
  }

  can_ip_forward = true

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro", "cloud-platform"]
  }

  metadata = merge(
    { user-data = local.fortigate_config_a },
    local.license_a != null ? { license = local.license_a } : {}
  )

  tags = ["fortigate-nsi"]

  labels = {
    role = "nsi-producer"
    zone = var.zone_a
  }
}

resource "google_compute_instance" "fortigate_b" {
  name         = "fortigate-nsi-b"
  zone         = var.zone_b
  machine_type = var.fortigate_machine_type

  boot_disk {
    initialize_params {
      image = local.fortigate_image
    }
  }

  attached_disk {
    source = google_compute_disk.fortigate_log_b.self_link
  }

  # port1 - Data/GENEVE interface (NSI traffic)
  network_interface {
    subnetwork = google_compute_subnetwork.producer_subnet.id
    network_ip = "10.10.0.3"
    access_config {
      nat_ip = google_compute_address.fortigate_data_b.address
    }
  }

  # port2 - Management interface
  network_interface {
    subnetwork = google_compute_subnetwork.mgmt_subnet.id
    access_config {
      nat_ip = google_compute_address.fortigate_mgmt_b.address
    }
  }

  can_ip_forward = true

  service_account {
    scopes = ["userinfo-email", "compute-rw", "storage-ro", "cloud-platform"]
  }

  metadata = merge(
    { user-data = local.fortigate_config_b },
    local.license_b != null ? { license = local.license_b } : {}
  )

  tags = ["fortigate-nsi"]

  labels = {
    role = "nsi-producer"
    zone = var.zone_b
  }
}

# =============================================================================
# FortiGate bootstrap config with license handling
# =============================================================================

locals {
  producer_gateway = cidrhost(google_compute_subnetwork.producer_subnet.ip_cidr_range, 1)
  mgmt_gateway     = cidrhost(google_compute_subnetwork.mgmt_subnet.ip_cidr_range, 1)
  ilb_ip_a         = "10.10.0.10"
  ilb_ip_b         = "10.10.0.11"

  fortigate_config_a = <<-EOF
    config system global
      set hostname "fortigate-nsi-a"
      set admintimeout 30
    end
    config system dns
      set interface-select-method specify
      set interface "port2"
    end
    config system fortiguard
      set interface-select-method specify
      set interface "port2"
    end
    config system probe-response
      set mode http-probe
    end
    config system geneve
      edit "gcp"
        set interface "port1"
        set type ppp
        set remote-ip ${local.producer_gateway}
      next
    end
    config system interface
      edit "port1"
        set mode static
        set ip 10.10.0.2 255.255.255.255
        set allowaccess ping https ssh http probe-response
        set mtu-override enable
        set mtu 1600
        set secondary-IP enable
        config secondaryip
          edit 1
            set ip ${local.ilb_ip_a} 255.255.255.0
            set allowaccess probe-response ping
          next
          edit 2
            set ip ${local.ilb_ip_b} 255.255.255.0
            set allowaccess probe-response ping
          next
        end
      next
      edit "port2"
        set vrf 5
        set mode dhcp
        set allowaccess ping https ssh http fgfm probe-response
        set mtu-override enable
        set mtu 1460
      next
      edit "gcp"
        set mtu-override enable
        set mtu 1522
      next
    end
    config router static
      edit 1
        set gateway ${local.mgmt_gateway}
        set device "port2"
      next
      edit 2
        set dst 130.211.0.0 255.255.252.0
        set gateway ${local.producer_gateway}
        set device "port1"
      next
      edit 3
        set dst 35.191.0.0 255.255.0.0
        set gateway ${local.producer_gateway}
        set device "port1"
      next
      edit 4
        set distance 5
        set device "gcp"
      next
      edit 5
        set gateway ${local.producer_gateway}
        set device "port1"
      next
    end
    config router policy
      edit 1
        set input-device "port1"
        set srcaddr "all"
        set dstaddr "all"
        set gateway ${local.producer_gateway}
        set output-device "port1"
      next
      edit 2
        set input-device "gcp"
        set srcaddr "all"
        set dstaddr "all"
        set output-device "gcp"
      next
    end
    config firewall policy
      edit 1
        set name "geneve-inspect"
        set srcintf "gcp"
        set dstintf "gcp"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set logtraffic all
      next
    end
  EOF

  fortigate_config_b = <<-EOF
    config system global
      set hostname "fortigate-nsi-b"
      set admintimeout 30
    end
    config system dns
      set interface-select-method specify
      set interface "port2"
    end
    config system fortiguard
      set interface-select-method specify
      set interface "port2"
    end
    config system probe-response
      set mode http-probe
    end
    config system geneve
      edit "gcp"
        set interface "port1"
        set type ppp
        set remote-ip ${local.producer_gateway}
      next
    end
    config system interface
      edit "port1"
        set mode static
        set ip 10.10.0.3 255.255.255.255
        set allowaccess ping https ssh http probe-response
        set mtu-override enable
        set mtu 1600
        set secondary-IP enable
        config secondaryip
          edit 1
            set ip ${local.ilb_ip_a} 255.255.255.0
            set allowaccess probe-response ping
          next
          edit 2
            set ip ${local.ilb_ip_b} 255.255.255.0
            set allowaccess probe-response ping
          next
        end
      next
      edit "port2"
        set vrf 5
        set mode dhcp
        set allowaccess ping https ssh http fgfm probe-response
        set mtu-override enable
        set mtu 1460
      next
      edit "gcp"
        set mtu-override enable
        set mtu 1522
      next
    end
    config router static
      edit 1
        set gateway ${local.mgmt_gateway}
        set device "port2"
      next
      edit 2
        set dst 130.211.0.0 255.255.252.0
        set gateway ${local.producer_gateway}
        set device "port1"
      next
      edit 3
        set dst 35.191.0.0 255.255.0.0
        set gateway ${local.producer_gateway}
        set device "port1"
      next
      edit 4
        set distance 5
        set device "gcp"
      next
      edit 5
        set gateway ${local.producer_gateway}
        set device "port1"
      next
    end
    config router policy
      edit 1
        set input-device "port1"
        set srcaddr "all"
        set dstaddr "all"
        set gateway ${local.producer_gateway}
        set output-device "port1"
      next
      edit 2
        set input-device "gcp"
        set srcaddr "all"
        set dstaddr "all"
        set output-device "gcp"
      next
    end
    config firewall policy
      edit 1
        set name "geneve-inspect"
        set srcintf "gcp"
        set dstintf "gcp"
        set srcaddr "all"
        set dstaddr "all"
        set action accept
        set schedule "always"
        set service "ALL"
        set logtraffic all
      next
    end
  EOF

  # Image selection: PAYG uses on-demand image, BYOL/FortiFlex uses BYOL image
  fortigate_image = var.license_type == "payg" ? var.fortigate_image_payg : var.fortigate_image_byol

  # License metadata based on license_type
  license_a = (
    var.license_type == "file" ? file(var.license_file_a) :
    var.license_type == "fortiflex" ? "LICENSE-TOKEN:${var.fortiflex_token_a}" :
    null # payg - no license needed
  )
  license_b = (
    var.license_type == "file" ? file(var.license_file_b) :
    var.license_type == "fortiflex" ? "LICENSE-TOKEN:${var.fortiflex_token_b}" :
    null # payg - no license needed
  )
}

# =============================================================================
# Instance Groups (one per zone for ILB backend)
# =============================================================================

resource "google_compute_instance_group" "fortigate_ig_a" {
  name    = "fortigate-ig-a"
  zone    = var.zone_a
  network = google_compute_network.producer_vpc.id

  instances = [google_compute_instance.fortigate_a.self_link]
}

resource "google_compute_instance_group" "fortigate_ig_b" {
  name    = "fortigate-ig-b"
  zone    = var.zone_b
  network = google_compute_network.producer_vpc.id

  instances = [google_compute_instance.fortigate_b.self_link]
}
