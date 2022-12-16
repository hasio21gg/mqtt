####################################################################################################
# �V�X�e����    �F
# �T�u�V�X�e�����F
# �t�@�C����    �F
#
# �T�v����      �F
#
####################################################################################################
# �ύX����      �F
# ����                         �ύX���R                                               �S����
# �ԍ�  �ύX��     �o�[�W����  �Č�/���   �ύX���e                                   ����
# 001   2022-10-07 ver.1.0.0   �V�K        ����                                        ���{�@�p�Y
####################################################################################################
Set-StrictMode -Version Latest
# ��O�������I������G���[(Stop)�܂őΏۂɂ��� (����FContinue ���s����G���[)
$ErrorActionPreference = "Stop"
# �߂�l 0 ����, 1 �ُ� 8 �Ή��\���u���s��
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
#DIR�ł��邱��
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
