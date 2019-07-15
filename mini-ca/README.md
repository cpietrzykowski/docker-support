# mini-ca

A minimal CA [libressl](https://www.libressl.org/) based docker container.

> [OpenSSL Cookbook](https://www.feistyduck.com/library/openssl-cookbook/online/)

- keys use the domain name as the pass phrase
- output is found in /root/ca/out

## Examples

> This image is intended to be used interactively.

Assuming you have built the image locally with the tag 'libressl'.

> docker build --tag mini-ca .

- `docker run --rm -it -v ${PWD}/out:/root/ca/out --entrypoint ca.sh mini-ca`
    - generate key, csr and sign certificate with root CA
- `docker run --rm -it mini-ca`
    - invoke a typical openssl session
