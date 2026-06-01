project_id = "lgang-pj"
region     = "asia-southeast1"
zone_a     = "asia-southeast1-a"
zone_b     = "asia-southeast1-b"

fortigate_machine_type = "n2-standard-4"

# --- License mode (choose one) ---

# Mode 1: PAYG (default) - no license needed, uses on-demand image
#license_type = "payg"

# Mode 2: BYOL with license file
# license_type   = "file"
# license_file_a = "./licenses/fortigate-a.lic"
# license_file_b = "./licenses/fortigate-b.lic"

# Mode 3: FortiFlex VM Token
license_type      = "fortiflex"
fortiflex_token_a = "C75CFFD0430B4B05AE9F"
fortiflex_token_b = "E15D96D1AFDBFDE5F63A"
