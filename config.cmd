    echo ================================================================================
    echo Å°èâä˙ê›íË
    set $ROOT=%~dp0
    set $DATA=%$ROOT%Data\
    set $RECV=%$DATA%Recv\
    set $RECVBK=%$DATA%Recv\Backup\
    set $SEND=%$DATA%Send\
    set $SENDBK=%$DATA%Send\Backup\
    set $WORK=%$DATA%Work\
    set $LOG=%$ROOT%Log\
    set DT=%DATE:~-10%
	set TM=%TIME: =0%
	set FMTDATE=%DT:~0,4%%DT:~5,2%%DT:~8,2%
	set FMTTIME=%TM:~0,2%%TM:~3,2%%TM:~6,2%
	set JOBDATE=%DT:~0,4%%DT:~5,2%%DT:~8,2%_%FMTTIME%
    set PROC3A1_WAIT=1
    set PROC3A1_MAXWAIT=1
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
    echo Å°í[ññï ê›íË
    set $SRCLOC=\\192.168.254.96
    set $DBR_SEND=D:\ap99999\mqtt\SendPath\
    set $DBR_RECV=D:\ap99999\mqtt\RecvPath\
    set $DBR_SUBSC_SEND=%$DBR_SEND%SUBSC\
    set $DBR_SUBSC_RECV=%$DBR_RECV%SUBSC\
    goto CONFIG_1
:D09068
    echo ================================================================================
    echo Å°í[ññï ê›íË
    set $SRCLOC=\\192.168.254.96
    set $DBR_SEND=D:\Dbrg\AutoTransfer\SendPath\
    set $DBR_RECV=D:\Dbrg\AutoTransfer\RecvPath\
    set $DBR_SUBSC_SEND=%$DBR_SEND%SUBSC\
    set $DBR_SUBSC_RECV=%$DBR_RECV%SUBSC\
    goto CONFIG_1
:D08757
    echo ================================================================================
    echo Å°í[ññï ê›íË
    ::set $SRCLOC=\\192.168.254.96
    ::set $DBR_SEND=D:\Dbrg\AutoTransfer\SendPath\
    set $DBR_RECV=D:\Dbrg\AutoTransfer\RecvPath\
    ::set $DBR_SUBSC_SEND=%$DBR_SEND%SUBSC\
    set $DBR_SUBSC_RECV=%$DBR_RECV%SUBSC\
    goto CONFIG_1
:CONFIG_1
    ::TEST
    set BEF_PROC2B_TOPIC1_001=20220705_PM_ì‡
    set AFT_PROC2B_TOPIC1_001=03C
    set BEF_PROC2B_TOPIC2_001=20220617_405∂»¬ ØŒﬂ≥ªﬁ≤
    set AFT_PROC2B_TOPIC2_001=B0001
    set BEF_PROC2B_TOPIC2_002=20220617_406∂»¬ ØŒﬂ≥ªﬁ≤
    set AFT_PROC2B_TOPIC2_002=B0002
    set BEF_PROC2B_TOPIC2_003=20220617_407∂»¬ ØŒﬂ≥ªﬁ≤
    set AFT_PROC2B_TOPIC2_003=B0003
    set BEF_PROC2B_TOPIC2_004=20220617_408∂»¬ ØŒﬂ≥ªﬁ≤
    set AFT_PROC2B_TOPIC2_004=B0004
    set BEF_PROC2B_TOPIC2_005=20220617_409∂»¬ ØŒﬂ≥ªﬁ≤
    set AFT_PROC2B_TOPIC2_005=B0005
    set BEF_PROC2B_TOPIC2_006=20220617_410∂»¬ ØŒﬂ≥ªﬁ≤
    set AFT_PROC2B_TOPIC2_006=B0006
    set BEF_PROC2B_TOPIC2_007=20220617_411∂»¬ ØŒﬂ≥ªﬁ≤
    set AFT_PROC2B_TOPIC2_007=B0007
    set BEF_PROC2B_TOPIC2_008=20220617_412∂»¬ ØŒﬂ≥ªﬁ≤
    set AFT_PROC2B_TOPIC2_008=B0008
    set BEF_PROC2B_TOPIC3_001=Input0_Camera
    set AFT_PROC2B_TOPIC3_001=DL
    set BEF_PROC2B_TOPIC3_002=.jpg
    set AFT_PROC2B_TOPIC3_002=
    set BEF_PROC2B_TOPIC3_003=foo_0
    set AFT_PROC2B_TOPIC3_003=DL2
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
    goto CONFIG_END
:CONFIG_ERR
    echo ================================================================================
    echo Å°ERROR
    exit /B:9
:CONFIG_END
    exit /B:0