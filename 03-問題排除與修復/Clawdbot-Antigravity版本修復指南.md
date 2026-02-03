# Clawdbot Antigravity 版本過期與 Gateway 啟動修復指南

本指南記錄了 2026/02/01 遇到的 Antigravity 版本封鎖問題及其解決方案，適用於 macOS 環境。

## 1. 問題現象
*   **Telegram 報錯**：`This version of Antigravity is no longer supported. Please update to receive the latest features!`
*   **Gateway 報錯**：`Gateway port 18789 is not listening` 或 `ECONNREFUSED`。
*   **原因**：Google 伺服器端停用了舊版 Antigravity 的 `userAgent` 版本號（1.11.5）。

---

## 2. 核心修復步驟 (手動修改版本號)

由於 Clawdbot 官方依賴的 `pi-ai` 套件尚未更新版本號，需手動修改本地檔案。

### 步驟 A：修改版本號
執行以下指令，將版本號從 `1.11.5` 替換為 `1.15.8`：
```bash
sed -i '' 's/1\.11\.5/1.15.8/g' /Users/user/.nvm/versions/node/v24.13.0/lib/node_modules/clawdbot/node_modules/@mariozechner/pi-ai/dist/providers/google-gemini-cli.js
```

### 步驟 B：徹底重啟服務
必須先殺掉佔用端口的舊行程，否則新設定不會生效：
```bash
# 1. 停止服務
clawdbot gateway stop

# 2. 強制殺掉殘留行程 (PID)
lsof -iTCP:18789 -sTCP:LISTEN | awk 'NR>1 {print $2}' | xargs kill -9

# 3. 重新註冊並啟動
clawdbot gateway install
clawdbot gateway start
```

---

## 3. 系統更新與資料保護 (重要觀念)

### 程式本體 vs. 個人資料
*   **程式本體 (可刪除)**：`/Users/user/.nvm/versions/node/v24.13.0/lib/node_modules/clawdbot`
    *   如果更新卡住，可以 `rm -rf` 刪除後重新 `npm install -g clawdbot`。
*   **個人資料 (絕對不可刪除)**：
    *   **記憶與設定**：`~/.clawdbot/`
    *   **工作區與開發技能**：`/Users/user/clawd/`
    *   *註：npm 指令不會觸碰以上兩個資料夾。*

### 技能重新連結 (Symlink)
重新安裝主程式後，需手動連回自定義技能：
```bash
# 連結 agent-browser 技能
sudo ln -sf /Users/user/clawd/skills/agent-browser /usr/local/lib/node_modules/clawdbot/skills/agent-browser
```

---

## 4. 故障排除 (Troubleshooting)
*   **如果還是報錯**：執行 `clawdbot configure` 選擇 **Google Antigravity** 重新登入。
*   **如果出現 Keychain 視窗**：務必點選 **「永遠允許 (Always Allow)」**，否則背景服務會卡住。
*   **檢查狀態**：執行 `clawdbot status` 確保 Gateway 是綠色的 `reachable`。

## 5. 參考資料
*   [OpenClaw Antigravity 版本過期手動修復 (ZeroOne)](https://laplusda.com/posts/openclaw-antigravity-version-fix/)
*   [Clawdbot 官方 GitHub Issues #4111](https://github.com/moltbot/moltbot/issues/4111)

---
*最後更新日期：2026-02-01*
