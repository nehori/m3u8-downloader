# M3U8 ダウンローダー

暗号化されたM3U8ストリーミングファイルをダウンロードしてMP4に変換するツールです。

## 機能
- video.m3u8とaudio.m3u8を別々にダウンロード
- 暗号化されたストリームの復号化
- 映像と音声を結合してMP4出力

## 必要なもの
- Windows PowerShell
- [FFmpeg](https://ffmpeg.org/download.html) (C:\ffmpeg\bin\に配置)

## 使い方

### 準備
1. `video.m3u8`と`audio.m3u8`を用意
2. スクリプトと同じフォルダに配置

### 実行
```batch
run.bat
```

## ファイル構成
```
├── run.bat                      # 実行用バッチ
├── download_video_with_key.ps1  # 映像ダウンロード
├── download_audio_with_key.ps1  # 音声ダウンロード
├── merge_encrypted.ps1          # 結合・変換
├── video.m3u8                   # 映像プレイリスト（ユーザー用意）
└── audio.m3u8                   # 音声プレイリスト（ユーザー用意）
```

## 出力
- `output.mp4` - 最終的な動画ファイル

## FFmpegパスの変更
`merge_encrypted.ps1`の最初の部分を編集：
```powershell
$ffmpegPath = "C:\ffmpeg\bin\ffmpeg"  # ここを変更
```

## ライセンス
パブリックドメイン。詳細は[LICENSE](LICENSE)を参照
