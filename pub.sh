#!/bin/bash
# --------------------------------------------------------------------------------------------------
# システム名    ：
# サブシステム名：
# ファイル名    ：
# 概要説明      ：
# --------------------------------------------------------------------------------------------------
# 変更履歴：
# 改定                         変更理由                                               担当者
# 番号  変更日     バージョン  案件/問題   変更内容                                   氏名
# --------------------------------------------------------------------------------------------------
# 001   2022-09-01 ver.1.0.0   202208R062  初版                                       橋本 英雄
# --------------------------------------------------------------------------------------------------
TODAY=`date "+%Y%m%d%H%M%S"`
JOBDATE=`date "+%Y%m%d"`
T="+%Y/%m/%d %H:%M:%S"
CURRENT_DIR=$(cd "$(dirname "$0")" && pwd -P)
HOSTNAME=$(hostname -s)
source "${CURRENT_DIR:?}/config.sh" "$HOSTNAME" "$1"
THIS=`basename ${0}`
LOGTHIS=$(printf "%-20s" ${THIS})
LOGFILE=${LOGDIR}${JOBDATE}_${THIS}.log
cd ${ROOT}
# --------------------------------------------------------------------------------------------------
# ログ処理
# --------------------------------------------------------------------------------------------------
LOG(){
    echo `date "${T}"` ["${LOGTHIS}"] $@  | tee -a ${LOGFILE}
}
# --------------------------------------------------------------------------------------------------
# 処理
# --------------------------------------------------------------------------------------------------
ERR(){
    ERRNUM=$?
    # ----------------------------------------------------------------------------------------------
    ORGLOGTHIS=$LOGTHIS
    SUBTHIS=ERR
    LOGTHIS=$(printf "%-10s:%-9s" ${THIS} ${SUBTHIS})
    LOG -------------------------------------------------------------
    # ----------------------------------------------------------------------------------------------
    case ${ERRNUM} in
        127)
            LOG "内部処理コードが未対応です($ERRNUM)"
            ;;
        *)
            LOG "システム例外です($ERRNUM)"
    esac
    exit 9
}
# --------------------------------------------------------------------------------------------------
# 処理
# --------------------------------------------------------------------------------------------------
PROC1A(){
    # ----------------------------------------------------------------------------------------------
    ORGLOGTHIS=$LOGTHIS
    SUBTHIS=PROC1A
    LOGTHIS=$(printf "%-10s:%-9s" ${THIS} ${SUBTHIS})
    LOG -------------------------------------------------------------
    LOG ${SUBTHIS}:開始 $1
    # ----------------------------------------------------------------------------------------------
    rm -rf ${TEMPO_DIR}*
    LOG rm[${TEMPO_DIR}]
    
    # ----------------------------------------------------------------------------------------------
    ORGIFS=$IFS
    IFS=/
    read -ra ARR <<< "${LOGIC_PATH}"
    LV1=${ARR[0]}
    LV2=${ARR[1]}
    LV3=${ARR[2]}
    IFS=$ORGIFS
    idx=0
    TEMPO_DEST_DIR=${TEMPO_DIR}${LV1}/${LV2}/${LV3}/
    LOG TEMPO_DEST_DIR:${TEMPO_DEST_DIR}
    if [ ! -d ${TEMPO_DEST_DIR} ]; then
        mkdir -p ${TEMPO_DEST_DIR}
    fi
    PUBLISHTM=`date "+%Y%m%d%H%M%S%2N"`
    SENDLIST=${SEND_DIR}${PUBLISHTM}_PROC1A.TXT
    if [ ! -f "${SENDLIST}" ];then
        rm -rf ${SENDLIST}
    fi
    
    #監視ディレクトリのファイル一覧取得しループする
    while read -r file; do
        #タイムスタンプ1:年月日時分秒
        ts1=`date +%Y%m%d%H%M%S -r ${file}`
        #タイムスタンプ2:年月日時分秒ミリ3桁
        ts2=`date +%Y%m%d%H%M%S%3N -r ${file}`
        #送信ファイル一覧を作成する
        # 01:DBRG(データブリッジ)での受信フォルダ
        # 02:DBRG受信ファイル名
        # 03:拠点別コード(DBRGに作成済フォルダでサービス認識されていること)
        # 04:データ種別
        # 05:タイムスタンプ1:年月日時分秒
        # 06:タイムスタンプ2:年月日時分秒ミリ3桁
        # 07:MQTTトピック
        echo -e ${DBRG_RECV_PATH//\\/\\\\}${LOGIC_PATH//\//\\\\}\\\\,${ts2}_`basename ${file}`,${LV1},"DATA",${ts1},${ts2},${LOGIC_PATH,,}\\r>> ${SENDLIST}
        #TEMPへ移動送信する
        mv -f  ${file} ${TEMPO_DEST_DIR}${ts2}_`basename ${file}`
        idx=$((idx+1))
    done < <(find ${WATCH_PATH} -name "${pattern}" -maxdepth 1)
    # ----------------------------------------------------------------------------------------------
    if [ $idx -gt 0 ]; then
        LOG mv[元][${WATCH_PATH}]
        LOG mv[先][${TEMPO_DEST_DIR}]
        # 再帰でファイルを送信する
        PROC1A_SUB1 ${TEMPO_DIR} ${LV1} ${LV2} || PROC1A_EX1
        PROC1A_SUB2 ${SENDLIST} ${SCP_REMOTE_SUBSC}|| PROC1A_EX1
        ./UtyFileBackup.sh ${SENDLIST} ${SENDBK_DIR} | tee -a ${LOGFILE}
    fi
    # ----------------------------------------------------------------------------------------------
    #BACKUPD=`date "+%Y%m%d%H%M%S"`
    #mv ${SENDLIST} ${SENDBK_DIR}${BACKUPD}_`basename ${SENDLIST}`
    ./UtyMoveFile.sh ${SENDBK_DIR} -1 | tee -a ${LOGFILE}
    ./UtyDirDelete.sh ${SENDBK_DIR} -10 | tee -a ${LOGFILE}
    LOG ${SUBTHIS}:終了[$idx][$?]
    LOGTHIS=$ORGLOGTHIS
}
PROC1A_EX1(){
    LOG /_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
    LOG PROC1A_EX1:例外[$ERRNUM]
    case "$ERRNUM" in
    * )
        LOG システム障害
        LOG mv ${TEMPO_DEST_DIR}* ${WATCH_PATH}
        #mv ${TEMPO_DEST_DIR}* ${WATCH_PATH}
        ERRNUM=$?
        LOG 切り戻し[RC=$ERRNUM]
        ;;
    esac
    LOG /_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
}
# --------------------------------------------------------------------------------------------------
# 処理
# --------------------------------------------------------------------------------------------------
#PROC1B(){
#    # ----------------------------------------------------------------------------------------------
#    ORGLOGTHIS=$LOGTHIS
#    SUBTHIS=PROC1B
#    LOGTHIS=$(printf "%-10s:%-9s" ${THIS} ${SUBTHIS})
#    LOG -------------------------------------------------------------
#    LOG ${SUBTHIS}:開始 $1
#    # ----------------------------------------------------------------------------------------------
#    TOPICINDEX=$2
#    export MQTT_BROKER_HOST
#    #$PYTHON Proc/python/pub.py ${TOPICINDEX}
#    LOG ${SUBTHIS}:終了
#    LOGTHIS=$ORGLOGTHIS
#}
# --------------------------------------------------------------------------------------------------
# 処理
# --------------------------------------------------------------------------------------------------
PROC1A_SUB1(){
    # ----------------------------------------------------------------------------------------------
    ORGLOGTHIS=$LOGTHIS
    SUBTHIS=PROC1A_SUB1
    LOGTHIS=$(printf "%-10s:%-9s" ${THIS} ${SUBTHIS})
    LOG -------------------------------------------------------------
    LOG ${SUBTHIS}:開始 $1 $2 $3
    # ----------------------------------------------------------------------------------------------
    local LVL1=$2
    local LVL2=$3
    local SCP=scp
    local SCP_CONNECT=${SCP_USER}@${SSH_HOST}
    local SCP_LOCAL_PATH=$1$LVL1/$LVL2/
    local REMOTE_ROOT=$LVL1
    echo ${SCP} -r -i ${SCP_PRIVATE_KEY} ${SCP_LOCAL_PATH} ${SCP_USER}@${SSH_HOST}:${SCP_REMOTE_PATH}${REMOTE_ROOT}
    ${SCP} -r -i ${SCP_PRIVATE_KEY} ${SCP_LOCAL_PATH} ${SCP_USER}@${SSH_HOST}:${SCP_REMOTE_PATH}${REMOTE_ROOT} 2>&1  | tee -a ${LOGFILE}
    ERRNUM=${PIPESTATUS[0]}
    LOG scp[${SSH_HOST}][RC=$ERRNUM]
    # ----------------------------------------------------------------------------------------------
    LOG ${SUBTHIS}:終了
    LOGTHIS=$ORGLOGTHIS
    return $ERRNUM
}
PROC1A_SUB2(){
    # ----------------------------------------------------------------------------------------------
    ORGLOGTHIS=$LOGTHIS
    SUBTHIS=PROC1A_SUB2
    LOGTHIS=$(printf "%-10s:%-9s" ${THIS} ${SUBTHIS})
    LOG -------------------------------------------------------------
    LOG ${SUBTHIS}:開始 $1 $2 $3
    # ----------------------------------------------------------------------------------------------
    local SCP=scp
    local SCP_CONNECT=${SCP_USER}@${SSH_HOST}
    local SCP_LOCAL_PATH=$1
    local SCP_REMOTE_PATH=$2
    echo ${SCP} -r -i ${SCP_PRIVATE_KEY} ${SCP_LOCAL_PATH} ${SCP_USER}@${SSH_HOST}:${SCP_REMOTE_PATH}
    ${SCP} -r -i ${SCP_PRIVATE_KEY} ${SCP_LOCAL_PATH} ${SCP_USER}@${SSH_HOST}:${SCP_REMOTE_PATH} 2>&1  | tee -a ${LOGFILE}
    local ERRNUM=${PIPESTATUS[0]}
    LOG scp[${SSH_HOST}][RC=$ERRNUM]
    # ----------------------------------------------------------------------------------------------
    LOG ${SUBTHIS}:終了
    LOGTHIS=$ORGLOGTHIS
    return $ERRNUM
}
# --------------------------------------------------------------------------------------------------
# 主処理
# --------------------------------------------------------------------------------------------------
LOG ==S_T_A_R_T==========================================================
ORGIFS=$IFS
IFS=,
#
. venv/bin/activate
#pip list
#
MAST_FILELIST=${ROOT}/${FILELIST1}
WORK_FILELIST=${ROOT}/Data/Work/FILELIST1.txt
# 改行不要
sed -e "s/\r$//" ${MAST_FILELIST} >${WORK_FILELIST}
# 先頭#はコメントで対象外
sed -i -e "/^\s*#/d" ${WORK_FILELIST}
# 空行は対象外
sed -i -e "/^\s*$/d" ${WORK_FILELIST}
#
LOG MAST_FILELIST: ${MAST_FILELIST}
LOG WORK_FILELIST: ${WORK_FILELIST}

