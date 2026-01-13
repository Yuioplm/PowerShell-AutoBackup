# 対象フォルダ
$Source = "$env:USERPROFILE\Documents"

#基準日（直近1か月）
$borderDate = (Get-Date).AddMonths(-1)

#直近1か月以内に更新されたファイル
$recentFiles = Get-ChildItem -Path $Source -Recurse -File |
    Where-Object { $_.LastWriteTime -ge $borderDate }

#バックアップ先フォルダ
$backupRoot = Join-Path $PSScriptRoot "backup"

#バックアップフォルダがなければ作成
if (-not (Test-Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}

#フォルダ構成を維持してコピー
foreach ($file in $recentFiles) {
    #元フォルダからの相対パス
    $relativePath = $file.FullName.Substring($Source.Length)

}


