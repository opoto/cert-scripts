#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 <Certif. name>"
    exit 0
fi

openssl pkcs12 -export -out "[$1]/$1.pfx" -inkey "[$1]/$1.key" -in "[$1]/$1.crt"
# -certfile CACert.crt
