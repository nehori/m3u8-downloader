# ===== 設定項目 =====
# 必要に応じて変更してください
$audioFolder = "tmp_audio"
$audioM3U8 = "audio.m3u8"
$encryptionKeyFile = "encryption.key"

# ===== メイン処理 =====
# 音声用フォルダの作成
$folder = $audioFolder
New-Item -ItemType Directory -Force -Path $folder | Out-Null

# audio.m3u8ファイルを読み込み
$m3u8Content = Get-Content $audioM3U8

# 暗号化キーをダウンロード（音声用）
foreach ($line in $m3u8Content) {
    if ($line -match 'URI="([^"]+)"') {
        $keyUrl = $matches[1]
        Write-Host "音声用暗号化キーをダウンロード中..."
        Invoke-WebRequest -Uri $keyUrl -OutFile "$folder\$encryptionKeyFile"
        break
    }
}

# 音声TSファイルをダウンロード
$tsUrls = $m3u8Content | Where-Object { $_ -match "^https.*\.ts" }
$counter = 0

foreach ($url in $tsUrls) {
    # 単純に連番でファイル名を作成
    $filename = "segment_${counter}.ts"
    
    Write-Host "Downloading $filename..."
    Invoke-WebRequest -Uri $url -OutFile "$folder\$filename"
    $counter++
}

Write-Host "音声ダウンロード完了！"
