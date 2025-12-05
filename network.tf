# -------------------------
# CUSTOM VPC
# -------------------------
resource "google_compute_network" "vault_vpc" {
  name                    = "vault-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vault_subnet" {
  name          = "vault-subnet"
  region        = var.region
  network       = google_compute_network.vault_vpc.id
  ip_cidr_range = "172.168.0.0/24"
}

# -------------------------
# FIREWALL
# -------------------------
resource "google_compute_firewall" "vault_internal" {
  name    = "vault-internal-fw"
  network = google_compute_network.vault_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "8200", "8201"]
  }

  source_ranges = ["172.168.0.0/24","35.235.240.0/20"]
}

# -------------------------
# STATIC INTERNAL IPS
# -------------------------
resource "google_compute_address" "vault_internal_ip" {
  for_each     = toset(var.vault_node_names)
  name         = "${each.key}-ip"
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.vault_subnet.id
  region       = var.region
}

resource "google_compute_router" "vault_router" {
  name    = "vault-router"
  region  = var.region
  network = google_compute_network.vault_vpc.id
}

resource "google_compute_router_nat" "vault_nat" {
  name                               = "vault-nat"
  router                             = google_compute_router.vault_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

#   log_config {
#     enable = false
#     filter = "ERRORS_ONLY"
#   }
}
