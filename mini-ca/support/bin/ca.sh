#!/bin/sh
set -x
SSL_CMD="openssl"

# ca config
CA_NAME="root"
CA_CONF="${CA_ROOT}/support/${CA_NAME}.conf"

init_ca() {
    # prepare ca
    mkdir -p "${3}/out" \
    && cd "${3}/out" \
    && mkdir -p certs db private \
    && touch db/index \
    && "${1}" rand -hex 16 > db/serial \
    && echo 1001 > db/crlnumber \
    && "${1}" req \
        -config "${CA_CONF}" \
        -extensions ca_ext \
        -keyout "private/${2}.key" \
        -x509 -new -days 3650 -nodes -out "${2}.crt" \
    && "${1}" ca -gencrl \
        -config "${4}" \
        -out "$crl/{2}.crl"
}

if [ ! -d "${CA_ROOT}/${CA_NAME}.crt" ] ; then 
    init_ca "${SSL_CMD}" "${CA_NAME}" "${CA_ROOT}" "${CA_CONF}"
else
    echo "USING EXISTING CERTIFACTE AUTHORITY"
fi

# user input
DOMAIN_NAME='example.com'
if [ $1 ] ; then
    DOMAIN_NAME=$1
else
    read -p 'domain: ' DOMAIN_NAME
fi
DOMAIN_NAME=$(echo "${DOMAIN_NAME}" | tr '[:upper:]' '[:lower:'])
export DOMAIN_NAME

DOMAIN_OUT="${CA_ROOT}/out/server/${DOMAIN_NAME}"
mkdir -p "${DOMAIN_OUT}" \
&& cd "${CA_ROOT}/out" \
&& pwd

openssl req \
    -new \
    -out "${DOMAIN_OUT}/server.csr" \
    -keyout "${DOMAIN_OUT}/server.key" \
    -config /dev/stdin<<END
name=${DOMAIN_NAME}

[req]
prompt              = no
encrypt_key         = no
distinguished_name  = dn
req_extensions      = v3ext
default_bits        = 4069

[dn]
countryName         = "CA"
organizationName    = \${name}
commonName          = DEVELOPMENT: \${name}
emailAddress        = support@\${name}

[v3ext]
basicConstraints    = CA:false
keyUsage            = nonRepudiation,digitalSignature,keyEncipherment
subjectAltName      = DNS:*.\${name},DNS:\${name}.local,DNS:localhost
END

openssl req \
    -text \
    -in "${DOMAIN_OUT}/server.csr"

openssl ca \
    -config "${CA_CONF}" \
    -in "${DOMAIN_OUT}/server.csr" \
    -out "${DOMAIN_OUT}/server.crt"

openssl verify \
    -x509_strict \
    -purpose sslserver \
    -CAfile "${CA_ROOT}/out/${CA_NAME}.crt" \
    "${DOMAIN_OUT}/server.crt"
