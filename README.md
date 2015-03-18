cert-scripts
============

Utility scripts for generating certificates, primarily useful for creating SSL test certificates.
They rely on [openssl](https://www.openssl.org/) for the key and certificate processing.
The scripts themselves are Unix shell scripts (`/bin/sh`).

Creating a root certificate authority
-------------------------------------

```
./newCA.sh <CA name>
```

Example:

```
./newCA.sh 'My Company CA'
```

This will create a `[My Company CA]` directory with 3 files:

  * `.key`: the CA private key (in clear, pem format)
  * `.crt`: the CA certificate (pem format)
  * `.srl`: a file tracking  issued certificate serial number

Issuing a certificate from a previously generated certificate authority
------------------------------------------------------------------------

```
./newCertificate.sh <Certif. name> <CA name>
```

Example:

```
 ./newCertificate.sh '*.mycompany.com' 'My Company CA'
```

This will create a `[mycompany.com]` directory with 2 files:

  * `.key`: the generated certificate private key (in clear, pem format)
  * `.crt`: the generated certificate (pem format)

