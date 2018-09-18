FROM libressl

ENV CA_ROOT "/root/ca"
RUN set -ex && mkdir -p $CA_ROOT/out
VOLUME ["/root/ca/out"]

ENV PATH /root/ca/support/bin:$PATH
COPY "support" "/root/ca/support"
