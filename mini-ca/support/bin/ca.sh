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
    && mkdir -p crl certs db ca \
    && touch db/index \
    && "${1}" rand -hex 16 > db/serial \
    && echo 1001 > db/crlnumber \
    && "${1}" req \
        -config "${CA_CONF}" \
        -keyout "ca/${2}.key" \
        -x509 -new -days 3650 -nodes -out "ca/${2}.crt" \
    && "${1}" x509 -in "ca/${2}.crt" -text \
    && "${1}" ca -gencrl \
        -config "${4}" \
        -out "crl/${2}.crl"
}

if [ -f "${CA_ROOT}/ca/${CA_NAME}.crt" ] ; then 
    echo "USING EXISTING CERTIFACTE AUTHORITY"
else
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
req_extensions      = req_ext
default_bits        = 4069

[dn]
countryName         = "CA"
organizationName    = "Development"
commonName          = DEVELOPMENT: \${name}
emailAddress        = support@\${name}

[req_ext]
basicConstraints    = CA:false
keyUsage            = dataEncipherment,digitalSignature,keyEncipherment,nonRepudiation
subjectAltName      = DNS:*.\${name},DNS:\${name}.local,DNS:localhost
END

if [ -f "${DOMAIN_OUT}/server.csr" ] ; then 
openssl req \
    -text \
    -in "${DOMAIN_OUT}/server.csr"

openssl ca \
    -config "${CA_CONF}" \
    -in "${DOMAIN_OUT}/server.csr" \
    -out "${DOMAIN_OUT}/server.crt"

openssl verify \
    -verbose \
    -x509_strict \
    -purpose sslserver \
    -CAfile "${CA_ROOT}/out/ca/${CA_NAME}.crt" \
    "${DOMAIN_OUT}/server.crt"
fi
