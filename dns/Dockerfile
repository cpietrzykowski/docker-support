FROM libressl

ARG UNBOUND_SOURCE_URL="https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz"
ARG BUILD_DEPS="\
    build-essential \
    ca-certificates \
    libexpat1-dev \
    wget \
"

RUN set -eux \
    && WORK_DIR="$(mktemp -d)" \
    && cd "${WORK_DIR}" \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${BUILD_DEPS} \
    && wget --output-document=unbound.tar.gz "https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz" \
    && mkdir -p "unbound" \
    && tar --extract --gzip --directory="unbound" --strip-components=1 --file=unbound.tar.gz \
    && cd "unbound" \
    && ./configure \
    && make install \
    && cd / \
    && rm -fr "${WORK_DIR}" \
    && apt-get purge -y --auto-remove ${BUILD_DEPS} \
    && groupadd --system unbound \
    && useradd --shell /dev/null --system -g unbound unbound \
    && command -v unbound

EXPOSE 53/TCP
EXPOSE 53/UDP
ENTRYPOINT [ "unbound" ]
