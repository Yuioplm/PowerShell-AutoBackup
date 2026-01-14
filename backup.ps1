# 対象フォルダ
$Source = "$env:USERPROFILE\Documents"

# 基準日（直近1か月）
$borderDate = (Get-Date).AddMonths(-1)

# 直近1か月以内に更新されたファイル
$recentFiles = Get-ChildItem -Path $Source -Recurse -File |
    Where-Object {
        $_.LastWriteTime -ge $borderDate -and
        $_.FullName -notlike "$backupRoot*"
        }

# バックアップ先フォルダ
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backupRoot = Join-Path $scriptDir "backup"


# バックアップフォルダがなければ作成
if (-not (Test-Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}

# CSV出力先
$csvPath = Join-Path $backupRoot "backup_list.csv"

# CSV出力用配列
$copiedFiles = @()

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

    # コピー
    Copy-Item -Path $file.FullName -Destination $destination -Force
    $copiedFiles += [PSCustomObject]@{
        FileName = $file.Name
        OriginalPath  = $file.FullName
        LastWriteTime = $file.LastWriteTime
        copiedAt      = Get-Date
        }
}

# CSV出力
if ($copiedFiles.Count -gt 0) {
    $copiedFiles | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
}
exit 0



