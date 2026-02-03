# Clawdbot 新電腦還原與安裝指南

**備份日期**: 2026-01-30  
**備份檔案**: `clawdbot-backup-20260130.tar.gz`（位於本機「下載」資料夾）

本指南說明如何在新電腦上正確安裝 Clawdbot，並還原舊電腦的**技能、記憶、設定與對話**。

---

## 交付物一：打包完整的檔案

**檔案名稱**: `clawdbot-backup-20260130.tar.gz`  
**位置**: `/Users/user/Downloads/clawdbot-backup-20260130.tar.gz`（或「下載」資料夾）

**內容包含**:
- `clawdbot.json` — 主設定（API、channel、gateway、agents 等）
- `agents/` — Agent 認證（auth-profiles.json）與所有對話 session（.jsonl）
- `memory/` — 記憶資料庫（main.sqlite）
- `credentials/` — Telegram 等配對資訊
- `devices/` — 裝置配對（paired.json、pending.json）
- `identity/` — 裝置身份
- `cron/` — 排程任務
- `telegram/` — Telegram 更新 offset
- `exec-approvals.json` — 執行審核設定
- `media/inbound/`、`media/outbound/` — 媒體檔案
- `skills/` — 工作區技能（ai-pdf-builder、oracle、solar-weather、pdf_generate、auto_cursor 等）

**請將此單一檔案** 複製到新電腦（隨身碟、雲端、AirDrop 等）。

---

## 交付物二：在新電腦正確安裝並還原技能與記憶

### 一、新電腦環境準備（macOS 為例）

#### 1. 安裝 Node.js（建議 18+ 或 20+）

- 官網：https://nodejs.org  
- 或 Homebrew：`brew install node`

驗證：
```bash
node -v
npm -v
```

#### 2. 安裝 Clawdbot

```bash
npm install -g clawdbot@latest
```

驗證：
```bash
clawdbot --version
```

#### 3. 若需 ai-pdf-builder 功能

```bash
# Pandoc
brew install pandoc

# LaTeX（BasicTeX）
brew install --cask basictex

# 安裝後重開終端，或執行：
eval "$(/usr/libexec/path_helper)"

# 中文/Unicode 支援
sudo tlmgr install collection-langcjk
```

PATH 設定（加入 `~/.zshrc`）：
```bash
export PATH="/Library/TeX/texbin:/usr/local/texlive/2025basic/bin/universal-darwin:$PATH"
```

然後執行：`source ~/.zshrc`

#### 4. 全域安裝 ai-pdf-builder（可選）

```bash
npm install -g ai-pdf-builder
```

---

### 二、還原備份（技能、記憶、設定）

假設 `clawdbot-backup-20260130.tar.gz` 已複製到新電腦的 **下載** 或 **桌面**。

#### 1. 解壓縮

```bash
cd ~
tar -xzvf ~/Downloads/clawdbot-backup-20260130.tar.gz
```

會產生目錄 `clawdbot-backup/`。

#### 2. 建立 .clawdbot 並還原

```bash
mkdir -p ~/.clawdbot

cp clawdbot-backup/clawdbot.json ~/.clawdbot/
cp -R clawdbot-backup/agents ~/.clawdbot/
cp -R clawdbot-backup/memory ~/.clawdbot/
cp -R clawdbot-backup/credentials ~/.clawdbot/
cp -R clawdbot-backup/devices ~/.clawdbot/
cp -R clawdbot-backup/identity ~/.clawdbot/
cp -R clawdbot-backup/cron ~/.clawdbot/
cp -R clawdbot-backup/telegram ~/.clawdbot/
cp clawdbot-backup/exec-approvals.json ~/.clawdbot/ 2>/dev/null || true

mkdir -p ~/.clawdbot/media
cp -R clawdbot-backup/media/inbound ~/.clawdbot/media/
cp -R clawdbot-backup/media/outbound ~/.clawdbot/media/ 2>/dev/null || true
```

#### 3. 還原工作區技能（對應舊電腦的 ~/clawd/skills）

```bash
mkdir -p ~/clawd
cp -R clawdbot-backup/skills ~/clawd/
```

#### 4. 清理暫存

```bash
rm -rf ~/clawdbot-backup
```

---

### 三、修正 workspace 路徑（若新電腦使用者名稱不同）

