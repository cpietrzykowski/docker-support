# DEV APP PROXY

This is intended to be used as a _secure_ development app proxy.

> based on [nginx](https://hub.docker.com/_/nginx/)

---

## SETUP

- config .env file (ensure ports match exposed)
    - `SERVER_NAME` : should be your cert cname
    - `APP_PORT` : defaults to 3000
    - `SSL_SUPPORT_DIR` : location of your ssl support files (ca/certs/keys)
        - request `/root.crt` if you want to install your CA to your device
          through a browser.

## Usage

```
$ docker-compose up
```
