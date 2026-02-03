# Clawdbot / OpenClaw Gateway 埠 18789 佔用與啟動失敗解決指南

若您遇到 `Gateway failed to start`、`Port 18789 is already in use` 或 `Gateway port 18789 is not listening (service appears running)`，可依本指南排查。  
**說明**：若您使用的是 OpenClaw，請將下列指令中的 `clawdbot` 改為 `openclaw`；資料目錄為 `~/.openclaw`。

---

## 問題 A：埠被舊行程佔用

**現象**：顯示 `gateway already running (pid XXXX)`，導致無法啟動。

### 解決步驟

1. **先停止現有服務**
   ```bash
   clawdbot gateway stop
   ```

2. **若仍佔用，清除佔用 18789 的行程**
   ```bash
   lsof -iTCP:18789 -sTCP:LISTEN | awk 'NR>1 {print $2}' | xargs kill -9
   ```

3. **重新啟動**
   ```bash
   clawdbot gateway start
   ```

---

## 問題 B：服務顯示 Running 但埠未監聽（1006 錯誤）

**現象**：狀態顯示 `running (pid XXXX)`，但報錯 `Gateway port 18789 is not listening`。常見原因為 NVM 路徑不一致或 LaunchAgent 設定過舊。

### 解決步驟

1. **執行自動修復診斷**
   ```bash
   clawdbot doctor --repair
   ```
   會嘗試修正 LaunchAgent 中的 Node 路徑問題。

2. **停止、清空埠、再啟動**
   ```bash
   clawdbot gateway stop
   lsof -iTCP:18789 -sTCP:LISTEN | awk 'NR>1 {print $2}' | xargs kill -9
   clawdbot gateway start
   ```

---

## 進階排錯：查看錯誤日誌

若上述步驟仍無法解決，可查看日誌確認錯誤原因：

- **錯誤日誌**：
  ```bash
  tail -n 50 ~/.clawdbot/logs/gateway.err.log
  ```
- **一般日誌**：
  ```bash
  tail -n 50 ~/.clawdbot/logs/gateway.log
  ```
（OpenClaw 使用者請改為 `~/.openclaw/logs/`。）

---

## 日常管理快速對照

| 需求 | 指令 |
|------|------|
| 正常重啟 | `clawdbot gateway restart` |
| 查看狀態 | `clawdbot gateway status` |
| 安裝為背景服務 | `clawdbot gateway install` |
| 修復環境問題 | `clawdbot doctor --repair` |

---

## 驗證

執行完畢後執行 `clawdbot gateway status`。若看到 **`online`** 且無 `failed` 訊息，即表示修復成功。
