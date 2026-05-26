variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone_a" {
  description = "First availability zone"
  type        = string
  default     = "us-central1-a"
}

variable "zone_b" {
  description = "Second availability zone"
  type        = string
  default     = "us-central1-b"
}

variable "fortigate_image" {
  description = "FortiGate image (v7.6.6)"
  type        = string
  default     = "projects/fortigcp-project-001/global/images/fortinet-fgtondemand-766-20260129-001-w-license"
}

variable "fortigate_machine_type" {
  description = "Machine type for FortiGate VMs"
  type        = string
  default     = "n2-standard-4"
}

variable "license_file_a" {
  description = "Path to FortiGate license file for instance A (.lic)"
  type        = string
  default     = ""
}

variable "license_file_b" {
  description = "Path to FortiGate license file for instance B (.lic)"
  type        = string
  default     = ""
}


