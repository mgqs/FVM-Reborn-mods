$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$source = Join-Path $root 'Launcher.cs'
$output = Join-Path $root '关卡工坊.exe'

if (-not (Test-Path -LiteralPath $compiler)) {
    throw "未找到 .NET Framework C# 编译器：$compiler"
}

& $compiler /nologo /target:winexe /platform:anycpu /reference:System.Windows.Forms.dll "/resource:$(Join-Path $root 'index.html'),index.html" "/out:$output" "$source"
if ($LASTEXITCODE -ne 0) {
    throw "关卡工坊编译失败，退出代码：$LASTEXITCODE"
}
Write-Output "已生成：$output"
