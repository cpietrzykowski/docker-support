# mini-ca

A minimal CA [libressl](https://www.libressl.org/) based docker container.

> [OpenSSL Cookbook](https://www.feistyduck.com/library/openssl-cookbook/online/)

- keys use the domain name as the pass phrase
- output is found in /root/ca/out

## Examples

> This image is intended to be used interactively.

Assuming you have built the image locally with the tag 'libressl'.

- `docker run --rm -it libressl ca.sh [devdomain]`
    - generate key, csr and sign certificate with root CA for [devdomain]
- `docker run --rm -it libressl openssl`
    - invoke a typical openssl session
