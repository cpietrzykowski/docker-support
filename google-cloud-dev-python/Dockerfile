FROM alpine

#
# NOTE INTENDED FOR PRODUCTION SERVICES
#
# this is a development environment for google cloud applications
#

ARG KEY_SERVERS="\
    ha.pool.sks-keyservers.net \
    na.pool.sks-keyservers.net \
"
ARG GPG_KEYIDS="6A45C816 36580288 7D9DC8D2 18ADD4FF A4135B38 A74B06BF EA5BBD71 E6DF025C AA65421D 6F5E1540 F73C700D 487034E5"
ARG PYTHON2_VERSION="2.7.15"
ARG PYTHON3_VERSION="3.7.0"
ARG CLOUDSDK_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz"

ARG PYTHON_DEP_APKS="\
    bzip2-dev \
    coreutils \
    dpkg-dev dpkg \
    expat-dev \
    findutils \
    gcc \
    gdbm-dev \
    libc-dev \
    libffi-dev \
    libnsl-dev \
    libressl-dev \
    libtirpc-dev \
    linux-headers \
    make \
    ncurses-dev \
    pax-utils \
    readline-dev \
    sqlite-dev \
    tcl-dev \
    tk \
    tk-dev \
    util-linux-dev \
    xz-dev \
    zlib-dev \
"
ARG CLOUDSDK_COMPONENTS="\
    alpha \
    app-engine-python \
    app-engine-python-extras \
    beta \
    bigtable \
    cbt \
    cloud-datastore-emulator \
    datalab \
    gcd-emulator \
    kubectl \
    pubsub-emulator \
"

RUN apk add --no-cache ca-certificates

# giant python/pip (2/3) install
RUN set -eux \
    && WORKDIR="$(mktemp -d)" \
    && cd "$WORKDIR" \
    && apk add --no-cache --virtual .deps \
        gnupg \
        \
    && export GNUPGHOME="$(mktemp -d)" \
    && for server in $KEY_SERVERS \
    ; do \
    gpg --keyserver "$server" --keyserver-options timeout=5 --recv-keys $GPG_KEYIDS ; \
    done \
    \
    && wget --output-document=python2.tar.gz "https://www.python.org/ftp/python/${PYTHON2_VERSION%%[a-z]*}/Python-$PYTHON2_VERSION.tgz" \
    && wget --output-document=python2.tar.gz.asc "https://www.python.org/ftp/python/${PYTHON2_VERSION%%[a-z]*}/Python-$PYTHON2_VERSION.tgz.asc" \
    && gpg --batch --verify python2.tar.gz.asc python2.tar.gz \
    && mkdir -p "$WORKDIR/python2" \
    && tar --extract --gzip --directory="$WORKDIR/python2" --strip-components=1 --file=python2.tar.gz \
    \
    && wget --output-document=python3.tar.gz "https://www.python.org/ftp/python/${PYTHON3_VERSION%%[a-z]*}/Python-$PYTHON3_VERSION.tgz" \
    && wget --output-document=python3.tar.gz.asc "https://www.python.org/ftp/python/${PYTHON3_VERSION%%[a-z]*}/Python-$PYTHON3_VERSION.tgz.asc" \
    && gpg --batch --verify python3.tar.gz.asc python3.tar.gz \
    && mkdir -p "$WORKDIR/python3" \
    && tar --extract --gzip --directory="$WORKDIR/python3" --strip-components=1 --file=python3.tar.gz \
    \
    && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
    \
    && apk add --no-cache --virtual .deps $PYTHON_DEP_APKS \
    && GNU_ARCH="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    \
    && cd "$WORKDIR/python2" \
    && ./configure \
        --build="$GNU_ARCH" \
        --enable-shared \
        --enable-unicode=ucs4 \
        --with-system-expat \
        --with-system-ffi \
        \
    && make -j "$(nproc)" install \
    \
    && cd "$WORKDIR/python3" \
    && ./configure \
        --build="$GNU_ARCH" \
        --enable-loadable-sqlite-extensions \
        --enable-shared \
        --with-system-expat \
        --with-system-ffi \
        \
    && make -j "$(nproc)" install \
    \
    && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' \
        | tr ',' '\n' \
        | sort -u \
        | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
        | xargs -rt apk add --no-cache --virtual .python-rundeps \
    \
    && command -v python && python --version \
    && command -v python2 && python2 --version \
    && command -v python3 && python3 --version \
    \
    && cd "$WORKDIR" \
    && wget --output-document=get-pip.py 'https://bootstrap.pypa.io/get-pip.py' \
    && python get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        \
    && python2 get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        \
    && python3 get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        \
    && find /usr/local -depth \
        \( \
            \( -type d -a \( -name test -o -name tests \) \) \
            -o \
            \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
        \) -exec rm -rf '{}' + \
    && cd / \
    && rm -fr "$GNUPGHOME" "$WORKDIR" \
    && apk del .deps \
    && command -v pip && pip --version \
    && command -v pip2 && pip --version \
    && command -v pip3 && pip3 --version

RUN pip install virtualenv

# google cloud sdk install
ENV PATH /usr/lib/google-cloud-sdk/bin:$PATH
RUN set -eux \
    && mkdir -p /usr/lib/google-cloud-sdk \
    && cd /usr/lib/google-cloud-sdk \
    && wget --output-document=gcloud-sdk.tar.gz "$CLOUDSDK_URL" \
    && tar --extract --gzip --strip-components=1 --file=gcloud-sdk.tar.gz \
    && rm gcloud-sdk.tar.gz \
    && CLOUDSDK_PYTHON_SITEPACKAGES=1 \
    && ./install.sh \
        --usage-reporting false \
        --path-update true \
        --command-completion true \
        --rc-path=/.bashrc \
        --quiet \
        --additional-components $CLOUDSDK_COMPONENTS \
        \
### NOTE: this disables the origin and xsrf check for the admin server
#         if there is a better solution for this (docker networking related)
#         remove and educate/correct
    && sed -i "s/\(if origin\)/\1 and False /" /usr/lib/google-cloud-sdk/platform/google_appengine/google/appengine/tools/devappserver2/admin/admin_server.py \
    && sed -i "s/\(if self\.request\.method in \['PATCH', 'POST', 'PUT', 'DELETE'\]\)/\1 and False"/ /usr/lib/google-cloud-sdk/platform/google_appengine/google/appengine/tools/devappserver2/admin/admin_request_handler.py \
    && gcloud config set core/disable_usage_reporting true \
    && gcloud config set component_manager/disable_update_check true \
    && command -v gcloud && gcloud --version


VOLUME ["/root/.config"]
CMD ["gcloud"]
