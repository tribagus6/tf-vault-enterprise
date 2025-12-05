variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "asia-east1"
}

variable "zone" {
  type    = string
  default = "asia-east1-b"
}

variable "vault_node_names" {
  type    = list(string)
  default = ["vault-1", "vault-2", "vault-3"]
}

variable "vault_enterprise_license" {
  description = "Vault Enterprise license content"
  type        = string
  sensitive   = true
}

