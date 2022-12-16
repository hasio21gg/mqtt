####################################################################################################
# システム名    ：
# サブシステム名：
# ファイル名    ：
#
# 概要説明      ：
#
####################################################################################################
# 変更履歴      ：
# 改定                         変更理由                                               担当者
# 番号  変更日     バージョン  案件/問題   変更内容                                   氏名
# 001   2022-10-07 ver.1.0.0   新規        初版                                        橋本　英雄
####################################################################################################
Set-StrictMode -Version Latest
# 例外処理を終了するエラー(Stop)まで対象にする (既定：Continue 続行するエラー)
$ErrorActionPreference = "Stop"
# 戻り値 0 正常, 1 異常 8 対応可能処置を行う
$script:rc = 0

#$CMDNAM  = $myInvocation.MyCommand.Name
#where /R . /T filelist_proc1.txt
#       465   2022/10/06      11:18:52  d:\ap99999\mqtt\mqtt1\filelist_proc1.txt

if ($Args.Length -eq  0 ){
    $rc = 9
    Write-Host "ERROR: Args ZERO. Return[${rc}]" 
    exit $rc
}
$filename = $Args[0]
$filepath = $Args[1]
#DIRであること
if ( -not (Test-Path $filepath )){
    $rc = 9
    Write-Host "ERROR: Directory Not Found. Return[${rc}]" 
    exit $rc
}
$response = Get-ChildItem -Path ${filepath}\* `
    -Include ${filename} | `
    Select FullName, `
    Length, `
    @{ `
        Name="LastWriteTime"; `
        Expression={$_.LastWriteTime.ToString("HH:mm:ss.fff")} `
    },`
    @{ `
        Name="LastWriteDate"; `
        Expression={$_.LastWriteTime.ToString("yyyy/MM/dd")} `
    }

$cnt = ($response | Measure-Object).Count
if ( $cnt -eq 0 ){
    $rc = 8
    Write-Host "DONE: Files Not Found. Return[${rc}]" 
    exit $rc
}
foreach ($file in $response) {
    Write-Output ("{0}`t{1}`t{2}`t{3}" -f (
        $file.Length, 
        $file.LastWriteDate,
        $file.LastWriteTime,
        $file.FullName
        )
    )
}
exit $rc
