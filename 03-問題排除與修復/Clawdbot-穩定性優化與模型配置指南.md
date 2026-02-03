# Clawdbot 穩定性優化與模型管道配置指南

本指南總結了如何解決 Bot 「不理人」、授權頻繁過期以及模型路徑配置錯誤的問題，確保 Bot 能夠長期穩定運行。

## 1. 核心觀念：供應商前綴 (Provider Prefix)

在 Clawdbot 中，模型名稱前的 `xxxx/` 代表的是 **「授權管道」**，而不是妳買產品的地方。

| 設定路徑 | 適用對象 | 認證方式 |
| :--- | :--- | :--- |
| `google-antigravity/` | **Claude Max 訂閱用戶** | Google 帳號 OAuth 登入 |
| `google-gemini-cli/` | **Gemini 原生用戶** | Google 帳號 OAuth 登入 |
| `anthropic/` | **API 開發者** | `sk-ant-...` 儲值序號 |

**⚠️ 重要：** 即使妳買的是 Anthropic Claude Max，因為它是透過 Google 驗證開啟的，所以在設定檔中必須寫 `google-antigravity/`。如果寫成 `anthropic/`，Bot 會因為找不到 API Key 而停止回應。

---

## 1.1 設定 Embedding 模型（記憶搜尋用）

**錯誤範例**（會出現 `Unrecognized key: "embedding"`）：
```bash
# ❌ 錯誤：agents.defaults.model 底下沒有 embedding 這個 key
clawdbot config set agents.defaults.model.embedding "google/text-embedding-004"
```

**原因**：`agents.defaults.model` 在 schema 裡只接受 `primary` 和 `fallbacks`（對話用 LLM），**不包含** embedding。

**正確做法**：Embedding 模型是給 **記憶搜尋（memory search）** 用的，要寫在 `agents.defaults.memorySearch`：

```bash
# 先設定 provider（若用 Google 嵌入）
clawdbot config set agents.defaults.memorySearch.provider "gemini"

# 再設定 embedding 模型
clawdbot config set agents.defaults.memorySearch.model "google/text-embedding-004"
```

若 Clawdbot 版本不支援 `google/text-embedding-004` 這個 id，可改用官方文件範例的 `gemini-embedding-001`：
```bash
clawdbot config set agents.defaults.memorySearch.model "gemini-embedding-001"
```

改完後執行 `clawdbot gateway restart` 讓設定生效。

---

## 2. 解決「Bot 不理人」的終極步驟

如果 Bot 突然沒反應，請依序執行以下動作：

### 步驟 A：修正模型路徑 (將所有錯誤前綴導回)
執行此指令，確保所有 Claude 模型都使用正確的 Google 驗證管道：
```bash
sed -i '' 's/"anthropic\//"google-antigravity\//g' ~/.clawdbot/clawdbot.json
```

### 步驟 B：徹底重置連線與服務
```bash
# 1. 停止服務
clawdbot gateway stop

# 2. 強制殺掉可能卡住的端口 (Port 18789)
lsof -iTCP:18789 -sTCP:LISTEN | awk 'NR>1 {print $2}' | xargs kill -9 2>/dev/null

# 3. 重新啟動
clawdbot gateway start
```

---

## 3. 提升長期穩定性的建議

### 1. 換成「系統級 Node.js」 (最推薦)
NVM 路徑不穩定是導致 Gateway 頻繁崩潰的主因。
```bash
# 安裝並連結系統 Node
brew install node@22
brew link --overwrite node@22

# 執行修復，鎖定穩定路徑
clawdbot doctor --repair
```

### 2. 解決「授權自動更新失敗」
Bot 會自動更新 Token，但如果設定檔中有重複帳號會導致失敗。
*   **修復方法**：執行 `clawdbot configure` -> 進入 `Model` -> 確保只有一組 `Google Antigravity` 或 `Google Gemini CLI` 是 Authenticated 狀態。

### 3. 修復記憶功能 (Memory Unavailable)
如果 `clawdbot status` 顯示 Memory 不可用：
```bash
rm -rf ~/.clawdbot/data/memory-core/
clawdbot gateway restart
```

---

## 4. 故障排查日誌 (Logs)
如果執行完上述步驟 Bot 還是沒反應，請輸入：
```bash
clawdbot logs --follow
```
*   看到 `TypeError: fetch failed`：代表網路/VPN 斷線。
*   看到 `No API key found`：代表步驟 A 的 `sed` 指令沒執行成功。

---
*最後更新日期：2026-02-02*
