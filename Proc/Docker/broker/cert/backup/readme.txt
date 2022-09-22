#秘密鍵
#openssl genrsa -des3 -out ca.key 2048
#CA証明書
#openssl req -new -x509 -days 3650 -key ca.key -out ca.crt
#サーバー証明書
#openssl genrsa -out server.key 2048
#CSRファイル
#openssl req -new -out server.csr -key server.key
#CERTファイル
#openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key

export duration=3650

#--------------------------------------------------------------------------------
#Generate a certificate authority certificate and key.
#--------------------------------------------------------------------------------
#C=JP/S=Toyama/L=Takaoka/ON=STHDG/OU=STHDG/CN=broker//
#passphrase=password
#--------------------------------------------------------------------------------
openssl req -new -x509 -days $duration -extensions v3_ca -keyout ca.key -out ca.crt

##########
# STEP1  #
##########
#Generate a server key.
openssl genrsa -des3 -out server.key 2048

#Generate a server key without encryption.
#openssl genrsa -out server.key 2048

#Generate a certificate signing request to send to the CA.
openssl req -out server.csr -key server.key -new

#Send the CSR to the CA, or sign it with your CA key:
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days $duration
#--------------------------------------------------------------------------------
#Generate a client key.
#--------------------------------------------------------------------------------
#openssl genrsa -des3 -out client.key 2048
openssl genrsa -out client.key 2048

#Generate a certificate signing request to send to the CA.
openssl req -out client.csr -key client.key -new

#Send the CSR to the CA, or sign it with your CA key:
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out client.crt -days $duration


# Certificate based SSL/TLS Support
mkdir -p /ssl/mqtt

cp /mosquitto/cert/ca.crt /ssl/mqtt/
cp /mosquitto/cert/server.key /ssl/mqtt/
cp /mosquitto/cert/server.crt /ssl/mqtt/

chown -R mosquitto:mosquitto /ssl/mqtt
chmod 0700 /ssl/mqtt
chmod 0600 /ssl/mqtt/*

drwx------    2 mosquitt mosquitt      4096 Sep 21 03:56 mqtt

-rw-------    1 mosquitt mosquitt      1322 Sep 21 03:56 ca.crt
-rw-------    1 mosquitt mosquitt      1200 Sep 21 03:58 server.crt
-rw-------    1 mosquitt mosquitt      1675 Sep 21 03:56 server.key


