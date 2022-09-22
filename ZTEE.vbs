Option Explicit
Dim StdErr
Dim StdIn
Dim StdOut
Dim line
dim logf

If WScript.Arguments.Count Then
  logf = WScript.Arguments(0)
  Set StdErr=CreateObject("Scripting.FileSystemObject").OpenTextFile(logf, 2, True)
Else
  Set StdErr=WScript.StdErr
End If
Set StdIn=WScript.StdIn
Set StdOut=WScript.StdOut
Do While Not StdIn.AtEndOfStream
  line=StdIn.ReadLine
  StdOut.WriteLine line
  StdErr.WriteLine line
Loop
