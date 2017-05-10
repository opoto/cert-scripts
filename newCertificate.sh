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
req_extensions          = v3_req

[ ssl_distinguished_name ]
commonName              = $NAME

[ v3_req ]
basicConstraints       = CA:FALSE
keyUsage               = digitalSignature, nonRepudiation, keyEncipherment
subjectAltName         = @alt_names

[ alt_names ]
DNS.1 = $NAME
EOT

# Generate key:
openssl genrsa -out "$FNAME.key" $KEYSIZE

# Generate certificate request:
openssl req -new -config openssl.cnf -key "$FNAME.key" -out "$FNAME.csr"

# Generate certificate:
openssl x509 -extfile openssl.cnf -req -$DIGEST -days $DAYS -in "$FNAME.csr" -CA "../[$CA]/$CA.crt" -CAkey "../[$CA]/$CA.key" -CAserial "../[$CA]/$CA.srl" -extensions v3_req -out "$FNAME.crt"

echo "Done."
echo

# P12 & JKS
echo "OPTIONAL: generate P12 & Java keystore"
echo "Type CTRL-C if you don't need this"
echo
read -p "Enter password: " PASSWORD
openssl pkcs12 -export -in $FNAME.crt -inkey $FNAME.key \
           -out $FNAME.p12 -name $FNAME -password pass:$PASSWORD
keytool -importkeystore -alias $FNAME \
    -deststorepass $PASSWORD -destkeypass $PASSWORD -destkeystore $FNAME.jks \
    -srckeystore $FNAME.p12 -srcstoretype PKCS12 -srcstorepass $PASSWORD

echo
echo "All Done!"
