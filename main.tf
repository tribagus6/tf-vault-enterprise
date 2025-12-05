terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# -------------------------
# OS IMAGE
# -------------------------
data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}


# -------------------------
# OUTPUTS
# -------------------------
output "vault_private_ips" {
  value = {
    for k, v in google_compute_address.vault_internal_ip :
    k => v.address
  }
}
