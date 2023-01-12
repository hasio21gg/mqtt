####################################################################################################
# システム名    ：
# サブシステム名：
# ファイル名    ：
# 概要説明      ：
####################################################################################################
# 変更履歴      ：
# 改定                         変更理由                                               担当者
# 番号  変更日     バージョン  案件/問題   変更内容                                   氏名
# 001   2022-09-30 ver.1.0.0   202208R062  初版                                       橋本　英雄
####################################################################################################
# -*- coding: utf-8 -*-
from awscrt import mqtt
import sys
import threading
import time
from uuid import uuid4
import json
####################################################################################################
# Custom
import os
import csv
from datetime import datetime
import re
import logging
from logging import Formatter
import logging.handlers
####################################################################################################
# Parse arguments
import command_line_utils;
cmdUtils = command_line_utils.CommandLineUtils("PubSub - Send and recieve messages through an MQTT connection.")
cmdUtils.add_common_mqtt_commands()
cmdUtils.add_common_topic_message_commands()
cmdUtils.add_common_proxy_commands()
cmdUtils.add_common_logging_commands()
cmdUtils.register_command("key", "<path>", "Path to your key in PEM format.", True, str)
cmdUtils.register_command("cert", "<path>", "Path to your client certificate in PEM format.", True, str)
cmdUtils.register_command("port", "<int>", "Connection port. AWS IoT supports 443 and 8883 (optional, default=auto).", type=int)
cmdUtils.register_command("client_id", "<str>", "Client ID to use for MQTT connection (optional, default='test-*').", default="test-" + str(uuid4()))
cmdUtils.register_command("count", "<int>", "The number of messages to send (optional, default='10').", default=10, type=int)
####################################################################################################
# User's Custumize★
cmdUtils.remove_command("topic")
cmdUtils.remove_command("message")
cmdUtils.register_command("sendlist", "<path>", "★送信ファイルリストを指定する", True, str)
cmdUtils.register_command("logfile" , "<path>", "★ログファイルを指定する", True,str)
####################################################################################################
# Needs to be called so the command utils parse the commands
cmdUtils.get_args()

received_count = 0
received_all_event = threading.Event()
####################################################################################################
# ログ
logfile = cmdUtils.get_command("logfile")
log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)
h0 = logging.StreamHandler()
h1 = logging.handlers.TimedRotatingFileHandler(
    filename=logfile,
    when='D',
    interval=1,
    backupCount=2)
formatter = Formatter('%(asctime)s [%(levelname)-8s][%(lineno)06d] %(message)s',datefmt='%Y/%m/%d %H:%M:%S')
h0.setFormatter(formatter)
h1.setFormatter(formatter)
h0.setLevel(logging.INFO)
h1.setLevel(logging.DEBUG)
log.addHandler(h0)
log.addHandler(h1)
####################################################################################################
# Callback when connection is accidentally lost.
# コネクション喪失時コールバック
####################################################################################################
def on_connection_interrupted(connection, error, **kwargs):
    log.info("Connection interrupted. error: {}".format(error))

####################################################################################################
# Callback when an interrupted connection is re-established.
# コネクション中断時コールバック
####################################################################################################
def on_connection_resumed(connection, return_code, session_present, **kwargs):
    log.info("Connection resumed. return_code: {} session_present: {}".format(return_code, session_present))

    if return_code == mqtt.ConnectReturnCode.ACCEPTED and not session_present:
        log.info("Session did not persist. Resubscribing to existing topics...")
        resubscribe_future, _ = connection.resubscribe_existing_topics()

        # Cannot synchronously wait for resubscribe result because we're on the connection's event-loop thread,
        # evaluate result with a callback instead.
        resubscribe_future.add_done_callback(on_resubscribe_complete)

####################################################################################################
# Callback 
# 再サブスクライブ完了時コールバック
####################################################################################################
def on_resubscribe_complete(resubscribe_future):
        resubscribe_results = resubscribe_future.result()
        log.info("Resubscribe results: {}".format(resubscribe_results))

        for topic, qos in resubscribe_results['topics']:
            if qos is None:
                sys.exit("Server rejected resubscribe to topic: {}".format(topic))

####################################################################################################
# Callback when the subscribed topic receives a message
# サブスクライブ受信時
####################################################################################################
def on_message_received(topic, payload, dup, qos, retain, **kwargs):
    log.info("Received message from topic '{}': {}".format(topic, payload))
    global received_count
    received_count += 1
    if received_count == cmdUtils.get_command("count"):
        received_all_event.set()

