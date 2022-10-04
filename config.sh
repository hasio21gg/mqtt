#!/bin/bash

case "$1" in
"raspberrypi")
    ROOT=/home/pi/mqtt/mqtt1
    PYTHON=python
    MQTT_BROKER_HOST=192.168.254.101
    SCP=scp
    SCP_PRIVATE_KEY=~/.ssh/ssh_host_rsa_key
    SCP_USER=pi
    SSH_HOST=192.168.254.101
    SCP_REMOTE_PATH=D:/Dbrg/AutoTransfer/SendPath/
    SCP_REMOTE_SUBSC=${SCP_REMOTE_PATH}SUBSC/
    DBRG_RECV_PATH=D:\\Dbrg\\AutoTransfer\\RecvPath\\
    ;;
"D08591")
    ROOT=/mnt/d/ap99999/mqtt/mqtt1
    PYTHON=python3
    MQTT_BROKER_HOST=192.168.254.101
    SCP=scp
    SCP_PRIVATE_KEY=~/.ssh/ssh_host_rsa_key
    SCP_USER=pi
    SSH_HOST=192.168.254.101
    SCP_REMOTE_PATH=D:/Dbrg/AutoTransfer/SendPath/
    SCP_REMOTE_SUBSC=${SCP_REMOTE_PATH}SUBSC/
    DBRG_RECV_PATH=D:\\Dbrg\\AutoTransfer\\RecvPath\\
    ;;
*)
    echo "NOT DEFINED COMPUTE."
    exit 9
    ;;
esac

case "$2" in
"PROC1")
    WATCH_DIR=${ROOT}/Data/Recv/
    SEND_DIR=${ROOT}/Data/Send/
    SENDBK_DIR=${SEND_DIR}Backup/
    TEMPO_DIR=${ROOT}/Data/Temp/
    FILELIST1=filelist_proc1.txt
    ;;
*)
    echo "NOT DEFINED PROC."
    exit 9
    ;;
esac

LOGDIR=${ROOT}/Log/