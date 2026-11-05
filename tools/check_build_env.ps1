# 编译前环境自检 —— 纹理打包 OOM 预防
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_build_env.ps1

$ErrorActionPreference = 'SilentlyContinue'

Write-Host '===== 1. 页文件 =====' -ForegroundColor Cyan
$totalMax = 0
Get-CimInstance Win32_PageFileSetting | ForEach-Object {
    Write-Host ("{0}  {1}-{2} MB" -f $_.Name, $_.InitialSize, $_.MaximumSize)
    $totalMax += $_.MaximumSize
}
if ($totalMax -lt 32768) {
    Write-Host "  [!] 页文件总量上限 $totalMax MB 偏小，建议 D 盘设到 49152 MB（运行 tools\set_pagefile.ps1）" -ForegroundColor Yellow
}

Write-Host ''
Write-Host '===== 2. 内存与提交 =====' -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
$totalGB = $os.TotalVirtualMemorySize / 1MB
$usedGB = ($os.TotalVirtualMemorySize - $os.FreeVirtualMemory) / 1MB
$freeGB = $totalGB - $usedGB
$physFreeGB = $os.FreePhysicalMemory / 1MB
Write-Host ("物理: {0:N2} GB, 可用 {1:N2} GB" -f ($os.TotalVisibleMemorySize / 1MB), $physFreeGB)
Write-Host ("提交: 上限 {0:N2} GB, 已用 {1:N2} GB, 余 {2:N2} GB" -f $totalGB, $usedGB, $freeGB)
if ($freeGB -lt 8) {
    Write-Host "  [!] 提交余量不足 8 GB —— 编译纹理阶段大概率 OOM，请先关掉多余后台程序" -ForegroundColor Red
} else {
    Write-Host '  [OK] 提交余量足够' -ForegroundColor Green
}

Write-Host ''
Write-Host '===== 3. 占用提交最多的进程 =====' -ForegroundColor Cyan
Get-Process | Sort-Object -Property WorkingSet64 -Descending | Select-Object -First 12 |
    ForEach-Object { Write-Host ("  {0,-30} {1,8:N0} MB  PID {2}" -f $_.ProcessName, ($_.WorkingSet64 / 1MB), $_.Id) }

Write-Host ''
Write-Host '===== 4. 残留 Igor / 编译器 =====' -ForegroundColor Cyan
$stale = Get-Process Igor, GMAssetCompiler
if ($stale) {
    $stale | ForEach-Object { Write-Host ("  [!] 残留 {0} PID {1} 占 {2:N0} MB —— 必须先结束" -f $_.ProcessName, $_.Id, ($_.WorkingSet64 / 1MB)) -ForegroundColor Red }
    Write-Host '  运行 tools\kill_igor.ps1 清理' -ForegroundColor Yellow
} else {
    Write-Host '  [OK] 无残留' -ForegroundColor Green
}

Write-Host ''
Write-Host '===== 5. 纹理页尺寸与预计页数 =====' -ForegroundColor Cyan
$optFile = 'D:\gameProject\FVM-Reborn-mod\options\windows\options_windows.yy'
if (Test-Path $optFile) {
    $page = (Select-String -Path $optFile -Pattern 'option_windows_texture_page"\s*:\s*"([^"]+)"').Matches.Groups[1].Value
    Write-Host "  当前纹理页: $page"
    if ($page -eq '2048x2048') {
        Write-Host '  2048 页 → 本项目约 131 页纹理，峰值托管堆约 7.2 GB' -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host '===== 6. 构建缓存完整性 =====' -ForegroundColor Cyan
$cache = 'D:\gameProject\gams\ziyuanhuancun\GMS2CACHE\FVM_Reborn_FB75BF12'
foreach ($f in 'macros.json', 'preferences.json', 'PlatformOptions.json', 'MainOptions.json') {
    $p = Join-Path $cache $f
    if (Test-Path $p) { Write-Host "  [OK] $f" -ForegroundColor Green }
    else { Write-Host "  [!] 缺少 $f —— 在 IDE 里点一次构建会自动重建" -ForegroundColor Yellow }
}

Write-Host ''
Write-Host '自检完成。' -ForegroundColor Cyan
