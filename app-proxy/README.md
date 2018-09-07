# DEV APP PROXY

This is intended to be used as a _secure_ development app proxy.

> based on [nginx:alpine docker container](https://hub.docker.com/_/nginx/)

---

## SETUP

- config .env file (ensure ports match exposed)
    - SERVER_NAME : should be your cert cname
    - APP_PORT : defaults to 3000
    - SSL_SUPPORT_DIR : location of your ssl support files (ca/certs/keys)
        - request /ca.pem if you want to install your CA to your device. (this is only request not passed to the app)
