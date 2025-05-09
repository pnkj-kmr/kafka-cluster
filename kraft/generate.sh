
# Generate Private Key and Self-Signed Cert

# cleaning up old files
rm ca.key ca.csr ca.crt kafka.p12 server.keystore.jks server.truststore.jks

# Generate private key
# openssl genpkey -algorithm RSA -out ca.key -aes256
openssl genrsa -out ca.key 4096

### Generate certificate signing request (CSR)
openssl req -new -key ca.key -out ca.csr -config openssl-san.cnf
# openssl req -new -key ca.key -out ca.csr -config openssl.cnf

### Generate self-signed certificate with SANs # 3000 days = 8 years
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt \
  -days 3000 -extensions v3_req -extfile openssl-san.cnf
# openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt \
#     -days 3000 -extensions v3_req -extfile openssl.cnf


# verify
openssl x509 -in ca.crt -noout -text


## Create PKCS12 Keystore

openssl pkcs12 -export \
  -in ca.crt \
  -inkey ca.key \
  -name kafka-broker \
  -out kafka.p12 \
  -password pass:123456789


## Convert PKCS12 to Java Keystore (keystore.jks)

keytool -importkeystore \
  -deststorepass 123456789 \
  -destkeypass 123456789 \
  -destkeystore server.keystore.jks \
  -srckeystore kafka.p12 \
  -srcstoretype PKCS12 \
  -srcstorepass 123456789 \
  -alias kafka-broker

## Create Truststore (truststore.jks)

keytool -import \
  -trustcacerts \
  -alias kafka-broker-cert \
  -file ca.crt \
  -keystore server.truststore.jks \
  -storepass 123456789 \
  -noprompt

