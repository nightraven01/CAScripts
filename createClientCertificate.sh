# Description: Creates an ECC server key/CSR and signs it with the Root CA.

# --- Configuration (MUST EXIST) --- run createRootca.sh first
CA_KEY="rootCA.key"
CA_CRT="rootCA.crt"
CA_SERIAL="rootCA.srl" # OpenSSL generates this file
SERVER_CURVE="prime256v1"
SERVER_DAYS=365

# --- Check for Root CA Files ---
if [ ! -f "$CA_KEY" ] || [ ! -f "$CA_CRT" ]; then
    echo "ERROR: Root CA key ($CA_KEY) or certificate ($CA_CRT) not found."
    echo "Please run create_root_ca.sh first."
    exit 1
fi

# --- Check for Arguments ---
if [ -z "$1" ]; then
    echo "USAGE: $0 <Server FQDN or CN>"
    echo "Example: $0 my.webserver.com"
    exit 1
fi

SERVER_CN="$1"
SERVER_KEY="${SERVER_CN}.key"
SERVER_CSR="${SERVER_CN}.csr"
SERVER_CRT="${SERVER_CN}.crt"
SERVER_EXT="${SERVER_CN}.ext"
SERVER_SUBJ="/C=DE/ST=HE/O=OneCF/CN=${SERVER_CN}"

echo "### 1. Generating ECC Private Key for Server ($SERVER_CN)..."
openssl ecparam -genkey -name "$SERVER_CURVE" -out "$SERVER_KEY"

echo "### 2. Creating Server CSR..."
openssl req -new -key "$SERVER_KEY" -out "$SERVER_CSR" -subj "$SERVER_SUBJ" -sha384

echo "### 3. Creating Extension File ($SERVER_EXT) for SAN and serverAuth..."
cat > "$SERVER_EXT" << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:$SERVER_CN
EOF

echo "### 4. Signing Server Certificate with Root CA..."
openssl x509 -req -in "$SERVER_CSR" \
    -CA "$CA_CRT" \
    -CAkey "$CA_KEY" \
    -CAcreateserial \
    -out "$SERVER_CRT" \
    -days "$SERVER_DAYS" \
    -sha384 \
    -extfile "$SERVER_EXT"

if [ $? -ne 0 ]; then
    echo "ERROR: Certificate signing failed. Check Root CA passphrase (if any) or file paths."
    exit 1
fi

echo "--- SUCCESS ---"
echo "Server certificate for $SERVER_CN created successfully:"
echo "Private Key: $SERVER_KEY"
echo "Certificate: $SERVER_CRT"
echo "-----------------"