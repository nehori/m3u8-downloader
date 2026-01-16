# ===== 設定項目 =====
$ffmpegPath = "C:\ffmpeg\bin\ffmpeg"  # 環境に応じて変更してください
$videoM3U8 = "video.m3u8"
$audioM3U8 = "audio.m3u8"
$encryptionKey = "encryption.key"
$videoFolder = "tmp_ts"
$audioFolder = "tmp_audio"
$finalOutput = "output.mp4"

# ===== 関数定義 =====
# 映像と音声の両方を処理する関数
function Process-M3U8($m3u8File, $outputName, $keyName, $folderName) {
    Set-Location $folderName
    
    # m3u8ファイルを読み込み
    $lines = Get-Content "..\$m3u8File"
    
    # HTMLエンティティを修正して処理
    $newLines = @()
    $hasEncryption = $false
    $tsCounter = 0
    
    foreach ($line in $lines) {
        $cleanLine = $line.Replace('&quot;', '"').Replace('&amp;', '&').Replace('&lt;', '<').Replace('&gt;', '>')
        
        if ($cleanLine -match '#EXT-X-KEY:.*URI="([^"]+)"') {
            $hasEncryption = $true
            $newLine = $cleanLine -replace 'URI="[^"]+"', "URI=`"$keyName`""
            $newLines += $newLine
        } elseif ($cleanLine -match '^https://.*\.ts') {
            # 統一されたファイル名形式を使用
            $newFilename = "segment_${tsCounter}.ts"
            $newLines += $newFilename
            $tsCounter++
        } else {
            $newLines += $cleanLine
        }
    }
    
    # BOMなしUTF-8で保存
    $Encoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines("$PWD\local.m3u8", $newLines, $Encoding)
    
    Write-Host "$outputName を作成中..."
    
    # 暗号化の有無に応じてffmpegコマンドを調整
    if ($hasEncryption) {
        & $ffmpegPath -allowed_extensions ALL -protocol_whitelist "file,crypto" -i local.m3u8 -c copy $outputName
    } else {
        & $ffmpegPath -i local.m3u8 -c copy $outputName
    }
    
    Set-Location ..
    return Test-Path "$folderName\$outputName"
}

# ===== メイン処理 =====
$videoExists = Test-Path $videoM3U8
$audioExists = Test-Path $audioM3U8

if (-not $videoExists) {
    Write-Host "エラー: $videoM3U8 が見つかりません。"
    exit
}

# 映像処理
Write-Host "=== 映像処理 ==="
$videoSuccess = Process-M3U8 $videoM3U8 "video.mp4" $encryptionKey $videoFolder

# 音声ファイルが存在する場合のみ処理
if ($audioExists) {
    Write-Host "`n=== 音声処理 ==="
    $audioSuccess = Process-M3U8 $audioM3U8 "audio.mp4" $encryptionKey $audioFolder
    
    # 映像と音声を結合
    if ($videoSuccess -and $audioSuccess) {
        Write-Host "`n=== 映像と音声を結合 ==="
        & $ffmpegPath -i "$videoFolder\video.mp4" `
              -i "$audioFolder\audio.mp4" `
              -c:v copy -c:a copy `
              -map 0:v -map 1:a `
              -bsf:a aac_adtstoasc `
              -movflags +faststart `
              $finalOutput
        if (Test-Path $finalOutput) {
            $fileInfo = Get-Item $finalOutput
            Write-Host "完了！$finalOutput が作成されました。(サイズ: $([math]::Round($fileInfo.Length/1MB, 2)) MB)"
            
            # 中間ファイルを削除
            Remove-Item "$videoFolder\video.mp4" -Force
            Remove-Item "$audioFolder\audio.mp4" -Force
        }
    }
} else {
    if ($videoSuccess) {
        Write-Host "`n=== 映像ファイルを最終出力として使用 ==="
        Move-Item "$videoFolder\video.mp4" $finalOutput -Force
        
        if (Test-Path $finalOutput) {
            $fileInfo = Get-Item $finalOutput
            Write-Host "完了！$finalOutput が作成されました。(サイズ: $([math]::Round($fileInfo.Length/1MB, 2)) MB)"
        }
    }
}