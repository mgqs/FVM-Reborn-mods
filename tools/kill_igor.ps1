# 清理残留的 Igor.exe / GMAssetCompiler 进程
# 编译失败后 Igor 不会自行退出，残留进程占 5 GB+ 会把后续每次编译都拖死。
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File tools\kill_igor.ps1

$targets = Get-Process Igor, GMAssetCompiler -ErrorAction SilentlyContinue
if (-not $targets) {
    Write-Host '没有残留的 Igor / GMAssetCompiler 进程。' -ForegroundColor Green
    return
}

foreach ($p in $targets) {
    Write-Host ("结束 {0} (PID {1}, 占用 {2:N0} MB)" -f $p.ProcessName, $p.Id, ($p.WorkingSet64 / 1MB)) -ForegroundColor Yellow
    Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2

$left = Get-Process Igor, GMAssetCompiler -ErrorAction SilentlyContinue
if ($left) { Write-Host '仍有残留，请用任务管理器手动结束。' -ForegroundColor Red }
else { Write-Host '已清理干净。' -ForegroundColor Green }

$os = Get-CimInstance Win32_OperatingSystem
Write-Host ("当前提交: 已用 {0:N2} GB / 上限 {1:N2} GB" -f (($os.TotalVirtualMemorySize - $os.FreeVirtualMemory) / 1MB), ($os.TotalVirtualMemorySize / 1MB))
