@echo off
echo ステップ1: 暗号化キーとTSファイルをダウンロード
powershell -ExecutionPolicy Bypass -File "download_video_with_key.ps1"

echo.
echo ステップ2: 暗号化キーとTSファイルをダウンロード
powershell -ExecutionPolicy Bypass -File "download_audio_with_key.ps1"

echo.
echo ステップ3: 暗号化を解除しながら結合
powershell -ExecutionPolicy Bypass -File "merge_encrypted.ps1"

pause
