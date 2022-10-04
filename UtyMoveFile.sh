#!/bin/bash
# --------------------------------------------------------------------------------------------------
# システム名    ：構成管理サーバーSCMS
# サブシステム名：
# ファイル名    ：UtyMoveFile.sh
#
# 概要説明      ：削除期間を超えた年月日文字ファイルを日付けディレクトリに移動します
# --------------------------------------------------------------------------------------------------
# 変更履歴：
# 改定                         変更理由                                               担当者
# 番号  変更日     バージョン  案件/問題   変更内容                                   氏名
# --------------------------------------------------------------------------------------------------
# 001   2015-04-03 ver.1.0.0   201412-011  初版                                       橋本 英雄
# --------------------------------------------------------------------------------------------------
DIRECTORY=$1
RANGE=$2
TODAY=`date "+%Y%m%d"`
MKDIRNAME=""
# --------------------------------------------------------------------------------------------------
# usage
# 機能    : 処理説明
# 引数    : 
# --------------------------------------------------------------------------------------------------
usage() {
cat <<EOF

$(basename ${0})
     指定ディレクトリ内のファイル一覧で削除期間を超えた年月日文字ファイルを日付けディレクトリに移動します
	 日付けフォルダが無ければ作成します
	 日付けフォルダと同じ名前のファイルがあればリネームします
	 日付けの判定は
	 1)先頭 8桁 yyyymmdd_FILE.NAME
	 2)先頭14桁 yyyymmddHHMMSS_FILE.NAME
	 3)末尾 8桁 FILE.NAME.yyyymmdd
	 4)末尾14桁 FILE.NAME.yyyymmddHHMMSS
	 に一致した文字列で判定します
Usage:
     $(basename ${0}) [DIRECTORY] [RANGE]
	 DIRECTORY    コピー先ディレクトリを指定します
	 RANGE        削除期間（日数）
EOF
}
# --------------------------------------------------------------------------------------------------
# FindFiles
# 機能    : ディレクトリ内から一覧取得する
# 引数    : Arg1 - 
# --------------------------------------------------------------------------------------------------
FindDirectory() {
	#
	DELSTR=$1
	FILES="${DIRECTORY}/*"
	FILARRAY=()
	DIRARRAY=()

	for filepath in $FILES; do
		if [  -f $filepath ]; then
			FILARRAY+=("$filepath")
		fi
		if [  -d $filepath ]; then
			DIRARRAY+=("$filepath")
		fi
		#echo $filepath
	done
	#
	for i in ${FILARRAY[@]}; do
		FILENAME=`basename $i`
		#echo ${FILENAME} ${DELSTR}
		Chcek1 ${FILENAME} ${DELSTR}
		result=$?
		if [ ! $result == 0 ]; then
			echo "MoveFile[$result]: $i ⇒ ${FILENAME}"
		
			if [  -f ${DIRECTORY}/${MKDIRNAME}  ]; then
				mv ${DIRECTORY}/${MKDIRNAME} ${DIRECTORY}/${MKDIRNAME}.Org
			fi
			if [ ! -d ${DIRECTORY}/${MKDIRNAME} ]; then
				mkdir ${DIRECTORY}/${MKDIRNAME}
			fi
			#
			CopyFile $i ${DIRECTORY}/${MKDIRNAME}/${FILENAME}
			DeleteFile $i
		fi
	done
}
# --------------------------------------------------------------------------------------------------
# 
# 機能    : ファイル名先頭が yyyymmddHHMMSSから始まる場合
# 引数    : 
# --------------------------------------------------------------------------------------------------
Chcek1() {
	#
	FILE=$1
	DELSTR=$2

	STR=`echo ${FILE} | sed -e "s/^\([0-9]\{4\}[0-9]\{2\}[0-9]\{2\}\)[0-9]\{6\}.*$/\1/"`
	#echo ${STR} ${DELSTR}
	if [ $STR != ${FILE} ]; then
		if [ ! "${STR:0:8}" ">" "${DELSTR}" ]; then
			MKDIRNAME="${STR:0:8}"
			return 1
		fi
		return 0
	fi
	
	STR=`echo ${FILE} | sed -e "s/^\([0-9]\{4\}[0-9]\{2\}[0-9]\{2\}\).*$/\1/"`
	if [ $STR != ${FILE} ]; then
		if [ ! "${STR:0:8}" ">" "${DELSTR}" ]; then
			MKDIRNAME="${STR:0:8}"
			return 2
		fi
		return 0
	fi

	STR=`echo ${FILE} | sed -e "s/^.*\([0-9]\{4\}[0-9]\{2\}[0-9]\{2\}\)[0-9]\{6\}$/\1/"`
	if [ $STR != ${FILE} ]; then
		if [ ! "${STR:0:8}" ">" "${DELSTR}" ]; then
			MKDIRNAME="${STR:0:8}"
			return 3
		fi
		return 0
	fi
	
	STR=`echo ${FILE} | sed -e "s/^.*\([0-9]\{4\}[0-9]\{2\}[0-9]\{2\}\)$/\1/"`
	if [ $STR != ${FILE} ]; then
		if [ ! "${STR:0:8}" ">" "${DELSTR}" ]; then
			MKDIRNAME="${STR:0:8}"
			return 4
		fi
		return 0
	fi

	return 0;
}
# --------------------------------------------------------------------------------------------------
# CopyFile
# 機能    : ファイルのコピー
# 引数    : Arg1 - コピー元ファイル名
#         : Arg2 - コピー先ファイル名
# --------------------------------------------------------------------------------------------------
CopyFile() {
	# コピー先ファイル
	FILE=$1
	sCopyFile=$2
	# コピー元ファイルの確認
	if [ ! -f ${FILE} ]; then
		echo "File Copy,Not Found ${FILE}"
		exit 1
	else
		# ファイルコピー
		cp ${FILE} ${sCopyFile}
	fi
}
# --------------------------------------------------------------------------------------------------
# DeleteFile
# 機能    : ファイルの削除
# 引数    : Arg1 - 削除ファイル名
# --------------------------------------------------------------------------------------------------
DeleteFile() {
	FILE=$1
	#
	if [ ! -f ${FILE} ]; then
		echo "File Delete,Not Found ${FILE}"
		exit 2
	else
		# ファイル削除
		rm -f ${FILE}
	fi
}
# --------------------------------------------------------------------------------------------------
# 主処理
# --------------------------------------------------------------------------------------------------
# 引数チェック
case $1 in
	"")
			usage
			exit 8
			;;
	*)
		;;
esac
case $2 in
	"")
			usage
			exit 8
			;;
	*)
		;;
esac

# 指定フォルダが正しいフォルダか
if [ ! -d ${DIRECTORY}  ]; then
	echo "Is Not Directory ! ${DIRECTORY}"
	exit 8
fi
# 指定フォルダ名が/で終っているか
if [ ${DIRECTORY: -1} == "/" ]; then
	DIRECTORY=${DIRECTORY/%?/}
fi

DELDATA=`date -d ${RANGE}day "+%Y%m%d"`

echo "Dir       : ${DIRECTORY}"
echo "削除期間  : ${RANGE}"
echo "削除日    : ${DELDATA}"

# 処理部
FindDirectory ${DELDATA}

# 終処理部
exit 0
