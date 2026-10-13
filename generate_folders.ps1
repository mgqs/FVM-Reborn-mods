$ErrorActionPreference = "Stop"
$projectRoot = "D:\gameProject\FVM-Reborn-mod"
$utf8 = New-Object System.Text.UTF8Encoding($false)

# 1. Read .yyp and extract folder definitions
Write-Host "Reading .yyp file..."
$yypContent = [System.IO.File]::ReadAllText("$projectRoot\FVM_Reborn_makk.yyp", $utf8)

$folderRegex = '"folderPath":"([^"]+)","name":"([^"]+)"'
$folderMatches = [regex]::Matches($yypContent, $folderRegex)
$folders = @{}
foreach ($m in $folderMatches) {
    $folderPath = $m.Groups[1].Value
    $name = $m.Groups[2].Value
    $folders[$folderPath] = $name
}
Write-Host "Found $($folders.Count) folder definitions"

# 2. Build folder hierarchy (parent -> child folders)
$folderChildren = @{}
foreach ($path in $folders.Keys) {
    $pathWithoutExt = $path -replace '\.yy$', ''
    $idx = $pathWithoutExt.LastIndexOf('/')
    if ($idx -gt 0) {
        $parentDir = $pathWithoutExt.Substring(0, $idx)
        $parentPath = $parentDir + ".yy"
        if ($folders.ContainsKey($parentPath)) {
            if (-not $folderChildren.ContainsKey($parentPath)) {
                $folderChildren[$parentPath] = @()
            }
            $folderChildren[$parentPath] += [PSCustomObject]@{
                name = $folders[$path]
                path = $path
            }
        }
    }
}
Write-Host "Found $($folderChildren.Count) parent folders with child folders"

# 3. Scan all resource .yy files to extract parent folder paths
Write-Host "Scanning resource .yy files for parent paths..."
$resourceParents = @{}

$yyFiles = Get-ChildItem -Path $projectRoot -Recurse -Filter "*.yy" | Where-Object {
    $_.FullName -notlike "*\folders\*" -and
    $_.FullName -notlike "*\options\*" -and
    $_.FullName -notlike "*\.git\*"
}
Write-Host "Found $($yyFiles.Count) resource .yy files to scan"

foreach ($file in $yyFiles) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, $utf8)
    } catch { continue }
    if (-not $content) { continue }

    $parentMatch = [regex]::Match($content, '"path":\s*"(folders/[^"]+)"')
    if ($parentMatch.Success) {
        $parentPath = $parentMatch.Groups[1].Value
        $nameMatch = [regex]::Match($content, '"name":\s*"([^"]+)"')
        $resourceName = if ($nameMatch.Success) { $nameMatch.Groups[1].Value } else { $file.BaseName }

        $relativePath = $file.FullName.Substring($projectRoot.Length + 1) -replace '\\','/'

        if (-not $resourceParents.ContainsKey($parentPath)) {
            $resourceParents[$parentPath] = @()
        }
        $resourceParents[$parentPath] += [PSCustomObject]@{
            name = $resourceName
            path = $relativePath
        }
    }
}
Write-Host "Found parent mappings for $($resourceParents.Count) folders"

# 4. Generate folder .yy files
Write-Host "Generating folder .yy files..."
$generated = 0
$skipped = 0
$errors = @()

foreach ($folderPath in $folders.Keys) {
    $name = $folders[$folderPath]
    # Convert forward slashes to backslashes for Windows path
    $relativeWin = $folderPath -replace '/', '\'
    $fullPath = "$projectRoot\$relativeWin"

    if (Test-Path $fullPath) {
        $skipped++
        continue
    }

    # Create directory if needed
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        try {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        } catch {
            $errors += "Failed to create dir for $folderPath : $_"
            continue
        }
    }

    # Get child folders
    $children = @()
    if ($folderChildren.ContainsKey($folderPath)) {
        $children = $folderChildren[$folderPath]
    }

    # Get child resources
    $resources = @()
    if ($resourceParents.ContainsKey($folderPath)) {
        $resources = $resourceParents[$folderPath]
    }

    # Build folder entries
    $folderEntries = @()
    foreach ($child in $children) {
        $folderEntries += '    {"name":"' + $child.name + '","path":"' + $child.path + '",}'
    }
    $folderEntriesStr = $folderEntries -join ",`n"

    # Build resource entries
    $resourceEntries = @()
    foreach ($res in $resources) {
        $resourceEntries += '    {"name":"' + $res.name + '","path":"' + $res.path + '",}'
    }
    $resourceEntriesStr = $resourceEntries -join ",`n"

    $foldersArray = if ($folderEntriesStr) { "[`n$folderEntriesStr`n  ]" } else { "[]" }
    $listItemsArray = if ($resourceEntriesStr) { "[`n$resourceEntriesStr`n  ]" } else { "[]" }

    $content = "{`n"
    $content += '  "$GMFolder":"",' + "`n"
    $content += '  "%Name":"' + $name + '",' + "`n"
    $content += '  "folderPath":"' + $folderPath + '",' + "`n"
    $content += '  "isDefaultView":false,' + "`n"
    $content += '  "listViewItems":[],' + "`n"
    $content += '  "name":"' + $name + '",' + "`n"
    $content += '  "resourceType":"GMFolder",' + "`n"
    $content += '  "resourceVersion":"2.0",' + "`n"
    $content += '  "viewLocked":false,' + "`n"
    $content += '  "visible":true,' + "`n"
    $content += '  "folders":' + $foldersArray + ',' + "`n"
    $content += '  "listItems":' + $listItemsArray + ',' + "`n"
    $content += "}"

    try {
        [System.IO.File]::WriteAllText($fullPath, $content, $utf8)
        $generated++
    } catch {
        $errors += "Failed to write $folderPath : $_"
    }
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "Total folders in .yyp: $($folders.Count)"
Write-Host "Generated: $generated"
Write-Host "Skipped (already existed): $skipped"
Write-Host "Errors: $($errors.Count)"
if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Errors ==="
    foreach ($e in $errors) {
        Write-Host "  $e"
    }
}
