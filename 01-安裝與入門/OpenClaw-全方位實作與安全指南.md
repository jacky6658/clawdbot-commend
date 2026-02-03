> **免責聲明**：本文件提供的資訊僅供參考，且 OpenClaw (原名 ClawdBot) 專案仍在快速發展中，部分資訊可能會隨時間變動。使用者應隨時參考官方文件以獲取最新資訊。此外，使用特定服務（如透過非官方管道取得的 Token）可能存在違反其服務條款的風險，使用者應自行評估並承擔相關責任。

# OpenClaw-全方位實作與安全指南

本文件旨在提供一份全面性的 OpenClaw (原名 ClawdBot) 實作指南，內容整合自 YouTube 上的教學影片 [1] [4] 及官方說明文件 [2] [3]，不僅涵蓋從零到一的安裝設定流程，更特別強調了安裝與使用過程中的各項**安全性最佳實踐**，希望能協助使用者在享受此強大工具的同時，也能確保自身資產與系統的安全。

---

## 一、專案背景與名稱變更

OpenClaw 是一個開源的 AI 助理專案，其核心功能是作為一個「閘道器（Gateway）」，將各種大型語言模型（LLM）與多種通訊軟體串接起來，讓使用者可以透過熟悉的聊天介面（如 Telegram、WhatsApp、Discord 等）與 AI 進行互動，打造個人化的 24/7 AI 代理人。

值得注意的是，此專案在發展過程中曾使用 **MoltBot**、**ClawdBot** 等名稱，目前已正式更名為 **OpenClaw**。因此，在搜尋相關資訊或查閱文件時，可能會遇到這些不同的名稱，但它們指的是同一個專案。

---

## 二、核心概念：安全第一

在開始安裝之前，必須建立一個核心觀念：**安全永遠是第一優先**。第二部影片 [4] 明確指出，若使用者僅依照網路上的簡易教學進行安裝，極有可能在未察覺的情況下，將服務的控制介面、API 金鑰等極度敏感的資訊完全暴露在公網上。這形同將家門鑰匙直接掛在門外，任何人都可以輕易竊取您的 AI 模型額度，甚至入侵您的伺服器。

> **嚴重警告**：根據影片 [4] 的調查，全球已有數千台伺服器因不當安裝而處於此類危險狀態。因此，本指南將安全性相關的步驟放在最前面，強烈建議所有使用者務必遵循。

---

## 三、環境準備與基礎安全設定

### 1. 選擇安全的運行環境：VPS

**強烈建議**使用者將 OpenClaw 安裝在**虛擬專用伺服器（VPS）**上，而非個人電腦。主要原因如下：

-   **環境隔離**：VPS 提供一個與您個人電腦完全隔離的環境，避免潛在風險影響您的個人資料。
-   **24/7 運行**：確保您的 AI 助理隨時在線。
-   **網路安全**：避免將個人電腦直接暴露於公網風險中。

影片中推薦使用 **Hostinger** 等 VPS 服務商，並選擇 **Ubuntu 24.04 LTS** 作為作業系統。

### 2. 建立專用使用者

在 VPS 上，永遠不要使用 root 帳號直接操作。應建立一個專用的非 root 使用者來執行 OpenClaw，以限制權限並降低風險：

```bash
# 1. 以 root 身份登入 VPS 後，建立新使用者 (例如 openclaw)
adduser openclaw

# 2. 賦予該使用者 sudo 權限
usermod -aG sudo openclaw

# 3. (強烈建議) 設定 SSH 金鑰登入，以實現更安全的無密碼登入
# 在您的本地電腦上產生金鑰對 (若尚未有)
ssh-keygen -t ed25519

# 將公鑰複製到 VPS 上的新使用者
ssh-copy-id openclaw@<您的VPS_IP>
```

### 3. 伺服器層級安全強化

在安裝 OpenClaw 之前，應先完成伺服器的基礎安全防護。這些措施是保護任何網路服務的基礎。

| 安全措施 | 實作方式與指令 | 說明 |
| :--- | :--- | :--- |
| **鎖定 SSH 存取** | 修改 `/etc/ssh/sshd_config` 檔案，設定 `PasswordAuthentication no` 和 `PermitRootLogin no`，然後重啟 SSH 服務 `sudo systemctl restart sshd`。 | 僅允許使用更安全的 SSH 金鑰登入，並禁止權限過大的 root 帳號直接登入。 |
| **設定防火牆 (UFW)** | `sudo ufw default deny incoming`<br>`sudo ufw default allow outgoing`<br>`sudo ufw allow ssh`<br>`sudo ufw enable` | 使用 Ubuntu 內建的 Uncomplicated Firewall (UFW) 設定嚴格的防火牆規則，預設阻擋所有連入請求，僅開放必要的服務（如 SSH）。 |
| **防止暴力破解 (Fail2Ban)** | `sudo apt update && sudo apt install fail2ban`<br>`sudo systemctl enable --now fail2ban` | 自動監控登入日誌，在偵測到多次登入失敗後，自動封鎖攻擊者的 IP，有效防止密碼暴力破解攻擊。 |
| **建立私有網路 (Tailscale)** | 參考 Tailscale 官方文件進行安裝與設定。 | **(極度推薦)** 將 SSH 存取權限僅開放給您自己的私有網路，徹底避免將 SSH 服務暴露於公網，是目前最安全的遠端存取方式之一。 |