####################################################################################################
# 主処理部
#
####################################################################################################
if __name__ == '__main__':

    sendlist = cmdUtils.get_command("sendlist")
    #log.info("Sendlist is {}".format(sendlist))
    log.info("Sendlist is {}".format(sendlist))
    with open(sendlist, 'r') as f:
        dread = csv.DictReader(f)
        dlist = [row for row in dread]
    json_text = json.dumps(dlist, ensure_ascii=False,)
    message_dict = json.loads(json_text)
    ################################################################################################
    #トピックは小文字・数字・ダッシュ
    #UTC時間を付与
    ################################################################################################
    for row in message_dict:
        dtstr = row['TIMESTAMP']
        (dtfmt, dtstr18) = ('%Y%m%d%H%M%S%f', dtstr + "0000") if len(dtstr) == 14 else ('%Y%m%d%H%M%S%f', dtstr) 
        dt = datetime.strptime(dtstr18, dtfmt)
        dtstr14 = datetime.strftime(dt, '%Y%m%d%H%M%S') 
        dtepoc = int(dt.timestamp())
        dtepoc_full = int(dt.timestamp() * 1000)
        #log.info(f"{dtstr18: <20} {dtstr14: <20} {dtepoc: <16} {dtepoc_full: <20} {dt}" )
        #row['DTFILEMODIFY'] = dtstr14
        row['OT_TIMESTAMP'] = dtepoc
        row['OT_TIMESTAMP_FULL'] = dtepoc_full
        row['OT_TIMEZONE'] = "Asia/Tokyo"
        #IoTCore置換テンプレートでは関数内にペイロードは参照できないのでここで分解する
        YEAR            = datetime.strftime(dt, '%Y') 
        MONTH           = datetime.strftime(dt, '%m') 
        DAY             = datetime.strftime(dt, '%d') 
        HOUR            = datetime.strftime(dt, '%H') 
        DATETIME        = datetime.strftime(dt, '%Y%m%d%H%M%S') 
        row['YEAR']     = YEAR
        row['MONTH']    = MONTH
        row['DAY']      = DAY
        row['HOUR']     = HOUR
        row['DATETIME'] = DATETIME
        topic = row['TOPIC'].lower()
        # topicは英字、数字、ダッシュのみ
        recvtopic = re.sub('([0-9a-zA-Z\-]+)/([0-9a-zA-Z\-]+)/.*'    , f'\\1/\\2-job/{dtepoc_full}', topic)
        
        s3_prefix = f"iot/{topic}year={YEAR}/month={MONTH}/day={DAY}/hour={HOUR}/datetime={DATETIME}/"
        row['TOPIC'] = topic
        row['RECVTOPIC'] = recvtopic
        row['S3PREFIX'] = s3_prefix
        
    message_json_count = len(message_dict)
    message_topic_recv_prefix = message_dict[0]["RECVTOPIC"]

    mqtt_connection = cmdUtils.build_mqtt_connection(on_connection_interrupted, on_connection_resumed)

    log.info("Connecting to {} with client ID '{}'...".format(
        cmdUtils.get_command(cmdUtils.m_cmd_endpoint), cmdUtils.get_command("client_id")))
    connect_future = mqtt_connection.connect()
    ################################################################################################
    # Future.result() waits until a result is available
    # コネクション確立待機
    ################################################################################################
    connect_future.result()
    log.info("Connected!")

    message_count = message_json_count
    message_string = ""

    ################################################################################################
    # Publish message to server desired number of times.
    # This step is skipped if message is blank.
    # This step loops forever if count was set to 0.
    if message_count == 0:
        log.info("Sending messages until program killed")
    else:
        log.info("Sending {} message(s)".format(message_count))

    publish_count = 1
    while (publish_count <= message_count) or (message_count == 0):
        json_row = message_dict[publish_count-1]
        message_string = json_row
        message_topic = json_row['TOPIC'].lower()
            
        log.info("Publishing message to topic '{}'".format(message_topic))
        message_json = json.dumps(message_string)
        mqtt_connection.publish(
            topic=message_topic,
            payload=message_json,
            qos=mqtt.QoS.AT_LEAST_ONCE)
        time.sleep(1)
        publish_count += 1

    ################################################################################################
    # Disconnect
    ################################################################################################
    log.info("Disconnecting...")
    disconnect_future = mqtt_connection.disconnect()
    disconnect_future.result()
    log.info("Disconnected!")
