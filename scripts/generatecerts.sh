#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

ASSETS_DIR="${SCRIPT_DIR}/../assets"

echo "For simplicity, we use the same ca for both parties"

echo '1. First we need a shared CA to later sign both the client and the server certificates:'
openssl req -nodes -new -x509 -keyout "${ASSETS_DIR}/shared-ca.key" -out "${ASSETS_DIR}/shared-ca.crt" -config "${ASSETS_DIR}/openssl.cnf"
cp "${ASSETS_DIR}/shared-ca.crt" "${ASSETS_DIR}/client-ca.crt"
cp "${ASSETS_DIR}/shared-ca.crt" "${ASSETS_DIR}/server-ca.crt"

echo '2. Then we create a shared cert signed by this CA for the user `development` in the superuser group
         `system:masters`:'
openssl req -out "${ASSETS_DIR}/shared-cert.csr" -new -newkey rsa:4096 -nodes -keyout "${ASSETS_DIR}/shared-cert.key" -subj "/CN=development/O=system:masters"
openssl x509 -req -days 365 -in "${ASSETS_DIR}/shared-cert.csr" -CA "${ASSETS_DIR}/shared-ca.crt" -CAkey "${ASSETS_DIR}/shared-ca.key" -set_serial 01 -sha256 -out "${ASSETS_DIR}/shared-cert.crt" -extfile "${ASSETS_DIR}/v3.ext"

cp "${ASSETS_DIR}/shared-cert.crt" "${ASSETS_DIR}/client.crt"
cp "${ASSETS_DIR}/shared-cert.crt" "${ASSETS_DIR}/server.crt"
cp "${ASSETS_DIR}/shared-cert.key" "${ASSETS_DIR}/client.key"
cp "${ASSETS_DIR}/shared-cert.key" "${ASSETS_DIR}/server.key"

echo '3. As curl requires client certificates in p12 format with password, do the conversion:'
openssl pkcs12 -export -in "${ASSETS_DIR}/client.crt" -inkey "${ASSETS_DIR}/client.key" -out "${ASSETS_DIR}/client.p12" -passout pass:password

# https://gist.github.com/KeithYeh/bb07cadd23645a6a62509b1ec8986bbc
# Step 1: Generate a Private Key
#openssl genrsa -des3 -out example.com.key 2048
# Step 2: Generate a CSR (Certificate Signing Request)
#openssl req -new -key example.com.key -out example.com.csr
# Step 3: Remove Passphrase from Key
#cp example.com.key example.com.key.org && openssl rsa -in example.com.key.org -out example.com.key

# Step 5: Generating a Self-Signed Certificate
#openssl x509 -req -in example.com.csr -signkey example.com.key -out example.com.crt -days 3650 -sha256 -extfile v3.ext

