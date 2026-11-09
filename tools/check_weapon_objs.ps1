$ErrorActionPreference = 'Stop'
$P = 'D:\gameProject\FVM-Reborn-mod'

# 项目里所有已定义的资源名（从 yyp 的 resources 段抓，最快最准）
$yyp = [System.IO.File]::ReadAllText((Join-Path $P 'FVM_Reborn_makk.yyp'), [System.Text.Encoding]::UTF8)
$defined = @{}
foreach ($m in [regex]::Matches($yyp, '"name":"([^"]+)","path":"(sprites|objects|sounds|fonts|scripts|shaders)/')) {
    $defined[$m.Groups[1].Value] = $m.Groups[2].Value
}
Write-Host "yyp 已注册资源: $($defined.Count)"

$targets = @(
    'obj_gods_shield_gem_1','obj_gods_shield_gem_2','obj_gods_shield_gem_3','obj_gods_shield_gem_4',
    'obj_poseidon_dart_gun_gem_1','obj_poseidon_dart_gun_gem_2','obj_poseidon_dart_gun_gem_3','obj_poseidon_dart_gun_gem_4',
    'obj_death_scythe','obj_death_scythe_enter','obj_death_scythe_bullet',
    'obj_death_scythe_gem_1','obj_death_scythe_gem_2','obj_death_scythe_gem_3','obj_death_scythe_gem_4',
    'obj_poseidon_dart_gun'
)

$missing = @()
$checked = 0
foreach ($obj in $targets) {
    $dir = Join-Path $P ('objects\' + $obj)
    if (-not (Test-Path $dir)) { $missing += "对象目录缺失: $obj"; continue }
    foreach ($f in Get-ChildItem $dir -Filter '*.gml') {
        $checked++
        $txt = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        foreach ($m in [regex]::Matches($txt, '\b(spr|obj|snd|font|scr|sh)_[A-Za-z0-9_]+')) {
            $nm = $m.Value
            # 跳过注释里的和 CARD_STATE 之类
            if (-not $defined.ContainsKey($nm)) {
                # 有些是函数/变量，只报 obj_/spr_ 前缀
                if ($nm -match '^(obj|spr|snd|font)_') {
                    $missing += ("{0}/{1}: 未注册符号 {2}" -f $obj, $f.Name, $nm)
                }
            }
        }
    }
}
Write-Host "扫描 gml 文件: $checked"

if ($missing.Count -eq 0) {
    Write-Host '符号检查通过：没有缺失资源'
} else {
    Write-Host "`n发现 $($missing.Count) 个问题："
    $missing | Sort-Object -Unique | ForEach-Object { Write-Host "  $_" }
}

# 括号平衡
# 只做粗检：忽略字符串与注释后的 ( ) { } [ ] 配对
Write-Host "`n=== 括号平衡粗检 ==="
foreach ($obj in $targets) {
    $dir = Join-Path $P ('objects\' + $obj)
    foreach ($f in Get-ChildItem $dir -Filter '*.gml') {
        $txt = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        $t2 = [regex]::Replace($txt, '(?s)/\*.*?\*/', '')
        $t2 = [regex]::Replace($t2, '//[^\r\n]*', '')
        $t2 = [regex]::Replace($t2, '"(?:[^"\\]|\\.)*"', '""')
        $o1 = ([regex]::Matches($t2, '\(')).Count; $c1 = ([regex]::Matches($t2, '\)')).Count
        $o2 = ([regex]::Matches($t2, '\{')).Count; $c2 = ([regex]::Matches($t2, '\}')).Count
        $o3 = ([regex]::Matches($t2, '\[')).Count; $c3 = ([regex]::Matches($t2, '\]')).Count
        if ($o1 -ne $c1 -or $o2 -ne $c2 -or $o3 -ne $c3) {
            Write-Host ("  !! {0}/{1}: ( {2}/{3}  {{ {4}/{5}  [ {6}/{7}" -f $obj, $f.Name, $o1, $c1, $o2, $c2, $o3, $c3)
        }
    }
}
Write-Host '括号检查完成'
