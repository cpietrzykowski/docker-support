# mini-ca

A minimal CA [libressl](https://www.libressl.org/) based docker container.

> [OpenSSL Cookbook](https://www.feistyduck.com/library/openssl-cookbook/online/)

- output is found in /root/ca/out (or mounted to host)

## Examples

> This image is intended to be used interactively (self-signed CA script to automate certificate creation included).


### Building
> Assuming you have built the image locally with the tag 'libressl'.

```
$ docker build --tag mini-ca .
```

### Usage

generate key, csr and sign certificate with root CA:

```
$ docker run --rm -it -v ${PWD}/out:/root/ca/out mini-ca
```
