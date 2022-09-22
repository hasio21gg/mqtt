'*********************************************************************
' ConvNs1 V01L01 COMMAND UTILITY
' StepCode ConvKumiline
' All Rights Reserved, Copyright (c) 2002 Sankyoalumi
'*********************************************************************
' ���p���FWSH(Windows Script Host)�����K�v�ł��B
' ���p����FWSH,VBScript
'*********************************************************************
' �@�\	�F	�w��̃t�@�C�����^�C���X�^���v�t�f�B���N�g���Ɋi�[����B
'			����t�H���_�ɍ쐬����B
'			[2005.11.19] Hashimoto	Log4j�d�l�ɑΉ�(Name.log.yyyymmdd����)
' �쐬�ҁF	Oogaki Shoji (Sankyoalumi)
' �쐬���F	2005/01/12
' ����	�F	Arg1=�f�B���N�g���@Arg2=�ޔ�����i�ߋ��H���j
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
Dim dtTime,strHeder

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
		'SearchString ="XXpXXpXXPXXP"   ' �����Ώۂ̕�����B
		'SearchChar = "P"   ' "P" ���������܂��B
		'MyPos = InstrRev(SearchString, SearchChar, 10, 0)   ' 10 �Ԗڂ̕�������A�o�C�i�� ���[�h�Ŕ�r���s���܂��B9 ��Ԃ��܂��B
		'MyPos = InstrRev(SearchString, SearchChar, -1, 1)   ' �Ō�̕�������A�e�L�X�g ���[�h�Ŕ�r���s���܂��B12 ��Ԃ��܂��B
		'MyPos = InstrRev(SearchString, SearchChar, 8)   ' ����ł̓o�C�i�� ���[�h�Ŕ�r���s���܂� (�Ō�̈����́A�ȗ�����܂�)�B0 ��Ԃ��܂��B
		'If strFile8R <= strHeder then
		'	strFile8 = strFile8R
		'End If
		If Len(strFile8R) = 8 Then
				Wscript.Echo strFile & "-" & strFile8R & InstrRev(strFile, ".", -1)
				strFile8 = strFile8R
		End If
		

	End If
	If strFile8 <= strHeder then
		'���t�H���_���ݗL���m�F
		strFolder   = objArgs(0) & "\" & strFile8 
		If Not fso.FolderExists(strFolder) then

			'���t�H���_�Ɠ����̃t�@�C�������݂���ꍇ�̓t�@�C����.Org���ɕύX����B
			If fso.FileExists(strFolder) Then
				strFile = strFile & ".Org"
				strFilePath =objArgs(0) & "\" & strFile
				nRet = fso.CopyFile(strFolder,strFilePath)
				nRet = fso.DeleteFile(strFolder)
			End If

			'���t�H���_�쐬
			nRet = fso.CreateFolder(strFolder)

		End If

		'���t�H���_�փR�s�[
		strFilePath = objArgs(0) & "\" & strFile
		If fso.FileExists(strFilePath) Then
			wscript.echo "MoveFile�F" & strFilePath & " �� " & strFolder
			strFilePathS = strFolder & "\" & strFile
			nRet = fso.CopyFile(strFilePath,strFilePathS)
			nRet = fso.DeleteFile(strFilePath)
		End If
	End If
Next
set fc  = nothing
set f   = nothing
