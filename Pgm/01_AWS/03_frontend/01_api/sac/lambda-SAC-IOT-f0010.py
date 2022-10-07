####################################################################################################
# システム名    ：
# サブシステム名：
# ファイル名    ：
#
# 概要説明      ：
####################################################################################################
# 変更履歴      ：
# 改定                         変更理由                                               担当者
# 番号  変更日     バージョン  案件/問題   変更内容                                   氏名
# 001   2022-09-30 ver.1.0.0   202209R001  初版                                       橋本　英雄
####################################################################################################
# -*- coding:utf-8 -*-
import json
import boto3
import os
import time
import logging
import re
import ast
####################################################################################################
#ロギング設定
LOGLEVEL = int(os.environ['LOGLEVEL'])
logging.basicConfig(format='%(asctime)s', datefmt='%Y/%m/%d')
log = logging.getLogger()
log.setLevel(LOGLEVEL)
log.info("boto3     :" + boto3.__version__)
####################################################################################################
# 関数名：lambda_handler
# 機能　：ルールを無効化・有効化
# 引数　：event, context
# 戻り値：終了コード HTTP 200 正常
####################################################################################################
# S3 constant
S3_OUTPUT = os.environ['S3BUCKET']

def lambda_handler(event, context):
    try:
        log.debug(str(os.environ))
        log.debug("event:"+str(event))
        #
        bucket     =  S3_OUTPUT
        methodname = "put_object"
        prefix     = event["S3PREFIX"]
        filename   = event["RESFILE"]
        presigned_url = get_presigned_url (methodname, bucket, prefix, filename)
        #
        message_topic = event["TOPIC"]
        sub2_topic = event["RECVTOPIC"]
        #
        payload = {
            "CLIENTID"    : event["clientid"],
            "RESPATH"     : event["RESPATH"],
            "RESFILE"     : event["RESFILE"],
            "RECVTOPIC"   : event["RECVTOPIC"],
            "PRESIGNEDURL": presigned_url
        }
        #
        publish_to(
            sub2_topic,
            payload
        )
        #
        responseBody={
                      "status":"OK",
                      "result": payload
                      }
        #戻り値設定
        return {
            "statusCode": 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET',
                'Access-Control-Allow-Origin': '*'
            },
            "body": json.dumps(responseBody),
            "isBase64Encoded": False
        }
    except Exception as e:
        # 例外処理
        log.error(e)
        raise e
####################################################################################################
# 関数名：publish_to
# 機能　：MQTTにパブリッシュする
# 引数　：
# 戻り値：
####################################################################################################
def publish_to (pi_topic, pi_payload):
    try:
        iot = boto3.client('iot-data')
        iot.publish(
            topic=pi_topic,
            qos=0,
            payload=json.dumps(pi_payload, ensure_ascii=False)
        )
        log.debug(f"Publish to AWS IoT: OK {pi_topic}")
    except Exception as e:
        # 例外処理
        raise e
################################################################################################
# 関数名：get_presigned_url
# 機能　：指定されたs3の署名付きURLを発行する関数
# 引数　：pi_methodname : 実行モードを指定(put_object:オブジェクト配置、get_object:オブジェクト取得）
#         pi_bucket     : S3バケット名 を指定
#         pi_prefix     : 当該S3のプリフィックス を指定
#         pi_filename   : 対象のオブジェクト を指定
# 戻り値：署名付きURL
################################################################################################
def get_presigned_url (pi_methodname, pi_bucket, pi_prefix, pi_filename):

    try:
        s3 = boto3.client('s3')
        params = {}
         #S3署名付きURLの取得s
        # デフォルトオプション
        #  ExpiresIn=600 URLの有効時限(秒)
        #  HttpMethod=None HTTPメソッド
        presigned_url = s3.generate_presigned_url(
            ClientMethod=pi_methodname,
            Params={
                "Bucket": pi_bucket,
                "Key": pi_prefix + pi_filename
            },
            ExpiresIn=600
        )
        
        log.debug("return_url   :" + presigned_url)
        log.debug("filename     :" + pi_filename)
        return presigned_url
    except Exception as e:
        # 例外処理
        raise e
