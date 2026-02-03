# OpenClaw-本機安裝與安全重裝指南

本文件旨在提供一份在**本機環境**（例如 macOS、Linux 個人電腦或 Windows WSL2）安裝 OpenClaw 的完整指南，並詳細說明如何在保護現有記憶與知識的前提下，安全地進行備份、刪除與重新安裝。所有步驟均基於 OpenClaw 官方文件 [1] [2] [3]。

---

## 一、本機安裝前的準備

### 1. 系統需求

在開始安裝前，請確保您的本機環境符合以下基本要求：

| 元件 | 要求 |
| :--- | :--- |
| **作業系統** | macOS、Linux 或 Windows (透過 WSL2) |
| **Node.js** | 版本 >= 22 |

> **Windows 使用者注意**：強烈建議使用 Windows Subsystem for Linux 2 (WSL2) 來模擬 Linux 環境，以獲得最佳的相容性與體驗。

### 2. 安裝 Node.js

如果您的系統尚未安裝 Node.js，建議使用 `nvm` (Node Version Manager) 來安裝，以便管理多個 Node.js 版本。

```bash
# 1. 安裝 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 2. 讓 nvm 指令生效 (或重開終端機)
source ~/.bashrc

# 3. 安裝 Node.js v22
nvm install 22

# 4. 設為預設版本並驗證
nvm use 22
nvm alias default 22
node -v # 應顯示 v22.x.x
```

---

## 二、OpenClaw 本機安裝流程

官方提供了多種安裝方式，對於大多數使用者而言，**一鍵安裝腳本**是最簡單、最推薦的選擇。

### 方法一：一鍵安裝腳本 (推薦)

此腳本會自動處理 npm 全域安裝並啟動引導設定精靈。

-   **macOS / Linux / WSL2:**
    ```bash
    curl -fsSL https://openclaw.ai/install.sh | bash
    ```

-   **Windows (PowerShell):**
    ```powershell
    iwr -useb https://openclaw.ai/install.ps1 | iex
    ```

安裝完成後，腳本會自動進入下一步的**引導設定精靈 (Onboarding Wizard)**，請依照提示完成 AI 模型、通訊軟體等設定。

### 方法二：手動全域安裝

如果您偏好手動操作，也可以使用 `npm` 或 `pnpm` 進行全域安裝。

```bash
# 使用 npm
npm install -g openclaw@latest

# 安裝後手動啟動引導精靈
openclaw onboard --install-daemon
```

> **疑難排解**：若安裝後執行 `openclaw` 指令出現 `command not found` 錯誤，通常是 npm 的全域路徑未加入系統的 `PATH` 環境變數。請將 `$(npm prefix -g)/bin` 的路徑加入您的 `~/.zshrc` 或 `~/.bashrc` 設定檔中。

---

## 三、安全備份與重新安裝

當您需要更新版本、遷移主機或解決嚴重問題時，可能需要重新安裝 OpenClaw。以下步驟將引導您如何在**不遺失任何記憶與知識**的前提下，安全地完成此操作。

### 步驟一：備份您的「龍蝦」核心資料

在進行任何刪除操作前，**備份是絕對必要的第一步**。OpenClaw 的核心資料（記憶、知識、設定）都儲存在特定目錄中。

#### 1. 需要備份的關鍵檔案與目錄

根據官方文件 [3]，最重要的資料位於 `~/.openclaw/` 目錄下：

| 資料類型 | 檔案/目錄路徑 | 說明 |
| :--- | :--- | :--- |
| **長期記憶** | `~/.openclaw/workspace/MEMORY.md` | 您精心整理的、最重要的核心知識。 |
| **每日記憶** | `~/.openclaw/workspace/memory/` | 以日期命名的每日對話與筆記。 |
| **設定檔** | `~/.openclaw/config.json` | 包含模型、插件等所有設定。 |
| **憑證檔** | `~/.openclaw/credentials/` | 儲存所有 API 金鑰與 Token。**極度敏感！** |
| **對話歷史** | `~/.openclaw/sessions.json` | 正在進行中的對話狀態。 |

#### 2. 執行備份指令

您可以執行以下指令，將所有重要資料備份到 `~/openclaw_backup` 目錄中：

```bash
# 建立一個安全的備份目錄
mkdir -p ~/openclaw_backup

# 備份整個 workspace (包含所有記憶檔案)
cp -r ~/.openclaw/workspace ~/openclaw_backup/

# 備份設定檔、憑證與對話歷史
cp ~/.openclaw/config.json ~/openclaw_backup/
cp -r ~/.openclaw/credentials ~/openclaw_backup/
cp ~/.openclaw/sessions.json ~/openclaw_backup/

echo "備份完成！您的 OpenClaw 核心資料已儲存至 ~/openclaw_backup 目錄。"
```

### 步驟二：徹底解除安裝 OpenClaw

備份完成後，您可以使用官方提供的指令來徹底移除 OpenClaw 及其相關服務。

```bash
# 執行官方的自動化解除安裝指令
# --all 會移除所有相關檔案，包括設定與 workspace
# --yes 會跳過所有確認提示
openclaw uninstall --all --yes
```

此指令會自動停止並移除背景服務、刪除 `~/.openclaw` 目錄、並移除 CLI 工具。

### 步驟三：重新安裝 OpenClaw

現在您的系統已經回到乾淨狀態，請依照本文件第二部分的**本機安裝流程**，使用一鍵腳本或手動方式重新安裝 OpenClaw。

**注意**：在重新安裝後的引導設定過程中，您可以先跳過或填寫任意的臨時資訊，因為我們稍後會用備份來覆蓋它們。

### 步驟四：還原您的「龍蝦」核心資料

安裝完成並至少執行過一次 `openclaw onboard` 後，`~/.openclaw` 目錄會被重新建立。現在，我們可以將之前備份的資料還原回來。

```bash
# 停止正在運行的 OpenClaw 服務，以避免檔案衝突
openclaw gateway stop

# 從備份目錄還原所有資料
cp -r ~/openclaw_backup/workspace ~/.openclaw/
cp ~/openclaw_backup/config.json ~/.openclaw/
cp -r ~/openclaw_backup/credentials ~/.openclaw/
cp ~/openclaw_backup/sessions.json ~/.openclaw/

echo "還原完成！"
```

### 步驟五：啟動並驗證

最後，重新啟動 OpenClaw 服務，並檢查狀態以確認您的記憶與知識是否都已成功還原。

```bash
# 重新啟動服務
openclaw gateway start

# 檢查健康狀況
openclaw health

# 與您的機器人對話，確認它是否記得之前的內容
```

透過以上五個步驟，您就可以在完整保護「龍蝦」記憶的前提下，安全地完成重新安裝，確保您的 AI 夥伴的知識與經驗得以傳承。

---

## 四、參考資料

[1] OpenClaw. (n.d.). *Install*. OpenClaw Docs. Retrieved February 2, 2026, from https://docs.openclaw.ai/install

[2] OpenClaw. (n.d.). *Uninstall*. OpenClaw Docs. Retrieved February 2, 2026, from https://docs.openclaw.ai/install/uninstall

[3] OpenClaw. (n.d.). *Memory*. OpenClaw Docs. Retrieved February 2, 2026, from https://docs.openclaw.ai/concepts/memory