---

## 四、系統需求與安裝流程

完成基礎安全設定後，即可開始安裝 OpenClaw。

### 1. 系統需求

| 元件 | 要求 | 說明 |
| :--- | :--- | :--- |
| **作業系統** | macOS、Linux 或 Windows (WSL2) | Windows 使用者**強烈建議**使用 WSL2。 |
| **Node.js** | 版本 >= 22 | 這是執行 OpenClaw 的核心環境。 |

### 2. 安裝方式

最推薦的是使用官方提供的一鍵安裝腳本，它會自動處理所有相依套件。

**Linux / macOS / WSL2:**
```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

安裝完成後，腳本會自動進入下一步的引導設定精靈。

---

## 五、設定與引導精靈 (Onboarding Wizard)

安裝完成後，**強烈建議**執行官方的引導精靈，它將以互動式的方式引導您完成所有必要的初始設定。

```bash
openclaw onboard --install-daemon
```

`--install-daemon` 參數會將 OpenClaw 安裝為系統背景服務，使其在系統啟動時自動運行。

在引導過程中，您需要設定 **AI 模型供應商**、**通訊頻道**等。以 Telegram 為例，您需要先透過 Telegram 的 **@BotFather** 建立一個新的機器人，並將取得的 **API Token** 貼入引導精靈中。

---

## 六、啟動、驗證與連線

### 1. 啟動與驗證

如果您安裝了背景服務，Gateway 應該已經在運行。您可以使用以下指令進行驗證：

| 指令 | 說明 |
| :--- | :--- |
| `openclaw status` | 檢查整體狀態 |
| `openclaw health` | 檢查 Gateway 健康狀況 |
| `openclaw doctor` | 診斷常見問題 |
| `openclaw logs` | 查看日誌 |

### 2. 存取網頁儀表板 (Dashboard)

若要從遠端安全地存取在 VPS 上的儀表板，建議使用 SSH 通道：

```bash
ssh -N -L 18789:127.0.0.1:18789 <您的使用者名稱>@<您的VPS_IP>
```

執行後，即可在本地瀏覽器中開啟 `http://127.0.0.1:18789/` 來存取儀表板。

### 3. 通訊軟體配對

基於安全考量，當新使用者首次私訊您的機器人時，需要進行**配對核准**。您需要在伺服器上執行以下指令來核准：

```bash
# 列出待核准的配對請求 (以 Telegram 為例)
openclaw pairing list telegram

# 核准特定配對碼
openclaw pairing approve telegram <配對碼>
```

---

## 七、應用層級安全強化

除了伺服器層級的安全，OpenClaw 本身也提供多項安全設定。

| 安全措施 | 實作方式與指令 | 說明 |
| :--- | :--- | :--- |
| **鎖定使用者權限** | 在 OpenClaw 設定檔中，將使用權限鎖定給特定的使用者 ID（例如您自己的 Telegram ID）。 | 避免未經授權的使用者與您的 AI 助理互動或下達指令。 |
| **修正憑證權限** | `chmod 600 ~/.openclaw/credentials/*` | 修改儲存 API 金鑰等敏感資訊的憑證檔案權限，使其僅有檔案擁有者可以讀寫。 |
| **執行內建安全審核** | `openclaw security audit --deep` | **務必執行此指令**。它會掃描您的設定並找出潛在的安全漏洞，並提供修復建議。 |

---

## 八、擴充技能 (Skills) 與安全警告

OpenClaw 的強大之處在於其可擴充性。您可以透過 **ClawdHub** 社群網站瀏覽並安裝各種技能。然而，這也帶來了新的安全風險。

> **技能市集安全警告**：影片 [4] 特別提醒，由於任何人都可以上傳技能到 ClawdHub，其中可能存在含有後門程式的惡意技能。這些惡意技能可能會竊取您的 API 金鑰、個人資料或對您的系統造成損害。因此，強烈建議使用者在安裝任何社群技能前，務必從 GitHub 等可信賴的來源進行下載，並**自行審核其程式碼**，以確保安全。

---

## 九、疑難排解

-   **`openclaw` 指令找不到**：通常是 npm 的全域安裝路徑未加入系統的 `PATH` 環境變數。請將 `$(npm prefix -g)/bin` 加入您的 `~/.zshrc` 或 `~/.bashrc` 中。
-   **Telegram 機器人沒有回應**：請檢查 Gateway 是否運行 (`openclaw status`)、是否已完成配對 (`openclaw pairing list telegram`)、以及 Token 是否正確。

---

## 十、參考資料

[1] 李哈利Harry. (2026, January 28). *最簡單、最安全的 ClawdBot 安裝方式｜新手也能一次成功（完整教學）* [影片]. YouTube. https://www.youtube.com/watch?v=RrwHHQSb1FQ

