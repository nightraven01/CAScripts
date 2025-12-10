#!/bin/bash
# Script: create_root_ca.sh
# Description: Creates an ECC Root CA key and self-signed certificate.

# --- Configuration ---change this as per your requirements
CA_KEY="rootCA.key"
CA_CRT="rootCA.crt"
CA_CURVE="prime256v1"
CA_DAYS=3650
CA_SUBJ="/C=DE/ST=HE/O=ONECF_CA/CN=OneCF ECC Root CA"

echo "### 1. Generating ECC Private Key for Root CA ($CA_CURVE)..."
openssl ecparam -genkey -name "$CA_CURVE" -out "$CA_KEY"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to generate CA key. Exiting."
    exit 1
fi

echo "### 2. Creating Self-Signed Root CA Certificate ($CA_DAYS days)..."
openssl req -x509 -new -key "$CA_KEY" -sha384 -days "$CA_DAYS" -out "$CA_CRT" -subj "$CA_SUBJ"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create CA certificate. Exiting."
    exit 1
fi

echo "--- SUCCESS ---"
echo "Root CA created successfully:"
echo "Private Key: $CA_KEY (KEEP SECURE!)"
echo "Certificate: $CA_CRT"
echo "-----------------"