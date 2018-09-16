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
    && mkdir certs db private \
    && touch db/index \
    && "${1}" rand -hex 16 > db/serial \
    && echo 1001 > db/crlnumber \
    && "${1}" req \
        -config "${CA_CONF}" \
        -extensions ca_ext \
        -keyout "private/${2}.key" \
        -x509 -new -nodes -out "${2}.crt" \
    && "${1}" ca -gencrl \
        -config "${4}" \
        -out "${4}.crl"
}

if [ ! -a "${CA_ROOT}/root.crt" ] ; then 
    init_ca "${SSL_CMD}" "${CA_NAME}" "${CA_ROOT}" "${CA_CONF}"
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

DOMAIM_OUT="${CA_ROOT}/out/server/${DOMAIN_NAME}"
mkdir -p "${DOMAIM_OUT}" \
&& cd "${CA_ROOT}/out" \
&& pwd

openssl req -new \
    -out "${DOMAIM_OUT}/server.csr" -keyout "${DOMAIM_OUT}/server.key" \
    -config /dev/stdin <<END
name=${DOMAIN_NAME}

[req]
prompt              = no
distinguished_name  = dn
req_extensions      = ext
input_password      = \${name}
output_password     = \${name}
default_bits        = 4069

[dn]
countryName         = "CA"
organizationName    = \${name}
commonName          = DEVELOPMENT CERTIFICATE: \${name}
emailAddress        = support@\${name}

[ext]
subjectAltName      = DNS:*.\${name},DNS:\${name}.local,DNS:localhost
END

openssl ca \
    -config "${CA_CONF}" \
    -in "${DOMAIM_OUT}/server.csr" \
    -out "${DOMAIM_OUT}/server.crt"

openssl verify -purpose sslserver \
    -CAfile "${CA_ROOT}/out/${CA_NAME}.crt" \
    "${DOMAIM_OUT}/server.crt"
