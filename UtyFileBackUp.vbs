'*********************************************************************
' ConvNs1 V01L01 COMMAND UTILITY
' StepCode ConvKumiline
' All Rights Reserved, Copyright (c) 2002 Sankyoalumi
'*********************************************************************
' 利用環境：WSH(Windows Script Host)環境が必要です。
' 利用言語：WSH,VBScript
'*********************************************************************
' 機能	：データバックアップ
' 概要	：処理時間を付加してデータをバックアップする。
' 作成者：Oogaki Shoji (Sankyoalumi)
' 作成日：2003/05/28
' 引数	：Arg1=コピー元　Arg2=コピー先
'
' 更新履歴：
'*********************************************************************
Option Explicit
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Dim WshShell
Dim fso
Dim objArgs
Dim I
Dim nRet

Set WshShell = wscript.CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

	Set objArgs = wscript.Arguments
	wscript.echo "Original：" & objArgs(0)
	wscript.echo "CopyDir ：" & objArgs(1)

	'▽ファイルの退避
	dim strSouceFile, strCopyFile, strFile
	strSouceFile = objArgs(0)
	strFile = Mid(objArgs(0),InstrRev(objArgs(0),"\")+1)
	dim strHeder,dtTime
	dtTime = Now()
	Dim strYear, strMonth, strDay, strHour, strMinute, strSecond
	strYear  = Year(dtTime)  : If Len(strYear)  = 2 Then strYear  = "20" & strYear
	strMonth = Month(dtTime) : If Len(strMonth) = 1 Then strMonth = "0"  & strMonth
	strDay   = Day(dtTime)   : If Len(strDay)   = 1 Then strDay   = "0"  & strDay
	strHour  = Hour(dtTime)  : If Len(strHour)  = 1 Then strHour  = "0"  & strHour
	strMinute= Minute(dtTime): If Len(strMinute)= 1 Then strMinute= "0"  & strMinute
	strSecond= Second(dtTime): If Len(strSecond)= 1 Then strSecond= "0"  & strSecond

	strHeder = strYear & strMonth & strDay & strHour & strMinute & strSecond
'	strHeder = Mid(strTime,1,4) & Mid(strTime,6,2) & Mid(strTime,9,2) & Mid(strTime,12,2) & Mid(strTime,15,2) & Mid(strTime,18,2)
	strCopyFile = objArgs(1) & strHeder & "_" & strFile

	nRet = CopyFile(strSouceFile,strCopyFile)

	'▽ファイルの削除
	nRet = DeleteFile(strSouceFile)


'*********************************************************************
' 機能		：ファイルのコピー
'	Arg1=コピー元ファイル,Arg2=コピー先ファイル
'*********************************************************************
Function CopyFile(sSouseFile,sCopyFile)

	dim fso, blCheck

	set fso = CreateObject("Scripting.FileSystemObject")
	blCheck = (fso.FileExists(sSouseFile))
	If blCheck then
		'WScript.echo "copy " & sSouseFile & " " & sCopyFile
		blCheck = (fso.CopyFile(sSouseFile,sCopyFile))
	Else
		Wscript.Echo "Not Found: " & sSouseFile
	End if

End Function

'*********************************************************************
' 機能		：ファイルの削除
' Arg1=削除ファイル
'*********************************************************************
Function DeleteFile(sSouseFile)

	dim fso, blCheck

	set fso = CreateObject("Scripting.FileSystemObject")
	blCheck = (fso.FileExists(sSouseFile))
	If blCheck then
			blCheck =(fso.DeleteFile(sSouseFile))
	End if

End Function

