FROM alpine

ARG LIBRESSL_VERSION="2.8.0"

ARG BUILD_DEPS="\
    build-base \
    gnupg \
    linux-headers \
"

RUN set -ex \
    && WORK_DIR="$(mktemp -d)" \
    && cd "$WORK_DIR" \
    && apk add --no-cache --virtual .deps $BUILD_DEPS \
    && wget --output-document=libressl.tar.gz "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz" \
    && wget --output-document=libressl.tar.gz.asc "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz.asc" \
    && wget --output-document=libressl.asc "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --import libressl.asc \
    && gpg --batch --verify libressl.tar.gz.asc libressl.tar.gz \
    && mkdir -p "$WORK_DIR/libressl" \
    && tar --extract --gzip --directory="$WORK_DIR/libressl" --strip-components=1 --file=libressl.tar.gz \
    && cd "$WORK_DIR/libressl" \
    && ./configure \
    && make check \
    && make install \
    && apk del .deps \
    && cd / \
    && rm -rf "$WORK_DIR"

ENTRYPOINT [ "openssl" ]
