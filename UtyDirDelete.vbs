'*********************************************************************
' ConvNs1 V01L01 COMMAND UTILITY
' StepCode ConvKumiline
' All Rights Reserved, Copyright (c) 2002 Sankyoalumi
'*********************************************************************
' ���p���FWSH(Windows Script Host)�����K�v�ł��B
' ���p����FWSH,VBScript
'*********************************************************************
' �@�\	�F�f�B���N�g���̐������s��
' �T�v	�F�f�B���N�g���̃^�C���X�^���v�𔻒肵�č폜����B
' �쐬��	�FOogaki Shoji (Sankyoalumi)
' �쐬��	�F2005/01/12
' ����		�FArg1=�����f�B���N�g���@Arg2=�폜����
' �X�V�����F
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
wscript.echo "Dir   �@�F" & objArgs(0)
wscript.echo "�폜���ԁF" & objArgs(1)

dtTime = DateAdd("d",objArgs(1),NOW())
Dim strYear, strMonth, strDay
strYear  = Year(dtTime)  : If Len(strYear)  = 2 Then strYear  = "20" & strYear
strMonth = Month(dtTime) : If Len(strMonth) = 1 Then strMonth = "0"  & strMonth
strDay   = Day(dtTime)   : If Len(strDay)   = 1 Then strDay   = "0"  & strDay

strHeder = strYear & strMonth & strDay
wscript.echo "�폜��  �F" & dtTime

dim sf,sfc
dim f, f1
Set f = fso.GetFolder(objArgs(0))
Set sf = f.SubFolders

Dim strSubDir

For Each f1 in sf
	strSubDir = f1.name
	if strSubDir <= strHeder And Left(strSubDir, 1) <> "." then
		'���f�B���N�g���̍폜
		wscript.echo "Delete�F" & strSubDir
		nRet = fso.DeleteFolder(objArgs(0) & "\" & strSubDir)
	end if
Next
set sf  = nothing
set f   = nothing
