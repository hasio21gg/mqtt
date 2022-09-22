'*********************************************************************
' ConvNs1 V01L01 COMMAND UTILITY
' StepCode ConvKumiline
' All Rights Reserved, Copyright (c) 2002 Sankyoalumi
'*********************************************************************
' 利用環境：WSH(Windows Script Host)環境が必要です。
' 利用言語：WSH,VBScript
'*********************************************************************
' 機能	：ディレクトリの整理を行う
' 概要	：ディレクトリのタイムスタンプを判定して削除する。
' 作成者	：Oogaki Shoji (Sankyoalumi)
' 作成日	：2005/01/12
' 引数		：Arg1=検索ディレクトリ　Arg2=削除日数
' 更新履歴：
'*********************************************************************
Option Explicit
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Dim WshShell
Dim fso
Dim objArgs
Dim I
Dim nRet
Dim dtTime,strHeder

Set WshShell = wscript.CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

Set objArgs = wscript.Arguments
wscript.echo "Dir   　：" & objArgs(0)
wscript.echo "削除期間：" & objArgs(1)

dtTime = DateAdd("d",objArgs(1),NOW())
Dim strYear, strMonth, strDay
strYear  = Year(dtTime)  : If Len(strYear)  = 2 Then strYear  = "20" & strYear
strMonth = Month(dtTime) : If Len(strMonth) = 1 Then strMonth = "0"  & strMonth
strDay   = Day(dtTime)   : If Len(strDay)   = 1 Then strDay   = "0"  & strDay

strHeder = strYear & strMonth & strDay
wscript.echo "削除日  ：" & dtTime

dim sf,sfc
dim f, f1
Set f = fso.GetFolder(objArgs(0))
Set sf = f.SubFolders

Dim strSubDir

For Each f1 in sf
	strSubDir = f1.name
	if strSubDir <= strHeder And Left(strSubDir, 1) <> "." then
		'▽ディレクトリの削除
		wscript.echo "Delete：" & strSubDir
		nRet = fso.DeleteFolder(objArgs(0) & "\" & strSubDir)
	end if
Next
set sf  = nothing
set f   = nothing
