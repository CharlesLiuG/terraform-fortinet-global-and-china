output "producer_vpc_id" {
  value = google_compute_network.producer_vpc.id
}

output "consumer_vpc_id" {
  value = google_compute_network.consumer_vpc.id
}

output "fortigate_a_ip" {
  value = google_compute_instance.fortigate_a.network_interface[0].network_ip
  description = "FortiGate-A data plane IP (port1)"
}

output "fortigate_b_ip" {
  value = google_compute_instance.fortigate_b.network_interface[0].network_ip
  description = "FortiGate-B data plane IP (port1)"
}

output "fortigate_a_mgmt_ip" {
  value = google_compute_instance.fortigate_a.network_interface[1].access_config[0].nat_ip
  description = "FortiGate-A management public IP (port2)"
}

output "fortigate_b_mgmt_ip" {
  value = google_compute_instance.fortigate_b.network_interface[1].access_config[0].nat_ip
  description = "FortiGate-B management public IP (port2)"
}

output "nsi_deployment_group" {
  value = google_network_security_intercept_deployment_group.nsi_dg.id
}

output "nsi_endpoint_group" {
  value = google_network_security_intercept_endpoint_group.nsi_eg.id
}