若新電腦的**使用者名稱**不是 `user`，需修改設定中的 workspace 路徑。

1. 開啟 `~/.clawdbot/clawdbot.json`
2. 找到 `agents.defaults.workspace`
3. 將路徑改為新電腦的實際路徑，例如：`/Users/你的新帳號/clawd`

或在新電腦建立與舊電腦相同的目錄結構（例如維持 `~/clawd`），則可不必改。

---

### 四、環境變數（API Key 等）

若舊電腦曾在 `~/.zshrc` 設定 API Key 或 TeX PATH，請在新電腦的 `~/.zshrc` 手動加入相同內容，例如：

```bash
# TeX/LaTeX
export PATH="/Library/TeX/texbin:/usr/local/texlive/2025basic/bin/universal-darwin:$PATH"

# API Key（若使用）
# export ANTHROPIC_API_KEY="你的_key"
# export OPENROUTER_API_KEY="你的_key"
```

存檔後執行：`source ~/.zshrc`。

---

### 五、驗證還原是否正確

```bash
# 檢查 Clawdbot 狀態
clawdbot status

# 檢查設定與資料是否存在
ls -la ~/.clawdbot/clawdbot.json
ls -la ~/.clawdbot/agents/main/agent/
ls -la ~/.clawdbot/memory/
ls ~/clawd/skills/
```

若以上檔案與目錄都存在，表示**技能與記憶已還原**。

---

### 六、重新配對（若需要）

- **Telegram**：若換電腦後 bot 無法收發，可能需重新取得 token 或重新配對（依你使用的登入方式）。
- **裝置/節點**：若有配對手機或其他裝置，可能需在新電腦上重新執行配對流程。

---

### 七、舊電腦曾做過的程式修改（可選）

舊電腦上若曾修改過以下檔案，新電腦安裝後可能需要**手動再改一次**（或等套件更新）：

1. **Clawdbot — 網路錯誤不退出**  
   檔案：`/usr/local/lib/node_modules/clawdbot/dist/infra/unhandled-rejections.js`  
   已將 AbortError、fetch failed 視為暫時性錯誤，不呼叫 `process.exit(1)`。

2. **Clawdbot — Daemon PATH 含 TeX**  
   檔案：`/usr/local/lib/node_modules/clawdbot/dist/daemon/service-env.js`  
   已在 darwin 的 PATH 中加入 `/Library/TeX/texbin` 與 TeX Live 路徑。

3. **ai-pdf-builder — 使用 xelatex**  
   檔案：`/usr/local/lib/node_modules/ai-pdf-builder/dist/index.js` 與 `dist/cli.js`  
   已將 `--pdf-engine=pdflatex` 改為 `--pdf-engine=xelatex`。

以上為進階選項；若新電腦未改，僅還原備份也可正常使用，僅部分行為可能與舊電腦略有差異。

---

## 快速檢查清單

- [ ] 新電腦已安裝 Node.js、npm
- [ ] 已執行 `npm install -g clawdbot@latest`
- [ ] 已將 `clawdbot-backup-20260130.tar.gz` 複製到新電腦
- [ ] 已解壓並還原到 `~/.clawdbot/` 與 `~/clawd/skills`
- [ ] 已檢查/修正 `agents.defaults.workspace` 路徑
- [ ] 已設定 PATH 與 API Key（若有需要）
- [ ] 已執行 `clawdbot status` 確認正常
- [ ] 若使用 ai-pdf-builder：已安裝 Pandoc、BasicTeX、collection-langcjk

完成以上步驟後，新電腦上的 Clawdbot 即具備與舊電腦相同的**技能與記憶**，並可依本指南持續維護。

---

## 附錄：本機安裝路徑（NVM）

若新電腦使用 **NVM** 管理 Node，Clawdbot 會安裝在 NVM 目錄下，例如：

- **指令**：`~/.nvm/versions/node/<版本>/bin/clawdbot`
- **套件目錄**：`~/.nvm/versions/node/<版本>/lib/node_modules/clawdbot`

查詢方式：終端機執行 `which clawdbot` 與 `npm root -g` 即可得知實際路徑。  
本機還原的具體指令與路徑請見同資料夾中的 **《本機還原指令與安裝位置》**。
