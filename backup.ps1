# ==============================
# PowerShell-AutoBackup
# CSV出力対応版
# ==============================

# ===== 設定 ===== #

# 対象フォルダ
$Source = "$env:USERPROFILE\Documents"

# スクリプトファイルのパス
$scriptPath = $MyInvocation.MyCommand.Path

# スクリプトのあるフォルダ
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# バックアップ先フォルダ
$backupRoot = Join-Path $scriptDir "backup"

# 基準日（直近1か月）
$borderDate = (Get-Date).AddMonths(-1)

# CSV出力先
$csvPath = Join-Path $backupRoot "backup_list.csv"


# ===== バックアップフォルダ作成 ===== #
if (-not (Test-Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}

# ===== 対象ファイル抽出 ===== #
$recentFiles = Get-ChildItem -Path $Source -Recurse -File |
    Where-Object {
        $_.LastWriteTime -ge $borderDate -and
        $_.FullName -notlike "$backupRoot*" -and
        $_.FullName -ne $scriptPath
    }

# ===== CSV　出力用配列 ===== #
$copiedFiles = @()

# ===== コピー処理 ===== #
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
    try {
        Copy-Item -Path $file.FullName -Destination $destination -Force -ErrorAction Stop
        $status = "Success"        
    } catch {
        $status = "Locked / Skipped"        
    }

    # CSV 用レコード
    $copiedFiles += [PSCustomObject]@{
        FileName = $file.Name
        OriginalPath  = $file.FullName
        LastWriteTime = $file.LastWriteTime
        CopiedAt      = Get-Date
        Status        = $status
    }
}


# ===== CSV 出力 =====
if ($copiedFiles.Count -gt 0) {
    $copiedFiles | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
}


exit 0