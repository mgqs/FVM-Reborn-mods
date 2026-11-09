# ============================================================
#  音频转 OGG（Vorbis）图形转换器
#  用法：双击「音频转OGG-GUI.bat」，或右键本文件「使用 PowerShell 运行」
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# 高 DPI 适配（避免高分屏下界面模糊）
try {
    $sig = '[DllImport("user32.dll")] public static extern bool SetProcessDPIAware();'
    $dpi = Add-Type -MemberDefinition $sig -Name 'Dpi' -Namespace 'Win32' -PassThru
    [void]$dpi::SetProcessDPIAware()
} catch { }

# ---------------- 全局状态 ----------------
$script:Files      = New-Object System.Collections.ArrayList   # 待转换文件（完整路径）
$script:LastOutDir = ""
$script:Running    = $false
$script:CancelFlag = $false
$script:FFmpeg     = ""

$script:AudioExt = @(".mp3", ".flac", ".wav", ".m4a", ".aac", ".wma", ".ape", ".aiff", ".aif", ".mp2", ".mpga")

# ---------------- 工具函数 ----------------
function Find-FFmpeg {
    $cands = New-Object System.Collections.ArrayList
    foreach ($root in @("C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes",
                        "C:\ProgramData\GameMakerStudio2\Cache\runtimes")) {
        if (Test-Path $root) {
            Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue |
                Sort-Object Name -Descending |
                ForEach-Object {
                    $p = Join-Path $_.FullName "bin\ffmpeg\windows\ffmpeg.exe"
                    if (Test-Path $p) { [void]$cands.Add($p) }
                }
        }
    }
    $local = Join-Path $PSScriptRoot "ffmpeg.exe"
    if (Test-Path $local) { [void]$cands.Add($local) }
    $cmd = Get-Command "ffmpeg.exe" -ErrorAction SilentlyContinue
    if ($cmd) { [void]$cands.Add($cmd.Source) }

    foreach ($c in $cands) {
        if (Test-Path -LiteralPath $c) { return $c }
    }
    return $null
}