[2] OpenClaw. (n.d.). *Install*. OpenClaw Docs. Retrieved February 2, 2026, from https://docs.openclaw.ai/install

[3] OpenClaw. (n.d.). *Getting Started*. OpenClaw Docs. Retrieved February 2, 2026, from https://docs.openclaw.ai/start/getting-started

[4] 李哈利Harry. (2026, January 31). *別再亂裝 ClawdBot 了｜我實測後最安全的安裝與使用方式* [影片]. YouTube. https://www.youtube.com/watch?v=zsCmcGWYvLU


---

## 十一、進階使用技巧：將 OpenClaw 效能提升 10 倍

第三部影片 [5] 提出了五個進階步驟，旨在將 OpenClaw 從一個被動的聊天機器人，轉變為主動、高效的智能工作夥伴，實現真正的 24/7 全天候 AI 員工。

### 1. 改善記憶體功能

根據影片 [5] 的建議，您可以透過修改設定檔來啟用兩個預設關閉的記憶體相關功能，大幅提升 AI 的上下文理解與記憶能力。您可以在與 OpenClaw 的對話中，直接發送以下指令來修改設定：

> **啟用記憶體增強提示詞範例：**
> ```
> Enable memory flush before compaction and session memory search in my OpenClaw config. Set `compaction.memoryFlush.enabled` to true and set `memorySearch.experimental.sessionMemory` to true with sources including both memory and sessions. Apply the config changes.
> ```

這段指令會讓 OpenClaw 自行修改設定檔，啟用「記憶體刷新」與「會話記憶體搜尋」功能。

### 2. 選擇合適的模型組合

將不同的 AI 模型視為一個團隊，各自發揮所長。影片 [5] 建議的組合如下：

-   **大腦 (主模型)**：使用最強大的模型，如 **Claude 3 Opus**，負責思考、決策與任務拆解。
-   **肌肉 (專用模型)**：整合其他在特定領域更具優勢的模型來執行具體任務，例如：
    -   **程式編碼**：使用 **Codex** 或 **Claude 3 Sonnet**。
    -   **網頁搜尋與研究**：使用 **Gemini**。

透過這種方式，可以更有效率且更經濟地完成複雜任務。

### 3. 腦力傾注與期望設定 (Brain Dump)

要讓 OpenClaw 成為您真正的 AI 員工，您需要像對待新進員工一樣，對其進行「入職培訓」。這個過程稱為「腦力傾注」，您可以將以下資訊整理成一份文件，並讓 OpenClaw 讀取與記憶：

-   **您的個人/公司目標**：短期、中期、長期目標是什麼？
-   **您的工作流程**：您通常如何完成一項任務？有哪些固定的步驟？
-   **您的溝通偏好**：您喜歡簡潔的報告還是詳細的分析？
-   **關鍵聯絡人與資源**：常用的網站、聯絡人資訊等。

完成腦力傾注後，您需要設定明確的期望，要求它**主動工作**，而非只是被動地等待指令。

### 4. 反向提問 (Reverse Prompting)

這是驅動 OpenClaw 主動性的關鍵技巧。不要總是直接下達指令，而是反過來問它，讓它思考如何更好地完成任務。這種方式能激發 AI 的「能動性 (Agency)」。

> **反向提問提示詞範例：**
> -   「根據你對我的目標的了解，你認為目前有哪些任務可以幫助我們更接近目標？」
> -   「為了提高我的工作效率，你還需要我提供哪些額外資訊？」

### 5. 讓 AI 自建工具

利用 OpenClaw 強大的程式編碼能力，讓它為自己打造客製化的生產力工具。這不僅能提升協作效率，也能讓 AI 更深度地融入您的工作流程。

> **自建工具提示詞範例：**
> 「請幫我建立一個簡單的任務看板網頁應用，讓我可以用來追蹤我們的專案進度。這個應用需要有『待辦』、『進行中』、『已完成』三個欄位。」

透過以上五個步驟，您可以將 OpenClaw 的潛力發揮到極致，使其成為您不可或缺的 AI 夥伴。

---

## 十二、參考資料

[1] 李哈利Harry. (2026, January 28). *最簡單、最安全的 ClawdBot 安裝方式｜新手也能一次成功（完整教學）* [影片]. YouTube. https://www.youtube.com/watch?v=RrwHHQSb1FQ

[2] OpenClaw. (n.d.). *Install*. OpenClaw Docs. Retrieved February 2, 2026, from https://docs.openclaw.ai/install

[3] OpenClaw. (n.d.). *Getting Started*. OpenClaw Docs. Retrieved February 2, 2026, from https://docs.openclaw.ai/start/getting-started

[4] 李哈利Harry. (2026, January 31). *別再亂裝 ClawdBot 了｜我實測後最安全的安裝與使用方式* [影片]. YouTube. https://www.youtube.com/watch?v=zsCmcGWYvLU

[5] Alex Finn. (2026, January 31). *How to make ClawdBot 10x better (5 easy steps)* [影片]. YouTube. https://www.youtube.com/watch?v=UTCi_q6iuCM
