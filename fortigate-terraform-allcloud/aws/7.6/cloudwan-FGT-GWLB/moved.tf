# ─────────────────────────────────────────────────────────────────────────────────
# State migration for the Cloud WAN attachment refactor.
#
# The six hand-written attachment resources became two for_each'd resources.
# These blocks tell Terraform it is the same attachment under a new address, so
# an existing state migrates without tearing down and rebuilding attachments
# (which would black-hole traffic while the core network reconverged).
#
# No-ops on a fresh state.
# ─────────────────────────────────────────────────────────────────────────────────

moved {
  from = aws_networkmanager_vpc_attachment.singapore_sec
  to   = aws_networkmanager_vpc_attachment.sec["singapore"]
}

moved {
  from = aws_networkmanager_vpc_attachment.tokyo_sec
  to   = aws_networkmanager_vpc_attachment.sec["tokyo"]
}

moved {
  from = aws_networkmanager_vpc_attachment.singapore_spoke_a
  to   = aws_networkmanager_vpc_attachment.spoke["singapore-a"]
}

moved {
  from = aws_networkmanager_vpc_attachment.singapore_spoke_b
  to   = aws_networkmanager_vpc_attachment.spoke["singapore-b"]
}

moved {
  from = aws_networkmanager_vpc_attachment.tokyo_spoke_a
  to   = aws_networkmanager_vpc_attachment.spoke["tokyo-a"]
}

moved {
  from = aws_networkmanager_vpc_attachment.tokyo_spoke_b
  to   = aws_networkmanager_vpc_attachment.spoke["tokyo-b"]
}