function Write-Log([string]$text, [string]$color = "Black") {
    $script:txtLog.SelectionStart = $script:txtLog.TextLength
    $script:txtLog.SelectionLength = 0
    try { $script:txtLog.SelectionColor = [System.Drawing.Color]::FromName($color) } catch { }
    $script:txtLog.AppendText($text + "`r`n")
    $script:txtLog.SelectionStart = $script:txtLog.TextLength
    $script:txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

function Update-Count {
    $script:lblCount.Text = "待转换：" + $script:Files.Count + " 个文件"
    $script:btnStart.Enabled = ($script:Files.Count -gt 0) -and (-not $script:Running)
}

function Add-PathItem([string]$p) {
    if ([string]::IsNullOrWhiteSpace($p)) { return }
    $p = $p.Trim('"')
    if (-not (Test-Path -LiteralPath $p)) { return }

    if (Test-Path -LiteralPath $p -PathType Container) {
        Get-ChildItem -LiteralPath $p -File -ErrorAction SilentlyContinue |
            Where-Object { $script:AudioExt -contains $_.Extension.ToLower() } |
            ForEach-Object {
                if (-not $script:Files.Contains($_.FullName)) { [void]$script:Files.Add($_.FullName) }
            }
    } else {
        $ext = [System.IO.Path]::GetExtension($p).ToLower()
        if ($script:AudioExt -contains $ext) {
            if (-not $script:Files.Contains($p)) { [void]$script:Files.Add($p) }
        }
    }
    Refresh-List
}

function Refresh-List {
    $script:lst.Items.Clear()
    foreach ($f in $script:Files) {
        $item = [System.IO.Path]::GetFileName($f)
        if ($script:lst.Items.Contains($item)) {
            $item = $item + "   (" + (Split-Path $f -Parent) + ")"
        }
        [void]$script:lst.Items.Add($item)
    }
    Update-Count
}

function Get-UniquePath([string]$dir, [string]$baseName, [bool]$overwrite) {
    $target = Join-Path $dir ($baseName + ".ogg")
    if ($overwrite -or -not (Test-Path $target)) { return $target }
    $i = 2
    while ($true) {
        $target = Join-Path $dir ($baseName + "_" + $i + ".ogg")
        if (-not (Test-Path $target)) { return $target }
        $i++
    }
}

# ---------------- 字体与配色 ----------------
$fntBase  = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$fntSmall = New-Object System.Drawing.Font("Microsoft YaHei UI", 8.5)
$fntTitle = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$fntMono  = New-Object System.Drawing.Font("Consolas", 8.5)

# ---------------- 主窗体 ----------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "音频转 OGG（Vorbis）"
$form.Size = New-Object System.Drawing.Size(760, 668)
$form.MinimumSize = New-Object System.Drawing.Size(680, 600)
$form.StartPosition = "CenterScreen"
$form.Font = $fntBase
$form.MaximizeBox = $false

$lblHead = New-Object System.Windows.Forms.Label
$lblHead.Text = "把 mp3 / flac / wav / m4a / aac / wma / ape 拖进下面的列表 → 点「开始转换」"
$lblHead.Location = New-Object System.Drawing.Point(16, 12)
$lblHead.Size = New-Object System.Drawing.Size(710, 20)
$lblHead.Font = $fntSmall
$lblHead.ForeColor = [System.Drawing.Color]::FromArgb(90, 90, 90)
$form.Controls.Add($lblHead)

# ---- 文件列表 ----
$lst = New-Object System.Windows.Forms.ListBox
$lst.Location = New-Object System.Drawing.Point(16, 38)
$lst.Size = New-Object System.Drawing.Size(710, 210)
$lst.AllowDrop = $true
$lst.SelectionMode = "MultiExtended"
$lst.HorizontalScrollbar = $true
$lst.IntegralHeight = $false
$form.Controls.Add($lst)
$script:lst = $lst

$lst.add_DragEnter({
    if ($_.Data.GetDataPresent([System.Windows.Forms.DataFormats]::FileDrop)) {
        $_.Effect = [System.Windows.Forms.DragDropEffects]::Copy
    } else {
        $_.Effect = [System.Windows.Forms.DragDropEffects]::None
    }
})
$lst.add_DragDrop({
    $paths = $_.Data.GetData([System.Windows.Forms.DataFormats]::FileDrop)
    foreach ($p in $paths) { Add-PathItem $p }
})

# ---- 文件操作按钮 ----
$btnAddFile = New-Object System.Windows.Forms.Button
$btnAddFile.Text = "添加文件"
$btnAddFile.Location = New-Object System.Drawing.Point(16, 254)
$btnAddFile.Size = New-Object System.Drawing.Size(90, 28)
$form.Controls.Add($btnAddFile)

$btnAddDir = New-Object System.Windows.Forms.Button
$btnAddDir.Text = "添加文件夹"
$btnAddDir.Location = New-Object System.Drawing.Point(112, 254)
$btnAddDir.Size = New-Object System.Drawing.Size(100, 28)
$form.Controls.Add($btnAddDir)

$btnDel = New-Object System.Windows.Forms.Button
$btnDel.Text = "移除选中"
$btnDel.Location = New-Object System.Drawing.Point(218, 254)
$btnDel.Size = New-Object System.Drawing.Size(90, 28)
$form.Controls.Add($btnDel)

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "清空"
$btnClear.Location = New-Object System.Drawing.Point(314, 254)
$btnClear.Size = New-Object System.Drawing.Size(70, 28)
$form.Controls.Add($btnClear)

$lblCount = New-Object System.Windows.Forms.Label
$lblCount.Text = "待转换：0 个文件"
$lblCount.Location = New-Object System.Drawing.Point(400, 260)
$lblCount.Size = New-Object System.Drawing.Size(330, 20)
$lblCount.Font = $fntSmall
$lblCount.ForeColor = [System.Drawing.Color]::FromArgb(70, 70, 70)
$form.Controls.Add($lblCount)
$script:lblCount = $lblCount

# ---- 选项区 ----
$chkSameDir = New-Object System.Windows.Forms.CheckBox
$chkSameDir.Text = "输出到源文件所在目录"
$chkSameDir.Location = New-Object System.Drawing.Point(16, 294)
$chkSameDir.Size = New-Object System.Drawing.Size(200, 22)
$chkSameDir.Checked = $true
$form.Controls.Add($chkSameDir)

$lblOut = New-Object System.Windows.Forms.Label
$lblOut.Text = "输出目录："
$lblOut.Location = New-Object System.Drawing.Point(16, 324)
$lblOut.AutoSize = $true
$form.Controls.Add($lblOut)

$txtOut = New-Object System.Windows.Forms.TextBox
$txtOut.Location = New-Object System.Drawing.Point(104, 321)
$txtOut.Size = New-Object System.Drawing.Size(540, 26)
$txtOut.Enabled = $false
$form.Controls.Add($txtOut)

$btnOut = New-Object System.Windows.Forms.Button
$btnOut.Text = "..."
$btnOut.Location = New-Object System.Drawing.Point(650, 320)
$btnOut.Size = New-Object System.Drawing.Size(34, 26)
$btnOut.Enabled = $false
$form.Controls.Add($btnOut)

$lblQ = New-Object System.Windows.Forms.Label
$lblQ.Text = "音质："
$lblQ.Location = New-Object System.Drawing.Point(16, 358)
$lblQ.Size = New-Object System.Drawing.Size(50, 22)
$form.Controls.Add($lblQ)

$tbQ = New-Object System.Windows.Forms.TrackBar
$tbQ.Location = New-Object System.Drawing.Point(64, 354)
$tbQ.Size = New-Object System.Drawing.Size(420, 40)
$tbQ.Minimum = 0
$tbQ.Maximum = 10
$tbQ.TickFrequency = 1
$tbQ.Value = 6
$tbQ.SmallChange = 1
$tbQ.LargeChange = 1
$form.Controls.Add($tbQ)

$lblQVal = New-Object System.Windows.Forms.Label
$lblQVal.Text = "6  ≈ 192 kbps"
$lblQVal.Location = New-Object System.Drawing.Point(492, 360)
$lblQVal.Size = New-Object System.Drawing.Size(200, 20)
$lblQVal.Font = $fntSmall
$form.Controls.Add($lblQVal)

$lblOver = New-Object System.Windows.Forms.Label
$lblOver.Text = ""

$tip = New-Object System.Windows.Forms.ToolTip
$tip.SetToolTip($lblOver, "同名 ogg 会自动加 _2 / _3，不会覆盖已有文件。")
$tip.SetToolTip($chkSameDir, "勾选时转换结果放在每首歌旁边；取消后可指定一个统一输出目录。")
$tip.SetToolTip($tbQ, "0~10，默认 6（约 192 kbps）。数值越大音质越好、文件越大。")

# ---- 开始 / 停止 ----
$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text = "开始转换"
$btnStart.Location = New-Object System.Drawing.Point(16, 426)
$btnStart.Size = New-Object System.Drawing.Size(140, 40)
$btnStart.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
$btnStart.BackColor = [System.Drawing.Color]::FromArgb(0, 130, 200)
$btnStart.ForeColor = [System.Drawing.Color]::White
$btnStart.FlatStyle = "Flat"
$btnStart.Enabled = $false
$form.Controls.Add($btnStart)
$script:btnStart = $btnStart

$btnStop = New-Object System.Windows.Forms.Button
$btnStop.Text = "停止"
$btnStop.Location = New-Object System.Drawing.Point(164, 426)
$btnStop.Size = New-Object System.Drawing.Size(80, 40)
$btnStop.Enabled = $false
$form.Controls.Add($btnStop)

$bar = New-Object System.Windows.Forms.ProgressBar
$bar.Location = New-Object System.Drawing.Point(254, 432)
$bar.Size = New-Object System.Drawing.Size(472, 28)
$bar.Minimum = 0
$bar.Maximum = 100
$bar.Value = 0
$form.Controls.Add($bar)
$script:bar = $bar

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "就绪"
$lblStatus.Location = New-Object System.Drawing.Point(16, 474)
$lblStatus.Size = New-Object System.Drawing.Size(710, 20)
$lblStatus.Font = $fntSmall
$lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(70, 70, 70)
$form.Controls.Add($lblStatus)
$script:lblStatus = $lblStatus

# ---- 日志 ----
$txtLog = New-Object System.Windows.Forms.RichTextBox
$txtLog.Location = New-Object System.Drawing.Point(16, 496)
$txtLog.Size = New-Object System.Drawing.Size(710, 108)
$txtLog.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::Vertical
$txtLog.ReadOnly = $true
$txtLog.DetectUrls = $false
$txtLog.BackColor = [System.Drawing.Color]::FromArgb(250, 250, 250)
$txtLog.Font = $fntMono
$txtLog.Anchor = "Top,Bottom,Left,Right"
$form.Controls.Add($txtLog)
$script:txtLog = $txtLog

# ---------------- 事件 ----------------
$chkSameDir.add_CheckedChanged({
    $same = $chkSameDir.Checked
    $script:txtOut.Enabled = -not $same
    $script:btnOut.Enabled = -not $same
})

$btnOut.add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "选择输出目录"
    if ($script:LastOutDir -ne "") { $dlg.SelectedPath = $script:LastOutDir }
    if ($dlg.ShowDialog() -eq "OK") {
        $script:txtOut.Text = $dlg.SelectedPath
        $script:LastOutDir = $dlg.SelectedPath
    }
})

