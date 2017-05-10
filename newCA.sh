#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 <CA name>"
    exit 0
fi

NAME=${1:-"SampleCA"}
FNAME=`echo $NAME | sed s+^\*.++`
DIGEST=sha256
KEYSIZE=4096
DAYS=7305

mkdir "[$FNAME]"
cd "[$FNAME]"

cat <<EOT > openssl.cnf
[ req ]
prompt                  = no
default_md              = $DIGEST
distinguished_name      = ca_distinguished_name
x509_extensions         = v3_ca

[ ca_distinguished_name ]
commonName              = $NAME

[ v3_ca ]
basicConstraints        = CA:TRUE
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always,issuer:always
keyUsage                = cRLSign, keyCertSign
nsCertType              = sslCA, emailCA
EOT

# Generate certificate:
openssl req -nodes -config openssl.cnf -days $DAYS -x509 -newkey rsa:$KEYSIZE -keyform PEM -keyout "$FNAME.key" -out "$FNAME.crt" -outform PEM

# Initialize serial numbers file:
echo "00" > "$FNAME.srl"

echo "Done."
