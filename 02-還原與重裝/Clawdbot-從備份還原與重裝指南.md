# OpenClaw（原 ClawdBot）從備份還原與重裝指南

本指南說明如何**依官方實作與安全文檔**重裝 OpenClaw / ClawdBot，並從**您自己的備份**還原記憶、設定與知識；重裝後並對應原防護層級（allowFrom、Control UI 僅本機、憑證權限、技能安全、Warn 三項）。

**使用前請先確認**：您已有一份完整備份（例如依「本機安裝與安全重裝指南」備份的 `~/.openclaw` 或 `~/.clawdbot`，或命名如 `clawdbot-full-backup-YYYYMMDD` 的目錄）。下列步驟中的**備份路徑請一律換成您自己的實際路徑**。

---

## 一、重裝時請依的參考文檔

請以本資料夾或課程提供的以下文檔為準進行安裝與安全重裝：

| 文檔 | 用途 |
|------|------|
| **OpenClaw 全方位實作與安全指南** | 專案背景、安全觀念、環境準備、安裝流程、引導精靈、啟動驗證、配對、應用層安全、技能安全、疑難排解、進階技巧。 |
| **OpenClaw 本機安裝與安全重裝指南** | 本機安裝（Node ≥ 22、一鍵腳本或手動 npm）、**安全備份與重新安裝的完整五步驟**（備份 → 解除安裝 → 重新安裝 → 還原 → 啟動驗證）。 |
| **OpenClaw 安全與安裝健檢報告** | 重裝後**防護對照**：allowFrom、Control UI 僅本機、憑證權限、技能安全、Warn：3 的對應（見本指南「四、重裝後對應原防護層級」）。 |

上述文檔若在「01-安裝與入門」或同一課程包中，請依實際檔名與路徑開啟。

---

## 二、本機安裝與重裝流程（摘要）

以下摘錄重點，**詳細步驟請直接看「本機安裝與安全重裝指南」**。

### 安裝（一鍵或手動）

1. **環境**：Node.js ≥ 22（可用 nvm 安裝）。
2. **安裝方式（二擇一）**  
   - 一鍵腳本（推薦）：`curl -fsSL https://openclaw.ai/install.sh | bash`  
   - 手動：`npm install -g openclaw@latest`
3. **引導設定**：`openclaw onboard --install-daemon`（或改為手動執行 `openclaw gateway`）。
4. **驗證**：`openclaw status`、`openclaw health`、`openclaw doctor`、`openclaw logs`。
5. **安全**：憑證權限、鎖定使用者權限、執行 `openclaw security audit --deep`。

### 若要「先卸載再重裝」

1. **步驟一：備份** — 備份 `~/.openclaw/`（或 `~/.clawdbot/`）的 workspace、config、credentials、sessions（文檔內有完整路徑與指令）。
2. **步驟二：解除安裝** — `openclaw uninstall --all --yes`（或 ClawdBot 對應指令）。
3. **步驟三：重新安裝** — 依上段一鍵或手動安裝，再執行 `openclaw onboard`。
4. **步驟四：還原** — 將備份複製回 `~/.openclaw/`（或 `~/.clawdbot/`）；見下方「三、備份與還原對應」。
5. **步驟五：啟動並驗證** — `openclaw gateway start`、`openclaw health`，並以對話確認記憶與知識。

---

## 三、您的備份與 OpenClaw / ClawdBot 的對應

您的備份可能是**舊版 ClawdBot** 結構（`~/.clawdbot`、`clawdbot.json`、`agents/` 等），或已是 **OpenClaw** 結構（`~/.openclaw/`、`config.json`、`credentials/`、`workspace/` 等）。還原時需做**路徑與結構對應**。

### 常見備份目錄結構

若您的備份是「完整備份」目錄（例如 `clawdbot-full-backup-YYYYMMDD` 或自訂名稱），通常會包含：

