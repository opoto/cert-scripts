#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  $0 <Certif. name> <CA name>"
    exit 0
fi

NAME=${1:-"www.example.com"}
FNAME=`echo $NAME | sed s+^\*.++`
CA=${2:-"SampleCA"}
CA=`echo $CA | sed s+^\*.++`

KEYSIZE=2048
DAYS=3652
DIGEST=sha256

mkdir "[$FNAME]"
cd "[$FNAME]"

cat <<EOT > openssl.cnf

keyUsage=digitalSignature, keyEncipherment 
basicConstraints=CA:FALSE
subjectKeyIdentifier=hash
authorityKeyIdentifier = keyid,issuer
extendedKeyUsage = serverAuth,clientAuth

[ req ]
prompt                  = no
distinguished_name      = ssl_distinguished_name

[ ssl_distinguished_name ]
commonName              = $NAME
EOT

# Generate key:
openssl genrsa -out "$FNAME.key" $KEYSIZE 

# Generate certificate request:
openssl req -new -config openssl.cnf -key "$FNAME.key" -out "$FNAME.csr"

# Generate certificate:
openssl x509 -extfile openssl.cnf -req -$DIGEST -days $DAYS -in "$FNAME.csr" -CA "../[$CA]/$CA.crt" -CAkey "../[$CA]/$CA.key" -CAserial "../[$CA]/$CA.srl" -out "$FNAME.crt"
