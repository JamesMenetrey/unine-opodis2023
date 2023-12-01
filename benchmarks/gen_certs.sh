WORKDIR=$(pwd)
# setup a few certificates to test
mkdir -p certs
cd certs

# create ca
STANDARD_CERT_VALUES="/C=CH/ST=NE/L=NE/O=Unine/OU=CS"
HOSTNAME=$1
HOSTNAME=${HOSTNAME:-$(hostname)}

openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 365 -key ca.key -out ca.crt -subj "$STANDARD_CERT_VALUES/CN=ca"

# create server cert
openssl genrsa -out server.key 2048
openssl req -out server.csr -key server.key -new -subj "$STANDARD_CERT_VALUES/CN=$HOSTNAME"
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365

# create server localhost cert
openssl genrsa -out server_lo.key 2048
openssl req -out server_lo.csr -key server_lo.key -new -subj "$STANDARD_CERT_VALUES/CN=localhost"
openssl x509 -req -in server_lo.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server_lo.crt -days 365

# create server invalid cert
openssl genrsa -out server_invalid.key 2048
openssl req -out server_invalid.csr -key server_invalid.key -new -subj "$STANDARD_CERT_VALUES/CN=invalidhostname"
openssl x509 -req -in server_invalid.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server_invalid.crt -days 365

# create server expired cert
openssl genrsa -out server_expired.key 2048
openssl req -out server_expired.csr -key server_expired.key -new -subj "$STANDARD_CERT_VALUES/CN=localhost"
openssl x509 -req -in server_expired.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server_expired.crt -days 0

# create client certs
openssl genrsa -out pub_client.key 2048
openssl req -out pub_client.csr -key pub_client.key -new -subj "$STANDARD_CERT_VALUES/CN=$HOSTNAME"
openssl x509 -req -in pub_client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out pub_client.crt -days 365

openssl genrsa -out sub_client.key 2048
openssl req -out sub_client.csr -key sub_client.key -new -subj "$STANDARD_CERT_VALUES/CN=$HOSTNAME"
openssl x509 -req -in sub_client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out sub_client.crt -days 365

# create expired client cert
openssl genrsa -out client_expired.key 2048
openssl req -out client_expired.csr -key client_expired.key -new -subj "$STANDARD_CERT_VALUES/CN=$HOSTNAME"
openssl x509 -req -in client_expired.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client_expired.crt -days 0

# create second ca
openssl genrsa -out other_ca.key 2048
openssl req -new -x509 -days 365 -key other_ca.key -out other_ca.crt -subj "$STANDARD_CERT_VALUES/CN=other_ca"

# create server cert signed by second ca
openssl genrsa -out server_other_ca.key 2048
openssl req -out server_other_ca.csr -key server_other_ca.key -new -subj "$STANDARD_CERT_VALUES/CN=localhost"
openssl x509 -req -in server_other_ca.csr -CA other_ca.crt -CAkey other_ca.key -CAcreateserial -out server_other_ca.crt -days 365

# create client cert signed by second ca
openssl genrsa -out client_other_ca.key 2048
openssl req -out client_other_ca.csr -key client_other_ca.key -new -subj "$STANDARD_CERT_VALUES/CN=$HOSTNAME"
openssl x509 -req -in client_other_ca.csr -CA other_ca.crt -CAkey other_ca.key -CAcreateserial -out client_other_ca.crt -days 365

# delete all certificate signing requests
rm *.csr

cd $WORKDIR