if [ ! -f "${WORK_FILELIST}" ];then
    LOG "ERROR!! NOT FOUND FilelistPath ${WORK_FILELIST}"
    LOG ==E___N___D================================================== [RC=$?]
    exit 9
fi

while read typename pattern subdir ruledir
do
    LOG LOOP1: [${typename}][${pattern}][${subdir}][${ruledir}]
    WATCH_PATH=${WATCH_DIR}${subdir}
    LOGIC_PATH=${subdir}
    if [ -n "${ruledir}" ];then
        LOGIC_PATH=${ruledir}
    fi
    if [ ! -d "${WATCH_PATH}" ];then
        LOG "WARN!! NOT FOUND Directory $WATCH_PATH"
        mkdir -p ${WATCH_PATH}
        #LOG ==E___N___D================================================== [RC=$?]
        #exit 9
    fi
    case "${typename}" in
        #"test1" | "test2" | "test3") proc=PROC1;;
        "FTYPE1" ) proc=PROC_A;;
        "FTYPE2" ) proc=PROC_B;; #未実装
        "FTYPE3" ) proc=PROC_C;; #未実装
        * )
            LOG "ERROR!! NOT FOUND Proctype ${typename}"
            LOG ==E___N___D================================================== [RC=$?]
            exit 9
            ;;
    esac
    
    case "$proc" in
        "PROC_A")
            PROC1A;;
        "PROC_B")
            PROC1B;;
    esac
done < ${WORK_FILELIST}
IFS=$ORGIFS
deactivate
LOG ==E___N___D================================================== [RC=$?]