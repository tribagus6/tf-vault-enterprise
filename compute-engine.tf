
# -------------------------
# VAULT INSTANCES (EXPLICIT)
# -------------------------
resource "google_compute_instance" "vault" {
  for_each     = toset(var.vault_node_names)
  name         = each.key
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 20
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vault_subnet.id
    network_ip = google_compute_address.vault_internal_ip[each.key].address
  }

  #   metadata = {
  #     ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  #   }

  metadata_startup_script = templatefile(
    "${path.module}/scripts/vault-install.sh",
    {
      node_name = each.key
      join_ips = join(",", [
        for name in var.vault_node_names :
        google_compute_address.vault_internal_ip[name].address
      ])
      vault_license = var.vault_enterprise_license
    }
  )

  tags = ["vault"]
}
