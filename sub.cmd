@echo off
setlocal
::*******************************************************************************************************
:: システム名    ：
:: サブシステム名：バッチ処理
:: ファイル名    ：
::
:: 概要説明      ：
::------------------------------------------------------------------------------------------------------
:: 変更履歴：
:: 改定                         変更理由                                               担当者
:: 番号  変更日     バージョン  案件/問題   変更内容                                   氏名
::------------------------------------------------------------------------------------------------------
:: 001   2022-09-13 ver.1.0.0   202208-000  初版                                       橋本　英雄
::*******************************************************************************************************
    set $ROOT=%~dp0
    ::setlocal enabledelayedexpansion
    call %~dp0config.cmd
	if "%1" NEQ "" set JOBLOG=%$LOG%%FMTDATE%_%~n0.%1.log
	if "%2" NEQ "" set JOBLOG=%$LOG%%FMTDATE%_%~n0.%1_%2.log
	if "%3" NEQ "" set JOBLOG=%$LOG%%FMTDATE%_%~n0.%1_%2_%3.log

	set $MOVE=MOVE
	::set $MOVE=echo ■MOVE
	echo ================================================================================
    if "%1" EQU "PROC3" (
        goto PROC3
    )
	set PROCNAME=INIT_ERR
    CALL :MSGPROC 引数対応PROCがありません(%1)
    goto ENDPROC
:PROC3
	::----------------------------------------------------------------------------
	::----------------------------------------------------------------------------
    set PROCNAME=PROC3
	CALL :MSGPROC START
	set SUBSC1=sac/03a-job/+
	set SUBSC2=sac/03a-job/-force-exit-

	IF "%2"=="STOP" (
		CALL :PROC3A1 %SUBSC2%
	) else (
		CALL :PROC3A %SUBSC1%
	)

	set PROCNAME=PROC3
	CALL :MSGPROC END
    goto ENDPROC
:PROC3A1
	::----------------------------------------------------------------------------
	:: MQTT サブスクライブ
	:: AWS IoT Core トピックの受信 の途中終了
	::----------------------------------------------------------------------------
    set PROCNAME=PROC3A1
	set _SUBSC_=%1
	CALL :MSGPROC _SUBSC_ :[%_SUBSC_%]
	set PY=pub0.py
	set ENDP=--endpoint %$MQTT_BROKER_HOST%
	set PORT=--port %$MQTT_BROKER_PORT%
	set CAFI=--ca_file %$MQTT_CA__FILE%
	set KEYF=--key %$MQTT_KEY_FILE%
	set CERT=--cert %$MQTT_CERTFILE%
	set SEND=--sendlist %SENDFILE%
	set PROXY=--proxy_host %$MQTT_BROKER_PROXY%
	set PROXY_PORT=--proxy_port %$MQTT_BROKER_PROXY_PORT%
	set CLIENT=--client_id %COMPUTERNAME%_%PROCNAME%_%_SUBSC_%
	set TOPIC=--topic %_SUBSC_%
	set MSG=--message STOP
	set PYLOG=--logfile %$LOG%%PY%.log
	CALL :MSGPROC %PY%
	IF "%$MQTT_BROKER_PROXY%" EQU "" (
		CALL :MSGPROC ======_NO_PROXY_==================================================================
		set PUBCMD=%$PYTHON% %$PYTHONPROC%mqtt\%PY% %ENDP% %PORT% %CAFI% %KEYF% %CERT% %CLIENT% %TOPIC% %PYLOG%
	) ELSE (
		CALl :MSGPROC ======USE_PROXY_==================================================================
		set PUBCMD=%$PYTHON% %$PYTHONPROC%mqtt\%PY% %ENDP% %PROXY% %PROXY_PORT% %CAFI% %KEYF% %CERT% %CLIENT% %TOPIC% %PYLOG%
	)
	CALL :MSGPROC %PUBCMD%
	%PUBCMD%
	set RC=%ERRORLEVEL%
	IF %RC% NEQ 0 (
		CALL :MSGPROC ERROR!![%RC%]
	)
:PROC3A1_END
	goto :EOF
