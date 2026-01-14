# 対象フォルダ
$Source = "$env:USERPROFILE\Documents"

# 基準日（直近1か月）
$borderDate = (Get-Date).AddMonths(-1)

# 直近1か月以内に更新されたファイル
$recentFiles = Get	-ChildItem -Path $Source -Recurse -File |
    Where-Object {
        $_.LastWriteTime -ge $borderDate -and
        $_.FullName -notlike "$backupRoot"
        }

# バックアップ先フォルダ
$backupRoot = Join-Path $PSScriptRoot "backup"

# バックアップフォルダがなければ作成
ea30276 (WIP: copy extracted files to backup)
if (-not (Test-Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}

# CSV出力先
$csvPath = Join-Path $backupRoot "backup_list.csv"

# フォルダ構成を維持してコピー
foreach ($file in $recentFiles) {
    # 元フォルダからの相対パス
    $relativePath = $file.FullName.Substring($Source.Length)

    # コピー先のフルパス
    $destination = Join-Path $backupRoot $relativePath

    # コピー先フォルダ作成
    $destinationDir = Split-Path $destination -Parent
    if (-not (Test-Path $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    }

    # 上書きしないでコピー
    if (-not (Test-Path $destination)) {
        Copy-Item -Path $file.FullName -Destination $destination 
    }
}

# CSV出力
if ($recentFiles.Count -gt 0) {
    $recentFiles | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
}
exit 0


ea30276 (WIP: copy extracted files to backup)

