@echo off
setlocal
::*******************************************************************************************************
:: システム名    ：
:: サブシステム名：バッチ処理
:: ファイル名    ：
::
:: 概要説明      ：
::https://qiita.com/yz2cm/items/8058d503a1b84688af09
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

	CALL %$ACTIVATE%
	
	set $MOVE=MOVE
	::set $MOVE=echo ■MOVE
	echo ================================================================================
    if "%1" EQU "PROC2" (
        goto PROC2
    )
    if "%1" EQU "PROC3" (
        goto PROC3
    )
	set PROCNAME=INIT_ERR
    CALL :MSGPROC 引数対応PROCがありません(%1)
    goto ENDPROC
:PROC3
	::----------------------------------------------------------------------------
	:: ITNWからリソースをプラットフォーム(AWSなど)へ可搬する
	:: 実装タイプとしてはPCファイルからの採取
	:: 採取１）PROC2Aへの対応
	:: MQTTでメッセージ送信(PUBLISH)し、S3署名URLを取得(SUBSCRIBE）、
	:: ペイロードをS3へ送信(HTTP)する
	::----------------------------------------------------------------------------
    set PROCNAME=PROC3
	CALL :MSGPROC START

	set SUBSC=PROC2A
	CALL :PROC3A %SUBSC%

	set SUBSC=PROC1A
	CALL :PROC3A %SUBSC%
    
	cscript %$ROOT%UtyMoveFile.vbs %$RECVBK% -1
	cscript %$ROOT%UtyDirDelete.vbs %$RECVBK% -10
	cscript %$ROOT%UtyMoveFile.vbs %$SENDBK% -1
	cscript %$ROOT%UtyDirDelete.vbs %$SENDBK% -30
	cscript %$ROOT%UtyMoveFile.vbs %$LOG% -1
	cscript %$ROOT%UtyDirDelete.vbs %$LOG% -10
	
	set PROCNAME=PROC3
    goto ENDPROC
:PROC3A
	echo ================================================================================
    set PROCNAME=PROC3A
	set _SUBSC_=%1
	CALL :MSGPROC _SUBSC_ :[%_SUBSC_%]

	::■ yyyymmddHHMMSSss_FPATが監視対象
	:: TXT以降に続く文字あっても対象になるので注意
	set FPAT=[0-9]*_%_SUBSC_%*.txt
	set SRCFIND=%$DBR_SUBSC_RECV%
	set WFILE=FILELIST3.txt
	set WORKFILE=%$WORK%%WFILE%
	set SFILE=FILELIST3_SEND.txt
	::set SENDFILE=%$WORK%%SFILE%
	set SENDHEAD=%$ROOT%filelist_PROC3.txt
	IF EXIST %WORKFILE% del /Q %WORKFILE%
	::IF EXIST %SENDFILE% del /Q %SENDFILE%

	::■ファイル一覧ヘッダー作成
	set GETSENDHEAD=
	SETLOCAL ENABLEDELAYEDEXPANSION
	FOR /F "eol=; delims=, tokens=1,2" %%I in (%SENDHEAD%) do (
		CALL :GET_SENDHEAD %%I %%J %_SUBSC_%
		IF "!GETSENDHEAD!" NEQ "" (
			CALL :MSGPROC FIND_HEAD_INFO[%_SUBSC_%]
			GOTO PROC3A_GETHEAD
		)
	)
	SETLOCAL DISABLEDELAYEDEXPANSION
	IF "%GETSENDHEAD%" EQU "" (
		CALL :MSGPROC WARN_NOT_FOUND_HEAD_FILES.[%_SUBSC_%]
		goto PROC3A_END
	)
:PROC3A_GETHEAD
	SETLOCAL DISABLEDELAYEDEXPANSION
	CALL :MSGPROC GETSENDHEAD: %GETSENDHEAD%
	
	::■ファイル一覧作成
	CALL :MSGPROC DIR /B %SRCFIND% /A-D %DIROPT%
	CALL :MSGPROC FINDSTR /R "%FPAT%"
	CALL :MSGPROC %WORKFILE%
	DIR /B %SRCFIND% /A-D %DIROPT% | FINDSTR /R /I "%FPAT%" > %WORKFILE%
	IF %ERRORLEVEL% NEQ 0 (
		CALL :MSGPROC NOT_FOUND_FILES SUBSCRIBE '%_SUBSC_%'.[%ERRORLEVEL%]
		goto PROC3A_END
	)
	set SUBSCLIST=%$DBR_SUBSC_RECV%
	set LISTS=0
	set RETCNTS=0
	SETLOCAL ENABLEDELAYEDEXPANSION
	FOR /F "eol=; tokens=1 delims=," %%I in (%WORKFILE%) do (
		set LOOPNAME=%%I
		::%LOOPNAME%から%_SUBSC_%は除去する
		CALL set LOOPNAME=%%LOOPNAME:%_SUBSC_%.TXT=%%
		set SENDFILE=%$WORK%!LOOPNAME!%SFILE%
		::遅延環境変数に格納を確認するためECHOを行う
		ECHO !SENDFILE!
		::ECHO %GETSENDHEAD%
		IF EXIST !SENDFILE! del /Q !SENDFILE!
		ECHO %GETSENDHEAD%>!SENDFILE!
		FOR /F "eol=; tokens=1,2,6,7 delims=," %%A IN (%$DBR_SUBSC_RECV%%%I) do (
			CALL :PROC3A1 %%A %%B %%C %%D !SENDFILE! %%I
			set /a LISTS+=1
		)
    	set PROCNAME=PROC3A
		CALL :MSGPROC [リスト件数:!LISTS!][ファイル数:!RETCNTS!]
		::■パブリッシュ
		IF !LISTS! EQU !RETCNTS! (
			CALL :MSGPROC パブリッシュ[!SENDFILE!]
			CALL :PROC3A2 !SENDFILE!
		)
		ECHO !RC!
    	set PROCNAME=PROC3A
		IF !RC! NEQ 0 (
			CALL :MSGPROC ERROR_PUBLISHED.[%_SUBSC_%][!RC!]
			move !SENDFILE! %$ERRDATA%
			goto PROC3A_END
		)
		::使用済みワークは削除する
		IF EXIST !SENDFILE! cscript %$ROOT%UtyFileBackUp.vbs !SENDFILE! %$SENDBK%
		::IF EXIST !SENDFILE! del /Q !SENDFILE!
    	::DBR受信トリガーファイルを移動する
		set RECVFILE=%$DBR_SUBSC_RECV%%%I
		cscript %$ROOT%UtyFileBackUp.vbs !RECVFILE! %$RECVBK%
		
		set LISTS=0
		set RETCNTS=0
	)
	::CALL :MSGPROC [リスト件数:%LISTS%][ファイル数:%RETCNTS%]
	SETLOCAL DISABLEDELAYEDEXPANSION

	::IF EXIST %WORKFILE% DEL %WORKFILE%
:PROC3A_END
	goto :EOF
:PROC3A1
	::----------------------------------------------------------------------------
	:: データブリッジの未着時対応 
	::----------------------------------------------------------------------------
	set PROCNAME=PROC3A1
	set RESPATH=%1
	set RESFILE=%2
	set TIMESTAMP=%3
	set _TOPIC_=%4
	set SEND=%5
	set LOOP=%6
	::CALL :MSGPROC %RESPATH%%RESFILE% [%PROC3A1_WAIT%][%PROC3A1_MAXWAIT%]
	::echo %SEND%
	::echo %LOOP%
	::IF NOT EXIST %RESPATH%/* mkdir %RESPATH%
	::echo.>%RESPATH%%RESFILE%
	set /a WAITS=0
:PROC3A1_WAIT
	IF EXIST %RESPATH%%RESFILE% GOTO PROC3A1_EXEC
	IF %WAITS% GTR %PROC3A1_MAXWAIT% GOTO PROC3A1_EXCEPT
	TIMEOUT %PROC3A1_WAIT%
	SET /a WAITS=%WAITS%+%PROC3A1_WAIT%
	goto PROC3A1_WAIT
:PROC3A1_EXCEPT
	ECHO %RESPATH%%RESFILE%
	CALL :MSGPROC TIMEOUT_PROC3A1
	set RETCNT=0
	goto :EOF
:PROC3A1_EXEC
	set TOPIC=%$COMPANY_TOPIC%/%_TOPIC_%
	FOR /F "delims=/ tokens=1,2" %%I IN ("%TOPIC%") DO set RECV_TOPIC=%%I/%%J/
	ECHO %LOOP%,%RESPATH%,%RESFILE%,%TIMESTAMP%,%TOPIC%,%RECV_TOPIC%>>%SEND%
:PROC3A1_END
	set /a RETCNTS+=1
	goto :EOF
:PROC3A2
	::----------------------------------------------------------------------------
	:: MQTT パブリッシュ
	:: AWS IoT Core トピックへの送信
	::----------------------------------------------------------------------------
	set PROCNAME=PROC3A2
	set PY=pub1.py
	set SENDFILE=%1
	set ENDP=--endpoint %$MQTT_BROKER_HOST%
	set PORT=--port %$MQTT_BROKER_PORT%
	set CAFI=--ca_file %$MQTT_CA__FILE%
	set KEYF=--key %$MQTT_KEY_FILE%
	set CERT=--cert %$MQTT_CERTFILE%
	set SEND=--sendlist %SENDFILE%
	set PROXY=--proxy_host %$MQTT_BROKER_PROXY%
	set PROXY_PORT=--proxy_port %$MQTT_BROKER_PROXY_PORT%
	set CLIENT=--client_id %COMPUTERNAME%
	set PYLOG=--logfile %$LOG%%PY%.log
	CALL :MSGPROC %PY%
	IF "%$MQTT_BROKER_PROXY%" EQU "" (
		CALL :MSGPROC ======_NO_PROXY_==================================================================
		set PUBCMD=%$PYTHON% %$PYTHONPROC%mqtt\%PY% %ENDP% %PORT% %CAFI% %KEYF% %CERT% %SEND% %CLIENT% %PYLOG%
	) ELSE (
		CALl :MSGPROC ======USE_PROXY_==================================================================
		set PUBCMD=%$PYTHON% %$PYTHONPROC%mqtt\%PY% %ENDP% %PROXY% %PROXY_PORT% %CAFI% %KEYF% %CERT% %SEND% %CLIENT% %PYLOG%
	)
	CALL :MSGPROC %PUBCMD%
	%PUBCMD%
	set RC=%ERRORLEVEL%
	IF %RC% NEQ 0 (
		CALL :MSGPROC ERROR!![%RC%]
	)
:PROC3A2_END
	goto :EOF
:PROC2
	::----------------------------------------------------------------------------
	:: OTNWからリソースをITNWへ可搬する
	:: 実装タイプとしてはNAS（SMB）からの採取
	::----------------------------------------------------------------------------
    set PROCNAME=PROC2
	CALL :MSGPROC START
	
	::実行時引数
	set ASCHE=%2

	::■パラメタ読込
	set FLIST=%$ROOT%filelist_proc2.txt
	CALL :MSGPROC FLIST:[%FLIST%]
	set /a LISTCOUNT=0
	SETLOCAL ENABLEDELAYEDEXPANSION
	FOR /F "eol=; tokens=1,2,3,4,5,6,7,8 delims=, " %%I in (%FLIST%) do (
		set /a LISTCOUNT+=1
		set FTYPE=%%I
		set FKUBUN=%%J
		set FPATERN=%%K
		set FPATH=%%L
		set FRECUR=%%M
		set FTIME=%%N
		set FTOPIC=%%O
		set FSCHE=%%P
		set FLEXEC=0
		IF "%ASCHE%"=="" (
			IF "!FSCHE!"=="N" set FLEXEC=1
		) ELSE (
			IF "%ASCHE%"=="!FSCHE!" set FLEXEC=1
		)
		rem echo A:%ASCHE% F:!FSCHE!
		IF !FLEXEC! EQU 1 (
			CALL :MSGPROC EXECUTE[%ASCHE%][!FSCHE!]
			CALL :%%I
		) ELSE (
			CALL :MSGPROC NOT_EXECUTE[%ASCHE%][!FSCHE!]
		)
	)
	SETLOCAL DISABLEDELAYEDEXPANSION
    set PROCNAME=PROC2
	IF %LISTCOUNT% EQU 0 (
		CALL :MSGPROC FILELIST_RECORDS_NOT_FOUND.
		goto PROC2_END
	)
	CALL :MSGPROC FILELIST_RECORDS[%LISTCOUNT%].
	IF "%FTYPE%" EQU "" (
		CALL :MSGPROC ERROR!!
		EXIT /B 9
	)
:PROC2_END
	cscript %$ROOT%UtyMoveFile.vbs %$RECVBK% -1
	cscript %$ROOT%UtyDirDelete.vbs %$RECVBK% -10
	cscript %$ROOT%UtyMoveFile.vbs %$SENDBK% -1
	cscript %$ROOT%UtyDirDelete.vbs %$SENDBK% -30
	cscript %$ROOT%UtyMoveFile.vbs %$LOG% -1
	cscript %$ROOT%UtyDirDelete.vbs %$LOG% -10
    goto ENDPROC
:PROC2A
    set PROCNAME=PROC2A
	CALL :MSGPROC --------------------------------------------------
	CALL :MSGPROC FLIST  :[%FLIST%]
	CALL :MSGPROC FTYPE  :[%FTYPE%]
	CALL :MSGPROC FKUBUN :[%FKUBUN%]
	CALL :MSGPROC FPATERN:[%FPATERN%]
	CALL :MSGPROC FPATH  :[%FPATH%]
	CALL :MSGPROC FRECUR :[%FRECUR%]
	CALL :MSGPROC FTIME  :[%FTIME%]
	CALL :MSGPROC FTOPIC :[%FTOPIC%]
	CALL :MSGPROC FSCHE  :[%FSCHE%]

    ::set SRCPATH=%$SRCLOC%%$SRCDIR%
    set SRCPATH=%$SRCLOC%
	set SRCFIND=%SRCPATH%\%FPATH%
	set WORKPATH=%$WORK%%FTYPE%\
	set WFILE=FILELIST2.txt
	set TMPWFILE=FILELIST2.tmp.txt
	set DMYWFILE=FILELIST2.dmy.txt
	set WORKFILE=%$WORK%%WFILE%
	set TMPWORKFILE=%$WORK%%TMPWFILE%
	set DMYWORKFILE=%$WORK%%DMYWFILE%
	CALL :GET_LOCALTIMESTAMP
	set SENDF=%GETLOCALTIMESTAMP%_%FTYPE%.TXT
	set SENDLIST=%$WORK%%SENDF%
	::
	set STRLEN=0
	CALL :STRLEN_PROC %SRCFIND%
	set SRCFIND_LEN=%STRLEN%
	::
	set STRLEN=0
	CALL :STRLEN_PROC %$SRCLOC%
	set SRCLOC_LEN=%STRLEN%
	::■ワーク初期化
	CALL :MSGPROC WORKFILE: %WORKFILE%
	IF EXIST "%WORKPATH%\*" (
		CALL :MSGPROC FOUND_DIRECTORY.
		del /Q %WORKPATH%*.*
		rmdir /S /Q %WORKPATH%
	) ELSE (
		rem 後で作成するのでここではしない
		rem mkdir %WORKPATH%
	)
	::■ファイル一覧作成
	set DIROPT=
	IF "%FRECUR%"=="Y" (
		set DIROPT=/S
	)
	CALL :MSGPROC DIR /B %SRCFIND% /A-D %DIROPT%
	CALL :MSGPROC FINDSTR /R "%FPATERN%"
	DIR /B %SRCFIND% /A-D %DIROPT% | FINDSTR /R "%FPATERN%" > %WORKFILE%
	IF %ERRORLEVEL% NEQ 0 (
		CALL :MSGPROC WARN_NOT_FOUND_FILES.[%ERRORLEVEL%]
		goto PROC2A_END
	)
	::::
	::ファイル名に空白入る(機器設定側不備)への対応
	::1)Item_ とすべきところItem となった場合を想定
	SETLOCAL ENABLEDELAYEDEXPANSION
	FOR /F "delims=," %%I IN (%WORKFILE%) DO (
		::ECHO %%I
		set MAE=%%I
		set ATO=!MAE:Item =Item_!
		IF "!MAE!" NEQ "!ATO!" (
			CALL :MSGPROC MOVE "!MAE!" "!ATO!"
			MOVE "!MAE!" "!ATO!"
		)
	)
	SETLOCAL DISABLEDELAYEDEXPANSION
	DIR /B %SRCFIND% /A-D %DIROPT% | FINDSTR /R "%FPATERN%" > %WORKFILE%
	::::
	::■ファイル一覧からNASから移動
	set PRNAME=PROC2A1
	ECHO.>%TMPWORKFILE%
	FOR /F "eol=;" %%I in (%WORKFILE%) do (
		CALL :%PRNAME% %%I %SRCFIND% %WORKPATH% %SRCFIND_LEN% %SRCLOC_LEN% %FRECUR% %TMPWORKFILE%
	)
	set PROCNAME=PROC2A
	MOVE %WORKFILE% %DMYWORKFILE%
	MOVE %TMPWORKFILE% %WORKFILE%
	
	::■移動先の決定
	set TRANTO=%$DBR_SEND%
	IF EXIST "%TRANTO%" (
		CALL :MSGPROC FOUND_DIRECTORY.[%TRANTO%]
	) ELSE (
		CALL :MSGPROC MAKE_DIRECTORY.[%TRANTO%]
		mkdir %TRANTO%
	)
	::■ファイル一覧からPCから移動
	set PRNAME=PROC2B1
	IF "%FKUBUN%"=="DATA" set PRNAME=PROC2B1
	IF "%FKUBUN%"=="SLUDGE" set PRNAME=PROC2B2
	FOR /F "tokens=1,2 delims=," %%I in (%WORKFILE%) do (
		CALL :%PRNAME% %%I %SRCFIND% %WORKPATH% %TRANTO% %SRCFIND_LEN% %SRCLOC_LEN% %FRECUR% %%J %SENDLIST%
	)
	::■ファイル一覧リストのチェック
	FOR %%F IN (%SENDFLIST%) DO (
		IF %%~zF EQU 0 (
			CALL :MSGPROC FILE_SIZE_ZERO.[%SENDLIST%]
			goto PROC2A_END
		)
	)
	::■ファイル一覧リストの送付
	IF EXIST "%$DBR_SUBSC_SEND%\*" (
		CALL :MSGPROC FOUND_DIRECTORY.[%$DBR_SUBSC_RECV%]
	) ELSE (
		CALL :MSGPROC MAKE_DIRECTORY.[%$DBR_SUBSC_SEND%]
		mkdir %$DBR_SUBSC_SEND%
	)
	COPY %SENDLIST% %$DBR_SUBSC_SEND%
	cscript %$ROOT%UtyFileBackUp.vbs %SENDLIST% %$SENDBK%
	cscript %$ROOT%UtyMoveFile.vbs %$SENDBK% -1
	cscript %$ROOT%UtyDirDelete.vbs %$SENDBK% -10

:PROC2A_END
	set PROCNAME=PROC2A
    goto :EOF
:PROC2A1
	:: ================================================================================
	::CALL :%PRNAME% %%I %SRCFIND% %WORKPATH% %SRCFIND_LEN% %SRCLOC_LEN% %FRECUR%
	set PROCNAME=PROC2A1
	set _TGT_=%1
	set _SRC_=%2
	set _DST_=%3
	set _LN1_=%4
	set _LN2_=%5
	set _REC_=%6
	set _WTM_=%7
	set /a _LN2_=%_LN2_% + 1
	CALL set DST=%%_SRC_:~%_LN2_%%%
	IF "%_REC_%"=="Y" goto PROC2A1_Y
	IF "%_REC_%"=="N" goto PROC2A1_N
	::echo _TGT_:%_TGT_%
	::echo _SRC_:%_SRC_%
	::echo _DST_:%_DST_%
	::echo _LN1_:%_LN1_%
	::echo _LN2_:%_LN2_%
	::echo _REC_:%_REC_%
	::echo _WTM_:%_WTM_%
:PROC2A1_Y
	set SRC=%_SRC_%
	CALL set TGT=%%_TGT_:~%_LN1_%%%
	CALL :GET_FILEPATH %TGT%
	CALL :GET_FILENAME %TGT%
	set DSTDIR=%_DST_%%DST%%GETFILEPATH%
	goto PROC2A1_YN_END
:PROC2A1_N
	set SRC=%_SRC_%\
	set TGT=%_TGT_%
	set GETFILENAME=%_TGT_%
	set DSTDIR=%_DST_%%DST%
	goto PROC2A1_YN_END
:PROC2A1_YN_END
	IF EXIST "%DSTDIR%\*" (
		CALL :MSGPROC FOUND_DIRECTORY.[%DSTDIR%][%_REC_%]
	) ELSE (
		CALL :MSGPROC MAKE_DIRECTORY.[%DSTDIR%][%_REC_%]
		mkdir %DSTDIR%
	)
	::
	::echo CALL :GET_FILETIMESTAMP2 %SRC%%TGT% \\
	::CALL :GET_FILETIMESTAMP2 %SRC%%TGT% \\
	CALL :GET_FILETIMESTAMP3 %SRC%%TGT% \\
	ECHO %_TGT_%,%GETFILETIMESTAMP%>>%_WTM_%
	::pause
	::CALL :MSGPROC GETFILEPATH:%GETFILEPATH%
	::CALL :MSGPROC GETFILENAME:%GETFILENAME%
	::CALL :MSGPROC GETFILETIMESTAMP:%GETFILETIMESTAMP%
	CALL :MSGPROC ■MOVE %SRC%%TGT% %DSTDIR%
	%$MOVE% %SRC%%TGT% %DSTDIR%


	goto :EOF
:PROC2B1
	:: ================================================================================
	set SUBPROC=PROC2B1
	goto PROC2B
:PROC2B2
	:: ================================================================================
	set SUBPROC=PROC2B2
	goto PROC2B
:PROC2B
	:: ================================================================================
	set PROCNAME=%SUBPROC%
	set _TGT_=%1
	set _SRC_=%2
	set _WRK_=%3
	set _DST_=%4
	set _LN1_=%5
	set _LN2_=%6
	set _REC_=%7
	set _MTI_=%8
	set _SND_=%9
	set /a _LN2_=%_LN2_% + 1
	CALL set DST=%%_SRC_:~%_LN2_%%%
	::echo _TGT_:%_TGT_%
	::echo _SRC_:%_SRC_%
	::echo _WRK_:%_WRK_%
	::echo _DST_:%_DST_%
	::echo _LN1_:%_LN1_%
	::echo _LN2_:%_LN2_%
	::echo _REC_:%_REC_%
	::echo _MTI_:%_MTI_%
	::echo _SND_:%_SND_%
	IF "%_REC_%"=="Y" goto PROC2B_Y
	IF "%_REC_%"=="N" goto PROC2B_N
:PROC2B_Y
	CALL set TGT=%%_TGT_:~%_LN1_%%%
	CALL :GET_FILEPATH %TGT%
	CALL :GET_FILENAME %TGT%
	set DSTDIR=%_DST_%%DST%%GETFILEPATH%
	set SRCDIR=%_WRK_%%DST%\
	::不要な/が先頭についている
	CALL set TGT=%%TGT:~1%%
	set RCVDIR=%$DBR_RECV%%DST%%GETFILEPATH%
	goto PROC2B_YN_END
:PROC2B_N
	set DST=%DST%\
	set TGT=%_TGT_%
	set GETFILENAME=%_TGT_%
	set DSTDIR=%_DST_%%DST%
	set SRCDIR=%_WRK_%%DST%\
	set RCVDIR=%$DBR_RECV%%DST%
	goto PROC2B_YN_END
:PROC2B_YN_END
	CALL :MSGPROC DST:%DST%
	CALL :MSGPROC TGT:%TGT%
	CALL :MSGPROC SRCDIR:%SRCDIR%
	CALL :MSGPROC DSTDIR:%DSTDIR%
	CALL :MSGPROC GETFILEPATH:%GETFILEPATH%
	CALL :MSGPROC GETFILENAME:%GETFILENAME%
	IF EXIST "%DSTDIR%\*" (
		CALL :MSGPROC FOUND_DIRECTORY.[%DSTDIR%][%_REC_%]
	) ELSE (
		CALL :MSGPROC MAKE_DIRECTORY.[%DSTDIR%][%_REC_%]
		mkdir %DSTDIR%
	)

	CALL :MSGPROC ▽MOVE %SRCDIR%%TGT% %DSTDIR%
	%$MOVE% %SRCDIR%%TGT% %DSTDIR%

	set FTXX_TIMESTAMP=%_MTI_%
	IF "%FTIME%" NEQ "N" (
		CALL :%FTIME% %TGT% 2 %_MTI_%
	)
	set FTXX_TOPIC=TOPIC
	IF "%FTOPIC%" NEQ "N" (
		CALL :%FTOPIC% %DST% %TGT% 
	)
	::■ファイル一覧リストの作成
	ECHO %RCVDIR%,%GETFILENAME%,%DST%,%FKUBUN%,%_MTI_%,%FTXX_TIMESTAMP%,%FTXX_TOPIC%>>%_SND_%
	goto :EOF
:: --------------------------------------------------------------------------------
::
:: --------------------------------------------------------------------------------
:FT02
	::FTXX_TOPIC
	::DST:03A\C\DL1
	::TGT:foo_001.jpeg
	FOR /F "tokens=1,2,3,4 delims=\" %%I IN ("%1\%2") DO set TOPIC1=%%I&& set TOPIC2=%%J&& set TOPIC3=%%L
	CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_003%=%AFT_PROC2B_TOPIC3_003%%%
	CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_004%=%AFT_PROC2B_TOPIC3_004%%%
	set FTXX_TOPIC=%TOPIC1%/%TOPIC2%/%TOPIC3%/
	goto :EOF
:FT04
	::FTXX_TOPIC
	::DST:03A\A01\DL1
	::TGT:OK__Default_Work_2_Item_1_20221020_173351.jpg
	FOR /F "tokens=1,2,3,4 delims=\" %%I IN ("%1\%2") DO set TOPIC1=%%I&& set TOPIC2=%%J&& set TOPIC3=%%K
	set FTXX_TOPIC=%TOPIC1%/%TOPIC2%/%TOPIC3%/
	goto :EOF
:FT03
	::FTXX_TOPIC
	::DST:20220705_PM_内
	::TGT:20220617_406ｶﾈﾂﾊｯﾎﾟｳｻﾞｲ\2022-09-15_10-52-00-1230.bfz\Input0_Camera10.jpg
	FOR /F "tokens=1,2,3,4 delims=\" %%I IN ("%1\%2") DO set TOPIC1=%%I&&set TOPIC2=%%J&& set TOPIC3=%%L
	CALL set TOPIC1=%%TOPIC1:%BEF_PROC2B_TOPIC1_001%=%AFT_PROC2B_TOPIC1_001%%%
	::8文字_　は8文字日付と判断し除去する
	echo %TOPIC2% | findstr [0-2][0-9][0-9][0-9][0-1][0-9][0-3][0-9]_ > nul && set TOPIC2=%TOPIC2:~9%
	CALL set TOPIC2=%%TOPIC2:%BEF_PROC2B_TOPIC2_001%=%AFT_PROC2B_TOPIC2_001%%%
	CALL set TOPIC2=%%TOPIC2:%BEF_PROC2B_TOPIC2_002%=%AFT_PROC2B_TOPIC2_002%%%
	CALL set TOPIC2=%%TOPIC2:%BEF_PROC2B_TOPIC2_003%=%AFT_PROC2B_TOPIC2_003%%%
	CALL set TOPIC2=%%TOPIC2:%BEF_PROC2B_TOPIC2_004%=%AFT_PROC2B_TOPIC2_004%%%
	CALL set TOPIC2=%%TOPIC2:%BEF_PROC2B_TOPIC2_005%=%AFT_PROC2B_TOPIC2_005%%%
	CALL set TOPIC2=%%TOPIC2:%BEF_PROC2B_TOPIC2_006%=%AFT_PROC2B_TOPIC2_006%%%
	CALL set TOPIC2=%%TOPIC2:%BEF_PROC2B_TOPIC2_007%=%AFT_PROC2B_TOPIC2_007%%%
	CALL set TOPIC2=%%TOPIC2:%BEF_PROC2B_TOPIC2_008%=%AFT_PROC2B_TOPIC2_008%%%
	::
	CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_001%=%AFT_PROC2B_TOPIC3_001%%%
	CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_002%=%AFT_PROC2B_TOPIC3_002%%%
	::CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_001%=%AFT_PROC2B_TOPIC3_001%%%
	::CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_002%=%AFT_PROC2B_TOPIC3_002%%%
	::CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_003%=%AFT_PROC2B_TOPIC3_003%%%
	::CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_004%=%AFT_PROC2B_TOPIC3_004%%%
	::CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_005%=%AFT_PROC2B_TOPIC3_005%%%
	::CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_006%=%AFT_PROC2B_TOPIC3_006%%%
	::CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_007%=%AFT_PROC2B_TOPIC3_007%%%
	::CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_008%=%AFT_PROC2B_TOPIC3_008%%%
	::CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_009%=%AFT_PROC2B_TOPIC3_009%%%
	::CALL set TOPIC3=%%TOPIC3:%BEF_PROC2B_TOPIC3_010%=%AFT_PROC2B_TOPIC3_010%%%
	set FTXX_TOPIC=%TOPIC1%/%TOPIC2%/%TOPIC3%/
	goto :EOF
:FT01
	::TGT:20220617_406ｶﾈﾂﾊｯﾎﾟｳｻﾞｲ\2022-09-15_10-52-00-1230.bfz\Input0_Camera10.jpg
	FOR /F "tokens=%2 delims=\" %%I IN ("%1") DO SET STAMP=%%I
	echo ■%STAMP%
	set STAMP=%STAMP:.bfz=%
	set STAMP=%STAMP:_=%
	set STAMP=%STAMP:-=%
	set STAMP=%STAMP:/=%
	set STAMP=%STAMP::=%
	set FTXX_TIMESTAMP=%STAMP%
	goto :EOF
:FT05
	set IN01=%1
	set IN01=%IN01:__=_0_%
	set IN01=%IN01:Copied_1_=%
	set IN01=%IN01:Copied_2_=%
	set IN01=%IN01:Copied_3_=%
	set IN01=%IN01:Copied_1_=%
	set IN01=%IN01:workColor_=%
	set TMI=%3
	::TGT:OK__Default_Work_2_Item_1_20221020_173351.jpg
	::20221007181519605
	FOR /F "tokens=8,9 delims=_" %%I IN ("%IN01%") DO SET STAMP=%%I%%J
	echo ■%STAMP%,%TMI%
	set STAMP=%STAMP:.jpg=%
	set TMI=%TMI%000
	set TMI=%TMI:~14,3%
	set STAMP=%STAMP%000
	set STAMP=%STAMP:~0,14%
	set FTXX_TIMESTAMP=%STAMP%%TMI%
	goto :EOF
:GET_SENDHEAD
	set _NAME_=%1
	set _HEADS_=%2
	set _SUBSC_=%3
	set GETSENDHEAD=
	::echo %_NAME_% --- %_SUBSC_%
	IF "%_NAME_%" NEQ "%_SUBSC_%" goto :EOF
	set GETSENDHEAD=%_HEADS_:@=,%
	::echo %_NAME_% === %_SUBSC_%
	goto :EOF
:GET_FILETIMESTAMP1
	set FF=%1
	set DD=%2
	goto GET_FILETIMESTAMP
:GET_FILETIMESTAMP2
	CALL :GET_FILENAME %1
	CALL :GET_FILEPATH %1
	set FF=%GETFILENAME%
	set DD=%2%GETFILEPATH%
	goto GET_FILETIMESTAMP
:GET_FILETIMESTAMP3
	CALL :GET_FILENAME %1
	CALL :GET_FILEPATH %1
	set FF=%GETFILENAME%
	set DD=%2%GETFILEPATH%
	goto GET_FILETIMESTAMP_PSE
:GET_FILETIMESTAMP
	set GETFILETIMESTAMP=
	for /F "tokens=2,3" %%I in ('where /R %DD% /T %FF%') do set STAMP=%%I_%%J
	echo %STAMP% | findstr _[0-9]: > nul && set STAMP=%STAMP:_=_0%
	set STAMP=%STAMP:_=%
	set STAMP=%STAMP:/=%
	set STAMP=%STAMP::=%
	set GETFILETIMESTAMP=%STAMP%
	goto :EOF
:GET_FILETIMESTAMP_PSE
	set GETFILETIMESTAMP=
	set PSF=%$PROC%powershell\where.ps1
	set WHERE=%$PSE% %PSF% %FF% %DD%
	for /F "tokens=2,3" %%I in ('%WHERE%') do set STAMP=%%I_%%J
	echo %STAMP% | findstr _[0-9]: > nul && set STAMP=%STAMP:_=_0%
	set STAMP=%STAMP:_=%
	set STAMP=%STAMP:/=%
	set STAMP=%STAMP::=%
	set STAMP=%STAMP:.=%
	set GETFILETIMESTAMP=%STAMP%
	goto :EOF
:GET_LOCALTIMESTAMP
	set GETLOCALTIMESTAMP=
	set STAMP=%DATE%_%TIME%
	set STAMP=%STAMP: =%
	echo %STAMP% | findstr _[0-9]: > nul && set STAMP=%STAMP:_=_0%
	set STAMP=%STAMP:_=%
	set STAMP=%STAMP:/=%
	set STAMP=%STAMP::=%
	set STAMP=%STAMP:.=%
	set GETLOCALTIMESTAMP=%STAMP%
	goto :EOF
:GET_FILENAME
	:: ================================================================================
	set GETFILENAME=
	set GETFILENAME=%~n1%~x1
	goto :EOF
:GET_FILEPATH
	:: ================================================================================
	set GETFILEPATH=
	set GETFILEPATH=%~p1
	goto :EOF
:STRLEN_PROC
	:: ================================================================================
	set _STR_=%1
	::echo %1
:STRLEN_LOOP
	IF NOT "%_STR_%"=="" (
		set _STR_=%_STR_:~1%
		set /a STRLEN=%STRLEN%+1
		goto STRLEN_LOOP
	)
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
	CALL %$DEACTIVATE%
	%$EXIT_CMD%
