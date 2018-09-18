# LibreSSL

A container for [libressl](https://www.libressl.org/), using alpine as its base.
Useful as a base image for other tools.

### building

> $ docker build --tag libressl .

### running

The entrypoint is `openssl`.

> $ docker run libressl version
