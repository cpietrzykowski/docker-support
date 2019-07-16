FROM debian:latest

ARG LIBRESSL_VERSION="2.9.2"

ARG BUILD_DEPS="\
    build-essential \
    ca-certificates \
    gnupg2 \
    wget \
"

RUN set -ex \
    && WORK_DIR="$(mktemp -d)" \
    && cd "${WORK_DIR}" \
    && apt-get update \
    && apt-get install -y --no-install-recommends $BUILD_DEPS \
    && wget --output-document=libressl.tar.gz "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz" \
    && wget --output-document=libressl.tar.gz.asc "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz.asc" \
    && wget --output-document=libressl.asc "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --import libressl.asc \
    && gpg --batch --verify libressl.tar.gz.asc libressl.tar.gz \
    && mkdir -p "libressl" \
    && tar --extract --gzip --directory="libressl" --strip-components=1 --file=libressl.tar.gz \
    && cd "libressl" \
    && ./configure \
    && make check \
    && make install \
    && cd / \
    && apt-get purge -y --auto-remove $BUILD_DEPS \
    && rm -rf "${WORK_DIR}"

ENTRYPOINT [ "openssl" ]
