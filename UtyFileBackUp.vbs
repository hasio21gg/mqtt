'*********************************************************************
' ConvNs1 V01L01 COMMAND UTILITY
' StepCode ConvKumiline
' All Rights Reserved, Copyright (c) 2002 Sankyoalumi
'*********************************************************************
' ���p���FWSH(Windows Script Host)�����K�v�ł��B
' ���p����FWSH,VBScript
'*********************************************************************
' �@�\	�F�f�[�^�o�b�N�A�b�v
' �T�v	�F�������Ԃ�t�����ăf�[�^���o�b�N�A�b�v����B
' �쐬�ҁFOogaki Shoji (Sankyoalumi)
' �쐬���F2003/05/28
' ����	�FArg1=�R�s�[���@Arg2=�R�s�[��
'
' �X�V�����F
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
	wscript.echo "Original�F" & objArgs(0)
	wscript.echo "CopyDir �F" & objArgs(1)

	'���t�@�C���̑ޔ�
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

	'���t�@�C���̍폜
	nRet = DeleteFile(strSouceFile)


'*********************************************************************
' �@�\		�F�t�@�C���̃R�s�[
'	Arg1=�R�s�[���t�@�C��,Arg2=�R�s�[��t�@�C��
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
' �@�\		�F�t�@�C���̍폜
' Arg1=�폜�t�@�C��
'*********************************************************************
Function DeleteFile(sSouseFile)

	dim fso, blCheck

	set fso = CreateObject("Scripting.FileSystemObject")
	blCheck = (fso.FileExists(sSouseFile))
	If blCheck then
			blCheck =(fso.DeleteFile(sSouseFile))
	End if

End Function