$btnAddFile.add_Click({
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = "选择音频文件"
    $dlg.Filter = "音频文件|*.mp3;*.flac;*.wav;*.m4a;*.aac;*.wma;*.ape;*.aiff;*.aif;*.mp2|所有文件|*.*"
    $dlg.Multiselect = $true
    if ($dlg.ShowDialog() -eq "OK") {
        foreach ($f in $dlg.FileNames) { Add-PathItem $f }
    }
})

$btnAddDir.add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "选择包含音频的文件夹"
    if ($dlg.ShowDialog() -eq "OK") { Add-PathItem $dlg.SelectedPath }
})

$btnDel.add_Click({
    $idx = @($script:lst.SelectedIndices) | Sort-Object -Descending
    foreach ($i in $idx) { $script:Files.RemoveAt($i) }
    Refresh-List
})

$btnClear.add_Click({
    $script:Files.Clear()
    Refresh-List
    $script:bar.Value = 0
    $script:lblStatus.Text = "就绪"
})

$tbQ.add_Scroll({
    $v = $script:tbQ.Value
    $br = switch ($v) {
        0 { "≈ 45 kbps" }; 1 { "≈ 64 kbps" }; 2 { "≈ 80 kbps" }; 3 { "≈ 96 kbps" }
        4 { "≈ 112 kbps" }; 5 { "≈ 160 kbps" }; 6 { "≈ 192 kbps" }; 7 { "≈ 224 kbps" }
        8 { "≈ 256 kbps" }; 9 { "≈ 320 kbps" }; 10 { "≈ 500 kbps" }
    }
    $script:lblQVal.Text = "" + $v + "  " + $br
})

