::*******************************************************************************************************
:: システム名    ：
:: サブシステム名：バッチ処理
:: ファイル名    ：
::
:: 概要説明      ：
::
::------------------------------------------------------------------------------------------------------
:: 変更履歴：
:: 改定                         変更理由                                               担当者
:: 番号  変更日     バージョン  案件/問題   変更内容                                   氏名
::------------------------------------------------------------------------------------------------------
:: 001   2022-09-13 ver.1.0.0   202208-000  初版                                       橋本　英雄
::*******************************************************************************************************
    echo ================================================================================
    echo ■初期設定
    set $ROOT=%~dp0
    set $PROC=%$ROOT%Proc\
    set $DATA=%$ROOT%Data\
    set $RECV=%$DATA%Recv\
    set $RECVBK=%$DATA%Recv\Backup\
    set $SEND=%$DATA%Send\
    set $SENDBK=%$DATA%Send\Backup\
    set $WORK=%$DATA%Work\
    set $ERRDATA=%$DATA%Error\
    set $LOG=%$ROOT%Log\
    set DT=%DATE:~-10%
	set TM=%TIME: =0%
	set FMTDATE=%DT:~0,4%%DT:~5,2%%DT:~8,2%
	set FMTTIME=%TM:~0,2%%TM:~3,2%%TM:~6,2%
	set JOBDATE=%DT:~0,4%%DT:~5,2%%DT:~8,2%_%FMTTIME%
    set PROC3A1_WAIT=1
    set PROC3A1_MAXWAIT=1
    set $AWS_MQTT_ENDPOINT_DEV=a2kihu57t8ntyn-ats.iot.ap-northeast-1.amazonaws.com
    set $AWS_MQTT_ENDPOINT_STG=a3knk8fpg0o81-ats.iot.ap-northeast-1.amazonaws.com
    set $AWS_MQTT_ENDPOINT_PRD=a2mwtccjyq0i11-ats.iot.ap-northeast-1.amazonaws.com
    set $STHDG_PROXY=proxy.sthdg.local
    set $STHDG_PROXY_PORT=8080
    IF NOT EXIST "%$RECVBK%\*" (
        mkdir %$RECVBK%
    )
    IF NOT EXIST "%$SENDBK%\*" (
        MKDIR %$SENDBK%
    )
    goto %COMPUTERNAME%
    goto CONFIG_ERR
:D08591
    echo ================================================================================
    echo ■端末別設定
    set $SRCLOC=\\192.168.254.96
    set $DBR_SEND=D:\ap99999\mqtt\SendPath\
    set $DBR_RECV=D:\ap99999\mqtt\RecvPath\
    set $DBR_SUBSC_SEND=%$DBR_SEND%SUBSC\
    set $DBR_SUBSC_RECV=%$DBR_RECV%SUBSC\
    set $MQTT_BROKER_HOST=localhost
    set $MQTT_BROKER_PORT=8883
    set $MQTT_BROKER_PROXY=
    set $MQTT_BROKER_PROXY_PORT=
    set $MQTT_CA__FILE=%$ROOT%ca.crt
    set $MQTT_KEY_FILE=%$ROOT%broker.key
    set $MQTT_CERTFILE=%$ROOT%broker.crt
    
    set $MQTT_BROKER_HOST=%$AWS_MQTT_ENDPOINT_DEV%
    set $MQTT_BROKER_PROXY=%$STHDG_PROXY%
    set $MQTT_BROKER_PROXY_PORT=%$STHDG_PROXY_PORT%
    set $MQTT_CA__FILE=%$ROOT%.certs\AmazonRootCA1.pem
    set $MQTT_KEY_FILE=%$ROOT%.certs\811173985eb4ec9f83944260691db567d29c23a8501cc424aae825b9e2b60c01-private.pem.key
    set $MQTT_CERTFILE=%$ROOT%.certs\811173985eb4ec9f83944260691db567d29c23a8501cc424aae825b9e2b60c01-certificate.pem.crt
    goto CONFIG_1
:D09068
    echo ================================================================================
    echo ■端末別設定
    set $SRCLOC=\\192.168.254.96
    set $DBR_SEND=D:\Dbrg\AutoTransfer\SendPath\
    set $DBR_RECV=D:\Dbrg\AutoTransfer\RecvPath\
    set $DBR_SUBSC_SEND=%$DBR_SEND%SUBSC\
    set $DBR_SUBSC_RECV=%$DBR_RECV%SUBSC\
    goto CONFIG_1
