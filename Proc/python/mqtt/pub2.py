#!/usr/bin/python
# -*- coding: utf-8 -*-

import paho.mqtt.client as mqtt
import ssl

host = 'localhost'
port = 8883
### パスワード認証を使用する時に使用する
#username = 'mqtt'
#password = 'mqtt'
### SSL
port = 8883
cacert = '..\certs\mqtt_ca.crt'
clientCert = '..\certs\client.crt'
clientKey = '..\certs\client.key'

topic = 'paho/mqtt'
message = 'test message'

def on_connect(client, userdata, flags, respons_code):
    """broker接続時のcallback関数
    """
    print('status {0}'.format(respons_code))
    client.publish(topic, message)

def on_publish(client, userdata, mid):
    """メッセージをpublishした後のcallback関数
    """
    client.disconnect()

if __name__ == '__main__':
    ### インスタンス作成時にprotocol v3.1.1を指定
    client = mqtt.Client(protocol=mqtt.MQTTv311)
    ### パスワード認証を使用する時に使用する
    #client.username_pw_set(username, password=password)
    ### SSL
    client.tls_set(cacert,
        certfile = clientCert,
        keyfile = clientKey,
        tls_version = ssl.PROTOCOL_TLSv1_2)
    client.tls_insecure_set(True)

    ### callback function
    client.on_connect = on_connect
    client.on_publish = on_publish

    client.connect(host, port=port, keepalive=60)
    client.loop_forever()