:PROC3A
	::----------------------------------------------------------------------------
	:: MQTT サブスクライブ
	:: AWS IoT Core トピックの受信
	::----------------------------------------------------------------------------
    set PROCNAME=PROC3A
	set _SUBSC_=%1
	CALL :MSGPROC _SUBSC_ :[%_SUBSC_%]
	set PY=sub2.py
	set ENDP=--endpoint %$MQTT_BROKER_HOST%
	set PORT=--port %$MQTT_BROKER_PORT%
	set CAFI=--ca_file %$MQTT_CA__FILE%
	set KEYF=--key %$MQTT_KEY_FILE%
	set CERT=--cert %$MQTT_CERTFILE%
	set SEND=--sendlist %SENDFILE%
	set PROXY=--proxy_host %$MQTT_BROKER_PROXY%
	set PROXY_PORT=--proxy_port %$MQTT_BROKER_PROXY_PORT%
	set CLIENT=--client_id %COMPUTERNAME%_%PROCNAME%_%_SUBSC_%
	set TOPIC=--topic %_SUBSC_%
	set PYLOG=--logfile %$LOG%%PY%.log
	CALL :MSGPROC %PY%
	IF "%$MQTT_BROKER_PROXY%" EQU "" (
		CALL :MSGPROC ======_NO_PROXY_==================================================================
		set SUBCMD=%$PYTHON% %$PYTHONPROC%mqtt\%PY% %ENDP% %PORT% %CAFI% %KEYF% %CERT% %CLIENT% %TOPIC% %PYLOG%
	) ELSE (
		CALl :MSGPROC ======USE_PROXY_==================================================================
		set SUBCMD=%$PYTHON% %$PYTHONPROC%mqtt\%PY% %ENDP% %PROXY% %PROXY_PORT% %CAFI% %KEYF% %CERT% %CLIENT% %TOPIC% %PYLOG%
	)
	CALL :MSGPROC %SUBCMD%
	%SUBCMD%
	set RC=%ERRORLEVEL%
	IF %RC% NEQ 0 (
		CALL :MSGPROC ERROR!![%RC%]
	)
:PROC3A_END
	goto :EOF
:MSGPROC
	::----------------------------------------------------------------------------
	:: メッセージログ出力
	::----------------------------------------------------------------------------
	set MESSAGE=%1 %2 %3 %4 %5 %6 %7 %8 %9
	set DT=%DATE:~-10%
	set TM0=%TIME: =0%
	IF "%LVL%"=="" set LVL=INFO
	echo %DT% %TM0:~,8% [%LVL%][%PROCNAME%] %MESSAGE% 2>&1 | cscript //Nologo ZTEE.vbs >> %JOBLOG%
	set LVL=
	goto :EOF
:STARTTM
	::----------------------------------------------------------------------------
	::----------------------------------------------------------------------------
	set T=%TIME: =0%
	set H=%T:~0,2%
	set M=%T:~3,2%
	set S=%T:~6,2%
	set C=%T:~9,2%
	::先頭が0の数値が8進数として扱われないようにするための処理
	set /a H=1%H%-100,M=1%M%-100,S=1%S%-100,C=1%C%-100
	goto :EOF
:ENDTM
	::----------------------------------------------------------------------------
	::----------------------------------------------------------------------------
	set T1=%TIME: =0%
	set H1=%T1:~0,2%
	set M1=%T1:~3,2%
	set S1=%T1:~6,2%
	set C1=%T1:~9,2%
	::先頭が0の数値が8進数として扱われないようにするための処理
	set /a H1=1%H1%-100,M1=1%M1%-100,S1=1%S1%-100,C1=1%C1%-100

	rem 処理時間の計算
	set /a H2=H1-H,M2=M1-M
	if %M2% LSS 0 set /a H2=H2-1,M2=M2+60
 	set /a S2=S1-S
	if %S2% LSS 0 set /a M2=M2-1,S2=S2+60
	set /a C2=C1-C
	if %C2% LSS 0 set /a S2=S2-1,C2=C2+100
	if %C2% LSS 10 set C2=0%C2%
	set /a SS=H2*60*60+M2*60+S2
	CALL :MSGPROC 開始時刻：%T%
	CALL :MSGPROC 終了時刻：%T1%
	CALL :MSGPROC 処理時間：%H2%h %M2%m %S2%.%C2%s
	CALL :MSGPROC 処理秒数：%SS%s
	goto :EOF
:ENDEXIT
	::----------------------------------------------------------------------------
	exit
:ENDPROC
	::----------------------------------------------------------------------------
