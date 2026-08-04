# ── Security VPC ────────────────────────────────────────────────────────────────
output "sec_vpc_arn" {
  value = aws_vpc.sec.arn
}

output "sec_vpc_id" {
  value = aws_vpc.sec.id
}

output "sec_cwan_subnet_arns" {
  description = "Cloud WAN attachment subnet ARNs (cwan-subnet in both AZs)"
  value       = [aws_subnet.sec_cwan_az1.arn, aws_subnet.sec_cwan_az2.arn]
}

# ── Spoke VPCs ──────────────────────────────────────────────────────────────────
output "spoke_a_vpc_arn" {
  value = aws_vpc.spoke["a"].arn
}

output "spoke_a_subnet_arns" {
  value = [aws_subnet.spoke["a-az1"].arn, aws_subnet.spoke["a-az2"].arn]
}

output "spoke_b_vpc_arn" {
  value = aws_vpc.spoke["b"].arn
}

output "spoke_b_subnet_arns" {
  value = [aws_subnet.spoke["b-az1"].arn, aws_subnet.spoke["b-az2"].arn]
}

# ── GWLB ────────────────────────────────────────────────────────────────────────
output "gwlb_arn" {
  value = aws_lb.gwlb.arn
}

output "gwlb_service_name" {
  description = "GWLB Endpoint Service name"
  value       = aws_vpc_endpoint_service.gwlb.service_name
}

# ── Route tables needing a Cloud WAN default route ──────────────────────────────
# The routes themselves are created in the root module so they can depend on the
# Cloud WAN attachments directly (see cloud_wan_routes.tf).
output "sec_gwlbe_route_table_id" {
  description = "Security VPC gwlbe subnet route table — needs 0.0.0.0/0 → core network"
  value       = aws_route_table.sec_gwlbe.id
}

output "spoke_a_route_table_id" {
  value = aws_route_table.spoke["a"].id
}

output "spoke_b_route_table_id" {
  value = aws_route_table.spoke["b"].id
}

# ── Management access ───────────────────────────────────────────────────────────
output "primary_mgmt_public_ip" {
  value = aws_eip.primary_mgmt.public_ip
}

output "secondary_mgmt_public_ip" {
  value = aws_eip.secondary_mgmt.public_ip
}

output "primary_mgmt_url" {
  value = "https://${aws_eip.primary_mgmt.public_ip}"
}

output "secondary_mgmt_url" {
  value = "https://${aws_eip.secondary_mgmt.public_ip}"
}

output "primary_external_eip" {
  value = aws_eip.primary_external.public_ip
}

output "secondary_external_eip" {
  value = aws_eip.secondary_external.public_ip
}
