# =============================================================================
# Security Profile & Firewall Policy (In-band interception rules)
# =============================================================================

# Custom intercept security profile
resource "google_network_security_security_profile" "nsi_profile" {
  provider    = google-beta
  name        = "fortigate-nsi-profile"
  parent      = "projects/${var.project_id}"
  location    = "global"
  type        = "CUSTOM_INTERCEPT"
  description = "NSI intercept security profile for FortiGate"

  custom_intercept_profile {
    intercept_endpoint_group = google_network_security_intercept_endpoint_group.nsi_eg.id
  }
}

# Security profile group
resource "google_network_security_security_profile_group" "nsi_spg" {
  provider                 = google-beta
  name                     = "fortigate-nsi-spg"
  parent                   = "projects/${var.project_id}"
  location                 = "global"
  description              = "Security profile group for FortiGate NSI"
  custom_intercept_profile = google_network_security_security_profile.nsi_profile.id
}

# Global network firewall policy on consumer VPC
resource "google_compute_network_firewall_policy" "nsi_policy" {
  name        = "nsi-intercept-policy"
  project     = var.project_id
  description = "Firewall policy for NSI in-band interception"
}

# Associate policy with consumer VPC
resource "google_compute_network_firewall_policy_association" "nsi_policy_assoc" {
  name              = "nsi-policy-assoc"
  firewall_policy   = google_compute_network_firewall_policy.nsi_policy.name
  attachment_target = google_compute_network.consumer_vpc.id
  project           = var.project_id
}

# Firewall rule - intercept all ingress traffic for inspection (highest priority)
resource "google_compute_network_firewall_policy_rule" "intercept_ingress" {
  firewall_policy = google_compute_network_firewall_policy.nsi_policy.name
  project         = var.project_id
  priority        = 100
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

# Firewall rule - intercept all egress traffic for inspection
resource "google_compute_network_firewall_policy_rule" "intercept_all" {
  firewall_policy = google_compute_network_firewall_policy.nsi_policy.name
  project         = var.project_id
  priority        = 101
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



# =============================================================================
# Allow-all rules AFTER NSI intercept (priority > 1001)
# Traffic is first intercepted by FortiGate, then allowed through.
# All policy enforcement is done on FortiGate side.
# =============================================================================

resource "google_compute_network_firewall_policy_rule" "allow_all_ingress" {
  firewall_policy = google_compute_network_firewall_policy.nsi_policy.name
  project         = var.project_id
  priority        = 2000
  direction       = "INGRESS"
  action          = "allow"
  description     = "Allow all ingress - policy enforcement on FortiGate"

  match {
    src_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "all"
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "allow_all_egress" {
  firewall_policy = google_compute_network_firewall_policy.nsi_policy.name
  project         = var.project_id
  priority        = 2001
  direction       = "EGRESS"
  action          = "allow"
  description     = "Allow all egress - policy enforcement on FortiGate"

  match {
    dest_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "all"
    }
  }
}