$btnStop.add_Click({
    $script:CancelFlag = $true
    $script:lblStatus.Text = "正在停止…（当前这首转换完就停）"
})

# ---------------- 转换主流程 ----------------
$btnStart.add_Click({
    if ($script:Running) { return }
    if ($script:Files.Count -eq 0) { return }

    if ($script:FFmpeg -eq "") {
        $script:FFmpeg = Find-FFmpeg
        if ($script:FFmpeg -eq "") {
            [void][System.Windows.Forms.MessageBox]::Show("找不到 ffmpeg.exe。`n`n请把 ffmpeg.exe 放到本脚本同目录，或安装 GameMaker。", "缺少 ffmpeg", "OK", "Warning")
            return
        }
    }

    $useSameDir = $script:chkSameDir.Checked
    $outDir = $script:txtOut.Text.Trim()
    if (-not $useSameDir -and $outDir -eq "") {
        [void][System.Windows.Forms.MessageBox]::Show("请先选择输出目录，或勾选「输出到源文件所在目录」。", "提示", "OK", "Information")
        return
    }
    if (-not $useSameDir -and -not (Test-Path -LiteralPath $outDir)) {
        try { $null = New-Item -ItemType Directory -Path $outDir -Force }
        catch {
            [void][System.Windows.Forms.MessageBox]::Show("输出目录无法创建：`n$outDir", "错误", "OK", "Error")
            return
        }
    }

    $quality = $script:tbQ.Value
    $overwrite = $false
    $total = $script:Files.Count

    $script:Running = $true
    $script:CancelFlag = $false
    $script:btnStart.Enabled = $false
    $script:btnStop.Enabled = $true
    $script:bar.Value = 0
    $script:txtLog.Clear()

    Write-Log ("ffmpeg : " + $script:FFmpeg) "DarkGray"
    Write-Log ("音质   : -q:a " + $quality) "DarkGray"
    Write-Log ("文件数 : " + $total) "DarkGray"
    Write-Log "" "Black"

    $ok = 0; $fail = 0; $skip = 0
    $totalSrc = [long]0; $totalDst = [long]0
    $failList = New-Object System.Collections.ArrayList
    $done = 0

    foreach ($src in @($script:Files)) {
        if ($script:CancelFlag) { break }

        $done++
        $srcPath = $src
        $name = [System.IO.Path]::GetFileName($srcPath)
        $script:lblStatus.Text = "正在转换 (" + $done + "/" + $total + ")：" + $name
        $script:bar.Value = [int](($done - 1) * 100 / $total)
        [System.Windows.Forms.Application]::DoEvents()

        if ([System.IO.Path]::GetExtension($srcPath).ToLower() -eq ".ogg") {
            Write-Log ("[" + $done + "/" + $total + "] " + $name + "  → 已是 ogg，跳过") "Gray"
            $skip++
            continue
        }

        if ($useSameDir) {
            $dstDir = Split-Path $srcPath -Parent
        } else {
            $dstDir = $outDir
        }
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($srcPath)
        $dst = Get-UniquePath $dstDir $baseName $overwrite

        $argList = @(
            "-hide_banner", "-loglevel", "error", "-nostdin", "-y",
            "-i", $srcPath,
            "-vn",
            "-c:a", "libvorbis",
            "-q:a", "$quality",
            "-map_metadata", "-1",
            $dst
        )

        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $errFile = [System.IO.Path]::GetTempFileName()
        $code = -1

        # 拼命令行：Start-Process -ArgumentList 传数组不会自动加引号，
        # 含空格的路径会被拆成多个参数（"A - B.mp3" 变成 "A"、"-"、"B.mp3"），必须自己引。
        $argLine = ""
        foreach ($a0 in $argList) {
            $a = [string]$a0
            if ($a -match '[\s"]') { $argLine += '"' + ($a -replace '"', '\"') + '" ' }
            else { $argLine += $a + " " }
        }

        try {
            $proc = Start-Process -FilePath $script:FFmpeg -ArgumentList $argLine `
                        -NoNewWindow -PassThru -RedirectStandardError $errFile `
                        -RedirectStandardOutput ([System.IO.Path]::GetTempFileName())
            while (-not $proc.HasExited) {
                [System.Windows.Forms.Application]::DoEvents()
                Start-Sleep -Milliseconds 60
                if ($script:CancelFlag) { try { $proc.Kill() } catch { } ; break }
            }
            $code = $proc.ExitCode
        } catch {
            $code = -1
        }
        $sw.Stop()

        $made = (Test-Path -LiteralPath $dst) -and ((Get-Item -LiteralPath $dst).Length -gt 0)
        if ($made) {
            $sSize = (Get-Item -LiteralPath $srcPath).Length
            $dSize = (Get-Item -LiteralPath $dst).Length
            $totalSrc += $sSize; $totalDst += $dSize
            $ratio = 0
            if ($sSize -gt 0) { $ratio = [int]($dSize * 100 / $sSize) }
            Write-Log ("[" + $done + "/" + $total + "] OK  " + [math]::Round($sw.Elapsed.TotalSeconds,1) + "s  " +
                       [math]::Round($sSize/1MB,1) + " MB → " + [math]::Round($dSize/1MB,1) + " MB (" + $ratio + "%)  " + $name) "DarkGreen"
            $ok++
        } else {
            $msg = ""
            if (Test-Path $errFile) { $msg = (Get-Content -LiteralPath $errFile -Raw -Encoding UTF8) }
            if ([string]::IsNullOrWhiteSpace($msg)) { $msg = "ffmpeg 退出码 $code" }
            $first = ($msg -split "`r?`n" | Where-Object { $_.Trim() -ne "" } | Select-Object -First 2) -join " / "
            Write-Log ("[" + $done + "/" + $total + "] 失败  " + $name) "Firebrick"
            Write-Log ("        " + $first) "DarkOrange"
            [void]$failList.Add($name)
            if (Test-Path -LiteralPath $dst) { Remove-Item -LiteralPath $dst -Force -ErrorAction SilentlyContinue }
            $fail++
        }
        Remove-Item -LiteralPath $errFile -Force -ErrorAction SilentlyContinue

        $script:bar.Value = [int]($done * 100 / $total)
        [System.Windows.Forms.Application]::DoEvents()
    }

    Write-Log "" "Black"
    $summary = "完成：成功 " + $ok + "，失败 " + $fail + "，跳过 " + $skip
    if ($totalSrc -gt 0) {
        $summary += "    体积 " + [math]::Round($totalSrc/1MB,1) + " MB → " + [math]::Round($totalDst/1MB,1) + " MB"
    }
    Write-Log $summary "Black"
    if ($fail -gt 0) {
        Write-Log ("失败：" + ($failList -join "、")) "Firebrick"
    }

    $script:lblStatus.Text = $summary
    $script:Running = $false
    $script:btnStop.Enabled = $false
    Update-Count
    $script:btnStart.Enabled = $script:Files.Count -gt 0
})

# ---------------- 启动 ----------------
$form.add_Shown({
    Refresh-List
    if ($script:FFmpeg -eq "") {
        Write-Log "警告：找不到 ffmpeg.exe。请把 ffmpeg.exe 放到本脚本同目录。" "Firebrick"
    } else {
        Write-Log ("就绪。ffmpeg: " + $script:FFmpeg) "DarkGray"
    }
    Write-Log "把音频文件拖进上面的列表，或点「添加文件 / 添加文件夹」。" "DarkGray"
})

# 暴露控件给事件处理器用
$script:chkSameDir = $chkSameDir
$script:txtOut     = $txtOut
$script:btnOut     = $btnOut
$script:tbQ        = $tbQ


# 提前解析 ffmpeg 路径（放在 ShowDialog 之前，避免阻塞首帧绘制）
$script:FFmpeg = Find-FFmpeg

# 把控件挂到脚本作用域，事件处理器里才能直接引用
$script:btnStop = $btnStop
$script:lblQVal = $lblQVal

[void]$form.ShowDialog()
