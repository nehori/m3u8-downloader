# ===== 設定項目 =====
# 必要に応じて変更してください
$videoFolder = "tmp_ts"
$videoM3U8 = "video.m3u8"
$encryptionKeyFile = "encryption.key"

# ===== メイン処理（変更なし）=====
# 固定フォルダの作成
$folder = $videoFolder
New-Item -ItemType Directory -Force -Path $folder | Out-Null

# m3u8ファイルを読み込み
$m3u8Content = Get-Content $videoM3U8

# 暗号化キーをダウンロード
foreach ($line in $m3u8Content) {
    if ($line -match 'URI="([^"]+)"') {
        $keyUrl = $matches[1]
        Write-Host "暗号化キーをダウンロード中..."
        Invoke-WebRequest -Uri $keyUrl -OutFile "$folder\$encryptionKeyFile"
        break
    }
}

# TSファイルをダウンロード
$tsUrls = $m3u8Content | Where-Object { $_ -match "^https.*\.ts" }
$counter = 0

foreach ($url in $tsUrls) {
    # 単純に連番でファイル名を作成
    $filename = "segment_${counter}.ts"
    
    Write-Host "Downloading $filename..."
    Invoke-WebRequest -Uri $url -OutFile "$folder\$filename"
    $counter++
}

Write-Host "完了！"