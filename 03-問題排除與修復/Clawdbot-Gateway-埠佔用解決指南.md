# Clawdbot-Gateway-埠佔用解決指南

如果你遇到 `Gateway failed to start`、`Port 18789 is already in use` 或是 `Gateway port 18789 is not listening (service appears running)`，請參考此指南進行修復。

---

## 問題 A：Port 被舊行程佔用
**現象**：顯示 `gateway already running (pid XXXX)`，導致無法啟動。

### 徹底解決步驟
請在本機終端機依序執行：

1. **強制停止現有服務**
   ```bash
   clawdbot gateway stop
   ```

2. **「強效清空」指令** (殺掉所有佔用 18789 的 node 行程)
   ```bash
   lsof -iTCP:18789 -sTCP:LISTEN | awk 'NR>1 {print $2}' | xargs kill -9
   ```

3. **重新啟動**
   ```bash
   clawdbot gateway start
   ```

---

## 問題 B：服務顯示 Running 但 Port 沒打開 (1006 錯誤)
**現象**：`clawdbot gateway status` 顯示 `running (pid XXXX)`，但隨後報錯 `Gateway port 18789 is not listening`。這通常是 NVM 路徑不一致或設定過舊導致。

### 修復步驟
1. **執行自動修復診斷**
   ```bash
   clawdbot doctor --repair
   ```
   *這會修正 LaunchAgent 中的 Node 路徑問題。*

2. **重置並重啟**
   ```bash
   clawdbot gateway stop
   lsof -iTCP:18789 -sTCP:LISTEN | awk 'NR>1 {print $2}' | xargs kill -9
   clawdbot gateway start
   ```

---

## 進階排錯：查看錯誤日誌
如果上述步驟都無效，請查看詳細的錯誤原因：

- **啟動錯誤日誌**：
  ```bash
  tail -n 50 ~/.clawdbot/logs/gateway.err.log
  ```
- **執行日誌**：
  ```bash
  tail -n 50 ~/.clawdbot/logs/gateway.log
  ```

---

## 日常管理快速對照表

| 需求 | 指令 |
|------|------|
| **正常重啟** | `clawdbot gateway restart` |
| **查看當前狀態** | `clawdbot gateway status` |
| **安裝為背景服務** | `clawdbot gateway install` |
| **修復環境問題** | `clawdbot doctor --repair` |

---

## 驗證
執行完畢後，執行 `clawdbot gateway status`。如果看到 **`online`** 且沒有紅色的 `failed` 訊息，即代表修復成功！
