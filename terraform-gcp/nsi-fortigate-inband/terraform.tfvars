project_id = "lgang-pj"
region     = "asia-southeast1"
zone_a     = "asia-southeast1-a"
zone_b     = "asia-southeast1-b"

# FortiGate v7.6.6 On-demand image
fortigate_image        = "projects/fortigcp-project-001/global/images/fortinet-fgtondemand-766-20260129-001-w-license"
fortigate_machine_type = "n2-standard-4"

# --- License activation (choose one method) ---

# Method 1: License file (.lic)
# license_type   = "file"
# license_file_a = "./licenses/fortigate-a.lic"
# license_file_b = "./licenses/fortigate-b.lic"

# Method 2: FortiFlex VM Token (uncomment below, comment out Method 1)
# license_type      = "fortiflex"
# fortiflex_token_a = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
# fortiflex_token_b = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
