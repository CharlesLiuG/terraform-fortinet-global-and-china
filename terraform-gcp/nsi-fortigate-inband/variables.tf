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

variable "license_type" {
  description = "License mode: 'payg' (on-demand, no license needed), 'file' (BYOL .lic file), or 'fortiflex' (VM token)"
  type        = string
  default     = "payg"
  validation {
    condition     = contains(["payg", "file", "fortiflex"], var.license_type)
    error_message = "license_type must be one of: payg, file, fortiflex"
  }
}

variable "fortigate_image_payg" {
  description = "FortiGate PAYG (on-demand) image"
  type        = string
  default     = "projects/fortigcp-project-001/global/images/fortinet-fgtondemand-766-20260129-001-w-license"
}

variable "fortigate_image_byol" {
  description = "FortiGate BYOL image"
  type        = string
  default     = "projects/fortigcp-project-001/global/images/fortinet-fgt-766-20260129-001-w-license"
}

variable "fortigate_machine_type" {
  description = "Machine type for FortiGate VMs"
  type        = string
  default     = "n2-standard-4"
}

variable "license_file_a" {
  description = "Path to FortiGate license file for instance A (.lic). Required when license_type = 'file'"
  type        = string
  default     = ""
}

variable "license_file_b" {
  description = "Path to FortiGate license file for instance B (.lic). Required when license_type = 'file'"
  type        = string
  default     = ""
}

variable "fortiflex_token_a" {
  description = "FortiFlex VM token for instance A. Required when license_type = 'fortiflex'"
  type        = string
  default     = ""
}

variable "fortiflex_token_b" {
  description = "FortiFlex VM token for instance B. Required when license_type = 'fortiflex'"
  type        = string
  default     = ""
}


