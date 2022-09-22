cd /mosquitto/cert
export duration=3650

#STEP1
openssl genrsa -des3 -out ca.key 2048

#STEP2
openssl req -new -x509 -days $duration -key ca.key -out ca.crt

#STEP3
openssl genrsa -out server.key 2048

#STEP4
openssl req -new -out server.csr -key server.key

#STEP5
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days $duration

cp /mosquitto/cert/ca.crt /ssl/mqtt/
cp /mosquitto/cert/server.key /ssl/mqtt/
cp /mosquitto/cert/server.crt /ssl/mqtt/

chown -R mosquitto:mosquitto /ssl/mqtt
chmod 0700 /ssl/mqtt
chmod 0600 /ssl/mqtt/*


cp /mosquitto/cert/ca.crt /ssl/mosquitto/
cp /mosquitto/cert/broker.key /ssl/mosquitto/
cp /mosquitto/cert/broker.crt /ssl/mosquitto/

cd /ssl/mosquitto
/mosquitto/cert/gen.sh


cp /ssl/mosquitto/* /mosquitto/cert
chmod +w /mosquitto/cert/*

chown -R mosquitto:mosquitto /ssl/mosquitto
chmod 0700 /ssl/mosquitto
chmod 0600 /ssl/mosquitto/*

# ca.crt     ===> pub:/mosquitto/cert
# broker.key ===> pub:/mosquitto/cert

# broker.crt ===> <root>: broker.crt
# broker.key ===> <root>: broker.key
# ca.crt     ===> <root>: ca.crt