:D08757
    echo ================================================================================
    echo ■端末別設定
    set $DBR_RECV=D:\Dbrg\AutoTransfer\RecvPath\
    set $DBR_SUBSC_RECV=%$DBR_RECV%SUBSC\
    set $MQTT_BROKER_HOST=%$AWS_MQTT_ENDPOINT_DEV%
    set $MQTT_BROKER_PORT=
    set $MQTT_BROKER_PROXY=%$STHDG_PROXY%
    set $MQTT_BROKER_PROXY_PORT=%$STHDG_PROXY_PORT%
    set $MQTT_CA__FILE=%$ROOT%.certs\AmazonRootCA1.pem
    set $MQTT_KEY_FILE=%$ROOT%.certs\811173985eb4ec9f83944260691db567d29c23a8501cc424aae825b9e2b60c01-private.pem.key
    set $MQTT_CERTFILE=%$ROOT%.certs\811173985eb4ec9f83944260691db567d29c23a8501cc424aae825b9e2b60c01-certificate.pem.crt
    goto CONFIG_1
:CONFIG_1
    ::TEST
    set BEF_PROC2B_TOPIC1_001=20220705_PM_内
    set AFT_PROC2B_TOPIC1_001=03c
    set BEF_PROC2B_TOPIC2_001=20220617_405ｶﾈﾂﾊｯﾎﾟｳｻﾞｲ
    set AFT_PROC2B_TOPIC2_001=b0001
    set BEF_PROC2B_TOPIC2_002=20220617_406ｶﾈﾂﾊｯﾎﾟｳｻﾞｲ
    set AFT_PROC2B_TOPIC2_002=b0002
    set BEF_PROC2B_TOPIC2_003=20220617_407ｶﾈﾂﾊｯﾎﾟｳｻﾞｲ
    set AFT_PROC2B_TOPIC2_003=b0003
    set BEF_PROC2B_TOPIC2_004=20220617_408ｶﾈﾂﾊｯﾎﾟｳｻﾞｲ
    set AFT_PROC2B_TOPIC2_004=b0004
    set BEF_PROC2B_TOPIC2_005=20220617_409ｶﾈﾂﾊｯﾎﾟｳｻﾞｲ
    set AFT_PROC2B_TOPIC2_005=b0005
    set BEF_PROC2B_TOPIC2_006=20220617_410ｶﾈﾂﾊｯﾎﾟｳｻﾞｲ
    set AFT_PROC2B_TOPIC2_006=b0006
    set BEF_PROC2B_TOPIC2_007=20220617_411ｶﾈﾂﾊｯﾎﾟｳｻﾞｲ
    set AFT_PROC2B_TOPIC2_007=b0007
    set BEF_PROC2B_TOPIC2_008=20220617_412ｶﾈﾂﾊｯﾎﾟｳｻﾞｲ
    set AFT_PROC2B_TOPIC2_008=b0008
    set BEF_PROC2B_TOPIC3_001=Input0_Camera
    set AFT_PROC2B_TOPIC3_001=dl
    set BEF_PROC2B_TOPIC3_002=.jpg
    set AFT_PROC2B_TOPIC3_002=
    set BEF_PROC2B_TOPIC3_003=foo_0
    set AFT_PROC2B_TOPIC3_003=dl2
    set BEF_PROC2B_TOPIC3_004=.jpeg
    set AFT_PROC2B_TOPIC3_004=
    ::set BEF_PROC2B_TOPIC3_001=Input0_Camera1
    ::set AFT_PROC2B_TOPIC3_001=DL001
    ::set BEF_PROC2B_TOPIC3_002=Input0_Camera2
    ::set AFT_PROC2B_TOPIC3_002=DL002
    ::set BEF_PROC2B_TOPIC3_003=Input0_Camera3
    ::set AFT_PROC2B_TOPIC3_003=DL003
    ::set BEF_PROC2B_TOPIC3_004=Input0_Camera4
    ::set AFT_PROC2B_TOPIC3_004=DL004
    ::set BEF_PROC2B_TOPIC3_005=Input0_Camera5
    ::set AFT_PROC2B_TOPIC3_005=DL005
    ::set BEF_PROC2B_TOPIC3_006=Input0_Camera6
    ::set AFT_PROC2B_TOPIC3_006=DL006
    ::set BEF_PROC2B_TOPIC3_007=Input0_Camera7
    ::set AFT_PROC2B_TOPIC3_007=DL007
    ::set BEF_PROC2B_TOPIC3_008=Input0_Camera8
    ::set AFT_PROC2B_TOPIC3_008=DL008
    ::set BEF_PROC2B_TOPIC3_009=Input0_Camera9
    ::set AFT_PROC2B_TOPIC3_009=DL009
    ::set BEF_PROC2B_TOPIC3_010=Input0_Camera10
    ::set AFT_PROC2B_TOPIC3_010=DL010
    set $COMPANY_TOPIC=SAC
    set $PYTHON=python
    set $PYTHONPROC=%$PROC%python\
    goto CONFIG_END
:CONFIG_ERR
    echo ================================================================================
    echo ?ｿｽ?ｿｽERROR
    exit /B:9
:CONFIG_END
    exit /B:0