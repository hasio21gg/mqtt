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
import logging
from logging import Formatter
import logging.handlers
import datetime
####################################################################################################
#Custom


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
cmdUtils.remove_command("count")
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
####################################################################################################
def on_connection_interrupted(connection, error, **kwargs):
    log.info("Connection interrupted. error: {}".format(error))


####################################################################################################
# Callback when an interrupted connection is re-established.
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
#
####################################################################################################
def on_resubscribe_complete(resubscribe_future):
        resubscribe_results = resubscribe_future.result()
        log.info("Resubscribe results: {}".format(resubscribe_results))

        for topic, qos in resubscribe_results['topics']:
            if qos is None:
                sys.exit("Server rejected resubscribe to topic: {}".format(topic))


####################################################################################################
# Callback when the subscribed topic receives a message
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
    # MQTT接続定義
    mqtt_connection = cmdUtils.build_mqtt_connection(on_connection_interrupted, on_connection_resumed)
    ################################################################################################
    # クライアントID定義
    ################################################################################################
    log.info("Connecting to {} with client ID '{}'...".format(
        cmdUtils.get_command(cmdUtils.m_cmd_endpoint), cmdUtils.get_command("client_id")))
    ################################################################################################
    # 接続
    ################################################################################################
    connect_future = mqtt_connection.connect()

    ################################################################################################
    # Future.result() waits until a result is available
    ################################################################################################
    connect_future.result()
    log.info("Connected!")

    #
    ################################################################################################
    #message_count = cmdUtils.get_command("count")
    message_topic = cmdUtils.get_command(cmdUtils.m_cmd_topic)
    message_string = cmdUtils.get_command(cmdUtils.m_cmd_message)

    ################################################################################################
    # Publish message to server desired number of times.
    # This step is skipped if message is blank.
    # This step loops forever if count was set to 0.
    ################################################################################################
    if message_string:
        #if message_count == 0:
        #    log.info ("Sending messages until program killed")
        #else:
        #    log.info ("Sending {} message(s)".format(message_count))
        print(message_string)
        (m1, m2) = str(message_string).split(',')
        dt_now       = datetime.datetime.now()
        message_json = {
            "COMPUTERNAME": m2,
            "OPERATE"     : m1,
            "OPEDATE"     : dt_now.strftime('%Y%m%d%H%M%S')
        }

        log.info("Publishing message to topic '{}': {}".format(message_topic, message_string))
        #message_json = json.dumps(message)
        #message_json = json.dumps(dict)
        mqtt_connection.publish(
            topic=message_topic,
            payload=json.dumps(message_json),
            qos=mqtt.QoS.AT_LEAST_ONCE)
        
        time.sleep(1)

    ################################################################################################
    # Disconnect
    ################################################################################################
    log.info("Disconnecting...")
    disconnect_future = mqtt_connection.disconnect()
    disconnect_future.result()
    log.info("Disconnected!")