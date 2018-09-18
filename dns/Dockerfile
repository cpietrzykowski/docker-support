FROM libressl

ARG UNBOUND_SOURCE_URL="https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz"
ARG BUILD_DEPS="\
    build-base \
    expat-dev \
"

RUN set -eux \
    && apk add --no-cache bind-tools

RUN set -eux \
    && WORK_DIR="$(mktemp -d)" \
    && mkdir -p "$WORK_DIR/unbound" \
    && cd "$WORK_DIR" \
    && wget --output-document=unbound.tar.gz "https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz" \
    && tar --extract --gzip --directory="$WORK_DIR/unbound" --strip-components=1 --file=unbound.tar.gz \
    && cd "$WORK_DIR/unbound" \
    && apk add --no-cache --virtual .deps $BUILD_DEPS \
    && ./configure \
    && make install \
    && cd / \
    && rm -fr "$WORK_DIR" \
    && apk del .deps \
    && addgroup -S unbound \
    && adduser -S unbound -G unbound \
    && command -v unbound

EXPOSE 53/TCP
EXPOSE 53/UDP
ENTRYPOINT [ "unbound" ]
