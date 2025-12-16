cat generate-wildcard-ca.sh
#!/bin/bash
set -e

# -------------------------
# Configuration
# -------------------------
DOMAIN="*.lab.jshk.dev"
CERT_NAME="lab.jshk.dev.crt"
CERT_PATH="/etc/ssl/private/$CERT_NAME"
COMBINED_PEM="/etc/ssl/private/wildcard.lab.jshk.dev.pem"

CA_KEY="/etc/ssl/private/lab.arkj.ca.key.pem"
CA_CERT="/etc/ssl/certs/lab.arkj.ca.crt.pem"
CA_SERIAL="/etc/ssl/certs/lab.arkj.ca.srl"
TRUST_STORE="/usr/local/share/ca-certificates/lab.jshk"

# Temporary working files
TMP_KEY="/tmp/wildcard.key.XXXX"
TMP_CSR="/tmp/wildcard.csr.XXXX"
TMP_CONF="/tmp/wildcard.conf.XXXX"

# -------------------------
# Step 0: Create internal CA if not exists
# -------------------------
if [ ! -f "$CA_KEY" ] || [ ! -f "$CA_CERT" ]; then
  echo "[INFO] Creating internal CA..."
  sudo openssl genrsa -out "$CA_KEY" 4096
  sudo chmod 400 "$CA_KEY"

  sudo openssl req -x509 -new -nodes -key "$CA_KEY" \
    -sha256 -days 3650 \
    -out "$CA_CERT" \
    -subj "/C=IN/ST=MH/L=Pune/O=LocalDev/OU=CA/CN=lab.jshk.dev"
  sudo chmod 444 "$CA_CERT"

  # Add CA to system trust store
  sudo cp "$CA_CERT" "$TRUST_STORE"
  sudo update-ca-certificates
fi

# -------------------------
# Step 1: Generate wildcard key
# -------------------------
openssl genrsa -out "$TMP_KEY" 2048

# -------------------------
# Step 2: Generate CSR config
# -------------------------
tee "$TMP_CONF" > /dev/null <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[dn]
C = IN
ST = MH
L = Pune
O = LocalDev
OU = Dev
CN = $DOMAIN

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $DOMAIN
DNS.2 = lab.jshk.dev
EOF

# -------------------------
# Step 3: Generate CSR
# -------------------------
openssl req -new -key "$TMP_KEY" -out "$TMP_CSR" -config "$TMP_CONF"

# -------------------------
# Step 4: Sign CSR with lab.CA
# -------------------------
sudo openssl x509 -req -in "$TMP_CSR" \
  -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial \
  -out "$CERT_PATH" -days 825 -sha256 \
  -extfile "$TMP_CONF" -extensions req_ext

# -------------------------
# Step 5: Combine key + cert for HAProxy
# -------------------------
sudo sh -c "cat $CERT_PATH $TMP_KEY > $COMBINED_PEM"
sudo chmod 644 "$COMBINED_PEM"

# -------------------------
# Step 6: Cleanup temporary files
# -------------------------
rm -f "$TMP_KEY" "$TMP_CSR" "$TMP_CONF"

# -------------------------
# Step 7: Print CA certificate path for user
# -------------------------
echo "[INFO] Wildcard certificate generated and combined PEM ready at: $COMBINED_PEM"
echo "[INFO] CA certificate to copy to client machines for trust: $CA_CERT"

# -----------------------------------------------------------
# Sample config for HAPROXY bellow
# frontend https-in
#	bind *:443 ssl crt wildcard.lab.jshk.dev.pem
#	mode http
#	acl host_torrent hdr(host) -i torrent.lab.jshk.dev
#	acl host_minio hdr(host)   -i minio.lab.jshk.dev
#	use_backend bk_torrent  if host_torrent
#	use_backend bk_minio    if host_minio
#
# backend bk_torrent
#	server torrent1 127.0.0.1:3244 check
# backend bk_minio
#	server minio1 127.0.0.1:9001 check
# -----------------------------------------------------------
