'*********************************************************************
' ConvNs1 V01L01 COMMAND UTILITY
' StepCode ConvKumiline
' All Rights Reserved, Copyright (c) 2002 Sankyoalumi
'*********************************************************************
' 利用環境：WSH(Windows Script Host)環境が必要です。
' 利用言語：WSH,VBScript
'*********************************************************************
' 機能	：	指定のファイルをタイムスタンプ付ディレクトリに格納する。
'			同一フォルダに作成する。
'			[2005.11.19] Hashimoto	Log4j仕様に対応(Name.log.yyyymmdd方式)
' 作成者：	Oogaki Shoji (Sankyoalumi)
' 作成日：	2005/01/12
' 引数	：	Arg1=ディレクトリ　Arg2=退避日数（過去？日）
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
Dim dtTime,strHeder

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

dim f, f1, fc
Set f = fso.GetFolder(objArgs(0))
Set fc = f.Files

Dim strFilePath
Dim strFilePathS
Dim strFolder
Dim strFile
Dim strFile8

For Each f1 in fc
	strFile=f1.name
	strFile8   = left(f1.name,8)
	If strFile8 > strHeder Then
		Dim strFile8R
		strFile8R = Mid(strFile, InstrRev(strFile, ".", -1) + 1)
		'SearchString ="XXpXXpXXPXXP"   ' 検索対象の文字列。
		'SearchChar = "P"   ' "P" を検索します。
		'MyPos = InstrRev(SearchString, SearchChar, 10, 0)   ' 10 番目の文字から、バイナリ モードで比較を行います。9 を返します。
		'MyPos = InstrRev(SearchString, SearchChar, -1, 1)   ' 最後の文字から、テキスト モードで比較を行います。12 を返します。
		'MyPos = InstrRev(SearchString, SearchChar, 8)   ' 既定ではバイナリ モードで比較を行います (最後の引数は、省略されます)。0 を返します。
		'If strFile8R <= strHeder then
		'	strFile8 = strFile8R
		'End If
		If Len(strFile8R) = 8 Then
				Wscript.Echo strFile & "-" & strFile8R & InstrRev(strFile, ".", -1)
				strFile8 = strFile8R
		End If
		

	End If
	If strFile8 <= strHeder then
		'▽フォルダ存在有無確認
		strFolder   = objArgs(0) & "\" & strFile8 
		If Not fso.FolderExists(strFolder) then

			'▽フォルダと同名のファイルが存在する場合はファイル名.Org名に変更する。
			If fso.FileExists(strFolder) Then
				strFile = strFile & ".Org"
				strFilePath =objArgs(0) & "\" & strFile
				nRet = fso.CopyFile(strFolder,strFilePath)
				nRet = fso.DeleteFile(strFolder)
			End If

			'▽フォルダ作成
			nRet = fso.CreateFolder(strFolder)

		End If

		'▽フォルダへコピー
		strFilePath = objArgs(0) & "\" & strFile
		If fso.FileExists(strFilePath) Then
			wscript.echo "MoveFile：" & strFilePath & " ⇒ " & strFolder
			strFilePathS = strFolder & "\" & strFile
			nRet = fso.CopyFile(strFilePath,strFilePathS)
			nRet = fso.DeleteFile(strFilePath)
		End If
	End If
Next
set fc  = nothing
set f   = nothing
