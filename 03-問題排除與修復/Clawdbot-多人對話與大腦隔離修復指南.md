# Clawdbot 多人對話卡頓與大腦隔離修復指南

本指南記錄了如何解決 Bot 在多人同時使用時出現的卡頓、排隊超時（Lane wait exceeded）以及網路請求中斷（AbortError）的問題。

## 1. 問題現象
*   **卡死 2 分鐘**：Telegram 顯示「正在輸入中」，但最後出現 `typing TTL reached (2m)`。
*   **排隊超時**：日誌顯示 `lane wait exceeded`，訊息處理延遲超過 100 秒。
*   **大腦混亂**：多人的對話紀錄混在一起，導致 AI 邏輯崩潰。
*   **報錯**：出現 `AbortError: This operation was aborted`。

---

## 2. 核心解決方案：開啟「大腦隔離」

為了讓 Bot 能同時服務多人而不互踢，必須開啟 `per-channel-peer` 模式，讓每個使用者擁有獨立的對話 Session。

### 步驟 A：修改隔離設定
在終端機執行以下指令：
```bash
# 設定大腦隔離：每個人擁有獨立對話空間
clawdbot config set session.dmScope "per-channel-peer"
```

### 步驟 B：修正模型路徑 (避免找不到 Key)
確保所有備援模型都指向正確的 Google 驗證管道：
```bash
sed -i '' 's/"anthropic\//"google-antigravity\//g' ~/.clawdbot/clawdbot.json
```

### 步驟 C：徹底大掃除並重啟
清除卡住的對話快取，並重新啟動服務：
```bash
# 1. 停止服務
clawdbot gateway stop

# 2. 強制殺掉殘留行程
lsof -iTCP:18789 -sTCP:LISTEN | awk 'NR>1 {print $2}' | xargs kill -9 2>/dev/null

# 3. 清除導致卡頓的舊對話快取 (重要：這能打破無限重啟迴圈)
rm -rf ~/.clawdbot/agents/main/sessions/

# 4. 重新註冊並啟動
clawdbot gateway install
clawdbot gateway start
```

---

## 3. 常見錯誤與原因分析

| 錯誤訊息 | 原因 | 解決方法 |
| :--- | :--- | :--- |
| `Unrecognized key: "dmScope"` | 設定放錯位置（例如放在 telegram 區塊） | 使用 `clawdbot config set session.dmScope` |
| `AbortError` | 請求被中斷（通常是多人搶奪同一個 Session） | 開啟 `per-channel-peer` 隔離大腦 |
| `lane wait exceeded` | 訊息在排隊（前一個人的 AI 還沒跑完） | 開啟 `per-channel-peer` 讓 Bot 同時思考 |
| `typing TTL reached` | AI 思考超時或模型連線卡死 | 換成更穩定的模型（如 `gemini-2.0-flash`） |

---

## 4. 教學同事時的穩定性建議
1.  **開啟隔離**：務必確認 `dmScope` 為 `per-channel-peer`。
2.  **監控頻率**：如果有人傳太快，可能會觸發 `Rate limit`。
3.  **模型選擇**：建議主力模型使用 `google-gemini-cli/gemini-2.0-flash`，反應最快。

---
*最後更新日期：2026-02-02*
