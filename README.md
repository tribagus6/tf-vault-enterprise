Sure — here is the **exact copied `README.md` content** you can paste directly into your repo:

```md
# Terraform Vault Enterprise on GCP

This repository provisions a **HashiCorp Vault Enterprise** cluster on **Google Cloud Platform (GCP)** using **Terraform**, with:

- ✅ Custom VPC & Subnet
- ✅ Cloud NAT for outbound internet access
- ✅ Static internal IPs
- ✅ Automated Vault installation via **startup script**
- ✅ Raft storage backend
- ✅ Systemd-managed Vault service
- ✅ Secure Vault Enterprise license injection

This project is production-oriented and fully automated with Terraform.

---

## 🏗️ Architecture Overview

- **Provider:** Google Cloud Platform (GCP)
- **Region:** `asia-southeast1`
- **Subnet CIDR:** `172.168.0.0/24`
- **Vault Storage:** Integrated Storage (Raft)
- **Traffic:**
  - Port `8200` → Vault API  
  - Port `8201` → Vault Cluster  
  - Port `22` → SSH
- **Egress:** Cloud NAT via Cloud Router

---

## 📁 Repository Structure

```

.
├── main.tf
├── variables.tf
├── outputs.tf
├── network.tf
├── compute-engine.tf
├── scripts/
│   └── vault-install.sh
├── .gitignore
└── README.md

````

---

## ✅ Prerequisites

Before using this repository, ensure you have:

- ✅ GCP Project
- ✅ Billing Enabled
- ✅ APIs enabled:
  - `compute.googleapis.com`
- ✅ Terraform v1.3+
- ✅ gcloud CLI authenticated:
  ```bash
  gcloud auth application-default login
````

---

## 🔐 Vault Enterprise License (IMPORTANT)

The Vault Enterprise license **must NOT be committed to GitHub**.

Set it securely as an environment variable:

### Linux / macOS

```bash
export TF_VAR_vault_enterprise_license="PASTE_YOUR_LICENSE_HERE"
```

### Windows (PowerShell)

```powershell
$env:TF_VAR_vault_enterprise_license="PASTE_YOUR_LICENSE_HERE"
```

Terraform will automatically inject it into the VM startup script.

---

## 🚀 Deployment Steps

### 1️⃣ Clone Repository

```bash
git clone https://github.com/tribagus6/tf-vault-enterprise.git
cd tf-vault-enterprise
```

---

### 2️⃣ Initialize Terraform

```bash
terraform init
```

---

### 3️⃣ Review the Plan

```bash
terraform plan
```

---

### 4️⃣ Apply Infrastructure

```bash
terraform apply
```

---

## 🔁 Recreate Vault VM (When Startup Script Changes)

If you update the startup script and want to re-run it:

```bash
terraform apply -replace='google_compute_instance.vault["vault-1"]'
```

---

## ✅ Post-Deployment Validation

SSH into the VM:

```bash
gcloud compute ssh vault-1 --zone=asia-southeast1-c
```

Verify Vault:

```bash
which vault
vault version
sudo systemctl status vault
```

You should see:

* `/usr/bin/vault`
* Vault Enterprise version
* `active (running)`

---

## 🧩 Vault Configuration Summary

* **Storage:** Raft
* **Cluster Join:** `retry_join` via internal IPs
* **UI:** Enabled
* **Listener:** TCP
* **TLS:** Disabled (can be added later)
* **License Path:**

  ```
  /etc/vault.d/vault-enterprise-license.hclic
  ```

---

## 🔒 Security Notes

* ❌ Do NOT commit:

  * `terraform.tfvars`
  * `*.hclic`
  * Any secrets or private keys
* ✅ Use `.gitignore`
* ✅ Use environment variables for secrets
* ✅ Consider adding TLS before production use

---

## 🔮 Roadmap (Optional Enhancements)

* [ ] Auto-unseal with GCP KMS
* [ ] TLS & mTLS
* [ ] Internal Load Balancer
* [ ] Vault auto-initialization
* [ ] HA with 3+ nodes
* [ ] GitHub Actions CI
* [ ] Remote backend using GCS

---

## 👤 Author

**Tri Bagus Pamungkas**
GitHub: [https://github.com/tribagus6](https://github.com/tribagus6)

---

## 📄 License

This project is provided as-is for learning and infrastructure automation purposes.
Vault Enterprise itself requires a valid HashiCorp license.

````
