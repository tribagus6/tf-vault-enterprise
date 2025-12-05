#!/bin/bash
set -e

VAULT_VERSION="1.18.4+ent"
VAULT_CLUSTER_NAME="cluster-pr"

NODE_NAME="${node_name}"
JOIN_IPS="${join_ips}"

apt-get update -y
apt-get install -y unzip curl jq

curl -fL -o /tmp/vault.zip \
  https://releases.hashicorp.com/vault/$VAULT_VERSION/vault_$${VAULT_VERSION}_linux_amd64.zip

unzip -t /tmp/vault.zip
unzip /tmp/vault.zip -d /usr/local/bin/
chmod +x /usr/local/bin/vault


useradd --system --home /etc/vault.d --shell /bin/false vault || true

mkdir -p /etc/vault.d /opt/vault
chown -R vault:vault /etc/vault.d /opt/vault

IP_ADDR=$(ip -4 route get 1.1.1.1 | awk '{print $7}')


# -------------------------
# VAULT CONFIG (MULTI JOIN)
# -------------------------
cat <<EOF >/etc/vault.d/vault.hcl
ui = true
disable_mlock = true

storage "raft" {
  path    = "/opt/vault"
  node_id = "$NODE_NAME"
EOF

for ip in $(echo $JOIN_IPS | tr "," " "); do
cat <<EOF >>/etc/vault.d/vault.hcl
  retry_join {
    leader_api_addr = "http://$ip:8200"
  }
EOF
done

cat <<EOF >>/etc/vault.d/vault.hcl
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr     = "http://$IP_ADDR:8200"
cluster_addr = "http://$IP_ADDR:8201"

cluster_name = "$VAULT_CLUSTER_NAME"
log_level    = "debug"

license_path = "/etc/vault.d/vault-enterprise-license.hclic"

EOF

# -------------------------
# ENTERPRISE LICENSE (FROM TERRAFORM)
# -------------------------
cat <<EOF >/etc/vault.d/vault-enterprise-license.hclic
${vault_license}
EOF

chown vault:vault /etc/vault.d/vault-enterprise-license.hclic
chmod 600 /etc/vault.d/vault-enterprise-license.hclic
chown -R vault:vault /etc/vault.d /opt/vault

# -------------------------
# SYSTEMD SERVICE
# -------------------------
cat <<EOF >/etc/systemd/system/vault.service
[Unit]
Description=Vault Enterprise
After=network-online.target
Wants=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65536
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable vault
systemctl start vault
