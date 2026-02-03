# 05-備份資料

本資料夾存放 **實際備份內容**（ClawdBot/OpenClaw 設定、workspace、sessions、憑證、媒體等）。

## ⚠️ 重要提醒

- **內含敏感資訊**：API 金鑰、Token、對話紀錄、裝置配對等可能在此目錄中。  
- **請勿上傳至公開 GitHub 倉庫**。若使用 Git，請在倉庫根目錄的 `.gitignore` 中加入 `05-備份資料/`。  
- 僅供本機還原或遷移使用，分享給他人時請先移除憑證與個人資料。

## 本目錄可能包含

- `clawdbot-backup/` — 舊版備份目錄結構  
- `clawdbot-full-backup-20260202/` — 完整備份（clawdbot 設定 + workspace 記憶與知識）  
- `clawdbot-backup-20260130.tar.gz` — 壓縮包備份  

還原步驟請參照 **02-還原與重裝** 中的對應指南。
