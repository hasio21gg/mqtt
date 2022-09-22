import os
import sys
import paho.mqtt.client as mqtt # MQTTのライブラリをimportする
from time import sleep

# クライアントが接続されサーバ接続を示すCONNACKを受信したときの処理
# ブローカに接続できたときの処理
def on_connect(client, userdata, flags,rc):
    print("Connected with result code" + str(rc))

# ブローカが切断したときの処理 
def on_disconnect(client, userdata, rc):
    print("Unexpected disconnection.")

#
def on_message(client, userdata, msg):
    print(msg.topic + " " + str(msg.payload))

# パブリッシュが完了したときの処理
def on_publish(client, userdata, mid):
    print("publish] {0}".format(mid))

def main():
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_disconnect = on_disconnect
    client.on_message = on_message
    client.on_publish = on_publish

    client.tls_set("ca.crt")
    mqtt_broker_host = os.environ['MQTT_BROKER_HOST']
    print(f'MQTT BROKER: {mqtt_broker_host}')
    #client.connect(mqtt_broker_host , 1883, 60)
    client.connect(mqtt_broker_host , 8883, 60)

    
    #client.publish(f"topic/1", "Hello!!", 0, False)

    #client.loop_forever()
    client.loop_start()

    #while True:
    #topic_index = int(sys.argv[1])
    topic_index = 1
    #while True:
    #    #client.publish(f"topic/{topic_index}","Hello, Drone!",0, True)
    while True:
        mesg = f"Helo{topic_index}"
        print(mesg)
        client.publish(f"topic/{topic_index}", mesg, 0, True )
        topic_index +=1
        sleep(3)
    
if __name__ == '__main__':
    main()