| 備份內目錄/檔案 | 內容說明 |
|-----------------|----------|
| **clawdbot/**（或對應的 openclaw 結構） | 設定與資料：clawdbot.json / config.json、agents（auth、sessions）、memory、devices、identity、cron、media、telegram 等。 |
| **workspace-memory-and-knowledge/** | 工作區記憶與知識：MEMORY.md、SOUL.md、USER.md、memory/、docs/ 等。 |

若您只是備份了 `~/.openclaw` 或 `~/.clawdbot` 整份，則上述內容會直接在備份根目錄下。

### 還原到 OpenClaw（~/.openclaw）時的對應建議

- **工作區記憶與知識**  
  - 將備份中的 **workspace** 或 **workspace-memory-and-knowledge** 的**全部內容**複製到 `~/.openclaw/workspace/`（或您設定的 workspace 路徑）。  
  - 即：MEMORY.md、SOUL.md、memory/、docs/ 等對應到 OpenClaw 的 workspace 結構。

- **設定與憑證**  
  - OpenClaw 使用 `config.json` 與 `credentials/`；舊版可能為 `clawdbot.json` 與 `agents/main/agent/auth-profiles.json`。  
  - 結構相容時可手動對應；不相容時請依官方文件在 onboard 或設定畫面重新填寫，再從舊備份**手動抄寫** API Key、Token 等，勿直接覆蓋不明結構的檔案。

- **對話歷史 / sessions**  
  - 舊備份的 sessions 可能在 `agents/main/sessions/`；OpenClaw 可能使用 `sessions.json`。若官方未提供匯入說明，可僅還原 workspace（記憶與知識），對話歷史視為可捨棄或僅供參考。

**還原指令範例（僅 workspace；請將 `<您的備份目錄>` 換成實際路徑）**：

```bash
# 先完成 openclaw 安裝並至少執行過一次 onboard，確保 ~/.openclaw 存在
# 還原工作區記憶與知識到 OpenClaw workspace
cp -R "<您的備份目錄>/workspace-memory-and-knowledge/"* ~/.openclaw/workspace/
```

若您的備份是直接複製的 `~/.openclaw`，則為：

```bash
cp -R "<您的備份目錄>/workspace" ~/.openclaw/
```

---

## 四、重裝後對應原防護層級（依健檢報告）

重裝完成並還原資料後，請對照**安全與安裝健檢報告**還原與原環境相同的防護。以下對應 **Warn：3** 及可選加強項目（allowFrom、Control UI 僅本機、憑證檔權限、技能安全）。  
**路徑說明**：若安裝的是 OpenClaw，設定與資料在 `~/.openclaw/`；若仍為 ClawdBot，則為 `~/.clawdbot/`。下列指令以 `~/.openclaw` 為例，ClawdBot 使用者請改為 `~/.clawdbot`。

### 1. allowFrom（DM 權限鎖定）

- **目標**：僅允許特定使用者與 Bot 私訊；陌生人須經配對核准。  
- **作法**：  
  - 在設定檔中設定：`channels.telegram.dmPolicy: "pairing"`；`allowFrom` 保留允許的 Telegram 使用者 ID 及配對後使用的 `"*"`（依您原設定）。  
  - **更嚴格**：設 `dmPolicy: "allowlist"`，`allowFrom` 只保留允許的 user ID（數字），**移除 `"*"`**。  
- **還原建議**：可從備份中的 `clawdbot.json` 或對應設定檔抄寫 `channels.telegram`、`allowFrom` 等相關區塊到新設定檔（結構相容時），或依上述說明手動設定。

### 2. Control UI 僅本機

- **目標**：Gateway 控制介面（埠 18789）只供本機存取。  
- **作法**：設定 `gateway.bind: "loopback"`，不要綁定到 `0.0.0.0`。本機存取：`http://127.0.0.1:18789/`。  
- **對應健檢 Warn**：僅 loopback 時「Reverse proxy headers not trusted」「Control UI allows insecure HTTP auth」可接受；若改為對外或 reverse proxy 再依指南設定。

### 3. 憑證檔權限

- **作法**：  
  ```bash
  chmod 700 ~/.openclaw/credentials
  chmod 600 ~/.openclaw/credentials/*
  ```  
  日後新增憑證檔後建議再執行一次 `chmod 600 ~/.openclaw/credentials/*`。

### 4. 技能 (Skills) 安全

- **作法**：從 ClawdHub 或社群安裝技能前，從 GitHub 等可信來源下載並**自行審核程式碼**後再安裝；不盲目信任市集預設。

### 5. 安全審核與 Warn：3 對應

- **執行審核**：`openclaw security audit --deep`（或 `clawdbot security audit --deep`）。  
- **Warn：3 對應**：維持 bind=loopback 時可不設定 trustedProxies；僅本機時 HTTP auth 風險可接受；models below recommended tiers 為可選優化。

完成以上五項後，重裝環境的防護層級即可對應健檢報告中的應用層防護與 Warn 處理方式。

---

## 五、建議操作順序（簡要）

1. **重裝與安全**：依「本機安裝與安全重裝指南」與「全方位實作與安全指南」完成安裝、onboard、驗證、安全審核與（若要做）卸載／重裝五步驟。  

2. **還原您的備份**：  
   - 先還原 **workspace**（備份中的 workspace 或 workspace-memory-and-knowledge → `~/.openclaw/workspace`）。  
   - 設定與憑證以官方結構為準，必要時手動對應或重新設定。  

3. **對應原防護層級**：依上方 **「四、重裝後對應原防護層級」** 完成 allowFrom、Control UI 僅本機、憑證檔權限、技能安全，並執行 `openclaw security audit --deep`。

這樣即可在依官方文檔的前提下重裝，在保護原有記憶與知識下還原備份，並維持與原環境相同的防護層級。
