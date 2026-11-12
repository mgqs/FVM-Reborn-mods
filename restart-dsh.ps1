# restart-dsh.ps1 — 让 D:\DSH\home\.env 与 billion-context 补丁生效
#
# 背景：bili_gate_oversize_refusal_unattributed_bytes 这个本地 422，来自
# billion-context 0.1.213 的 native fetch 拦截器：会话 session-ff35a2e7 的请求
# 无法归属到 bili 会话（attribution state = none），只能走 uncompressed 直连，
# 而直连有 8 MiB 硬上限，该请求 10.45 MB → 本地拒绝。
#
# 已做的三处改动（都需要重启 DSH 才加载）：
#   1. D:\DSH\home\.env
#        BILI_SILENT_DIRECT_MAX_MB=32      # 直连上限 8 MiB -> 32 MiB
#        BILI_HTTP_OUTBOUND_BYTES=4194304  # proxy lane byte-shed 预算 10 MiB -> 4 MiB
#   2. dsh-native.js 的 attribution 回退补丁（sessionId 缺失时回退 currentInitiator / sticky sid）
#   3. 备份：dsh-native.js.bak-20261112-105519
#
# 用法：关掉 DSH 桌面后运行本脚本（或在任意 PowerShell 窗口直接运行）。

$ErrorActionPreference = 'Stop'

$exe = 'D:\ruanjian\dsh\DSH Desktop\DSH Desktop.exe'
if (-not (Test-Path $exe)) {
    $exe = (Get-ChildItem 'D:\ruanjian\dsh' -Recurse -Filter 'DSH Desktop.exe' -ErrorAction SilentlyContinue |
            Select-Object -First 1).FullName
}
if (-not $exe) { throw 'DSH Desktop.exe not found' }

Write-Host '== stopping DSH Desktop ==' -ForegroundColor Cyan
Get-CimInstance Win32_Process -Filter "Name='DSH Desktop.exe'" |
    Where-Object { $_.ParentProcessId -notin (Get-CimInstance Win32_Process -Filter "Name='DSH Desktop.exe'").ProcessId } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 3
Get-Process -Name 'DSH Desktop' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host '== stopping stale bili proxy ==' -ForegroundColor Cyan
Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
    Where-Object { $_.CommandLine -like '*billion-context*dist\index.js start*' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 1

Write-Host '== starting DSH Desktop ==' -ForegroundColor Cyan
Start-Process -FilePath $exe -WorkingDirectory (Split-Path $exe)
Start-Sleep -Seconds 20

Write-Host '== verification ==' -ForegroundColor Cyan
$log = Join-Path $env:USERPROFILE '.local\state\billion-context\bili.log'
$proc = Get-CimInstance Win32_Process -Filter "Name='node.exe'" |
    Where-Object { $_.CommandLine -like '*billion-context*' } |
    Select-Object -First 1
if ($proc) {
    # 读取新起 host 进程的环境变量不可行，改为间接验证：日志里应出现 attribution active
    Write-Host "bili proxy pid = $($proc.ProcessId)"
}
if (Test-Path $log) {
    Write-Host "--- last 5 attribution / 422 lines ---"
    Select-String -Path $log -Pattern 'attribution active|unattributed oversized|takeover gate refused' |
        Select-Object -Last 5 | ForEach-Object { $_.Line }
}
Write-Host ''
Write-Host '看两件事：' -ForegroundColor Yellow
Write-Host '  1) 是否出现 "llm/stream attribution active" —— 有则说明补丁生效，请求回到 proxy lane 可压缩。'
Write-Host '  2) 失败会话再发一条消息，是否还出现 "unattributed oversized model request refused ... 8,388,608 B"。'
