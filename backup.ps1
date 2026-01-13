# 対象フォルダ
$Source = "$env:USERPROFILE\Documents"

#基準日（直近1か月）
$borderDate = (Get-Date).AddMonths(-1)

#直近1か月以内に更新されたファイル
$recentFiles = Get-ChildItem -Path $Source -Recurse -File |
    Where-Object { $_.LastWriteTime -ge $borderDate }
