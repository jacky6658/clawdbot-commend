#!/bin/bash
# Clawdbot 備份還原腳本 — 請在「終端機」中執行此腳本（本機執行才有寫入權限）
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP="$SCRIPT_DIR/clawdbot-backup"

if [[ ! -d "$BACKUP" ]]; then
  echo "錯誤：找不到備份目錄 $BACKUP"
  exit 1
fi

echo "備份來源: $BACKUP"
echo "還原目標: ~/.clawdbot 與 ~/clawd"
echo "---"
read -p "按 Enter 開始還原，或 Ctrl+C 取消..."

mkdir -p ~/.clawdbot
cp "$BACKUP/clawdbot.json" ~/.clawdbot/
cp -R "$BACKUP/agents" ~/.clawdbot/
cp -R "$BACKUP/memory" ~/.clawdbot/
cp -R "$BACKUP/credentials" ~/.clawdbot/
cp -R "$BACKUP/devices" ~/.clawdbot/
cp -R "$BACKUP/identity" ~/.clawdbot/
cp -R "$BACKUP/cron" ~/.clawdbot/
cp -R "$BACKUP/telegram" ~/.clawdbot/
cp "$BACKUP/exec-approvals.json" ~/.clawdbot/ 2>/dev/null || true

mkdir -p ~/.clawdbot/media
cp -R "$BACKUP/media/inbound" ~/.clawdbot/media/
cp -R "$BACKUP/media/outbound" ~/.clawdbot/media/ 2>/dev/null || true

mkdir -p ~/clawd
cp -R "$BACKUP/skills" ~/clawd/

echo ""
echo "--- 還原完成 ---"
echo "請執行以下指令驗證："
echo "  clawdbot status"
echo "  ls -la ~/.clawdbot/clawdbot.json ~/.clawdbot/memory/main.sqlite ~/clawd/skills/"
