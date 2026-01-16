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

# ログフォルダ
$logDir = Join-Path $scriptDir "logs"



# ===== バックアップフォルダ作成 ===== #
if (-not (Test-Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}


# ===== ログ出力先の作成 ===== #
# ログフォルダの作成 #
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# ログ出力先
$logPath = Join-Path $logDir "backup.log"


# ===== ログ出力関数 ===== #
function Write-Log {
    param([string]$Message)
    $time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logPath -Value "$time $Message"

}

Write-Log "=== Backup Start ==="
Write-Log "Source: $Source"
Write-Log "BorderDate: $borderDate"


# ===== 対象ファイル抽出 ===== #
$recentFiles = Get-ChildItem -Path $Source -Recurse -File |
    Where-Object {
        $_.LastWriteTime -ge $borderDate -and
        $_.FullName -notlike "$backupRoot*" -and
        $_.FullName -ne $scriptPath
    }

Write-Log "Target files count: $($recentFiles.Count)"

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

    Write-Log "$status : $($file.FullName)"

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

Write-Log "Export CSV: Done)"


# ===== 終了ログ =====
$successCount = @($copiedFiles | Where-Object { $_.Status -eq "Success" }).Count
$skipCount = @($copiedFiles | Where-Object { $_.Status -ne "Success" }).Count

Write-Log "Success: $successCount, Skipped: $skipCount"
Write-Log "=== Backup End ==="


exit 0