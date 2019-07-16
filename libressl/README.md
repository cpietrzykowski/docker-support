# LibreSSL

A container for [libressl](https://www.libressl.org/).
Useful as a base image for other tools that depend on an OpenSSL-like install being available.

### Building

```
$ docker build --tag libressl .
```

### Usage

The entrypoint is `openssl`.

```
$ docker run libressl version
```
