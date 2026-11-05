# 把 D 盘页文件上限提到 49152 MB —— 解决 GMAssetCompiler 纹理打包 OOM
# 用法：右键「使用 PowerShell 运行」，或在管理员 PowerShell 里执行。
# 修改后必须重启才生效。

$ErrorActionPreference = 'Stop'
$InitialMB = 16384
$MaximumMB = 49152
$Drive = 'D:'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host '需要管理员权限，正在提权重启本脚本...' -ForegroundColor Yellow
    Start-Process -FilePath (Get-Process -Id $PID).Path -Verb RunAs `
        -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath
    return
}

$name = "$Drive\pagefile.sys"
$pf = Get-CimInstance Win32_PageFileSetting -Filter "Name='$($name.Replace('\','\\'))'"
if (-not $pf) {
    Write-Host "未找到 $name 的页文件设置，请先在 sysdm.cpl 里为 $Drive 创建页文件。" -ForegroundColor Red
    Read-Host '按回车退出'
    return
}

Write-Host ("修改前: {0}  {1}-{2} MB" -f $pf.Name, $pf.InitialSize, $pf.MaximumSize)
Set-CimInstance -InputObject $pf -Property @{ InitialSize = $InitialMB; MaximumSize = $MaximumMB }

Write-Host '--- 修改后 ---' -ForegroundColor Green
Get-CimInstance Win32_PageFileSetting | ForEach-Object {
    Write-Host ("{0}  {1}-{2} MB" -f $_.Name, $_.InitialSize, $_.MaximumSize)
}
Write-Host ''
Write-Host '注意：必须重启电脑，提交内存上限才会真正提升。' -ForegroundColor Yellow
Read-Host '按回车退出'
