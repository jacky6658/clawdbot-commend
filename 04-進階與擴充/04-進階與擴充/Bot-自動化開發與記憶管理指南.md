# Clawdbot 自動化開發與記憶管理指南

如果你要讓 Bot 持續完成一長串開發任務（Milestone #1 ~ #N），請參考以下設定與 Prompt。

---

## 1. 建立計畫檔案：`PROJECT_PLAN.md`

在你的工作區建立此檔案，內容範例如下：

```markdown
# 專案開發計畫：[專案名稱]

## 目前狀態
- 當前進度：Milestone #1
- 記憶狀態：良好

## 任務清單
- [ ] Milestone #1: 基礎架構搭建
- [ ] Milestone #2: 資料庫與 API 設計
- [ ] Milestone #3: UI 介面實作
- [ ] Milestone #4: 整合測試與 Bug 修復
```

---

## 2. 驅動 Bot 的自動化 Prompt (直接貼給 Bot)

將以下這段話貼給你的 Telegram Bot，啟動「自動導航模式」：

> **「請讀取 `PROJECT_PLAN.md` 並進入『自動化開發模式』。你的規則如下：**
> 
> 1. **任務執行**：依照計畫檔中的勾選框 `[ ]` 順序執行任務。每完成一項，請立即在檔案中標記為 `[x]` 並存檔。
> 2. **自動延續**：完成一個小項後，除非遇到『無法自動修復的嚴重錯誤』，否則**不要停下來問我**，請直接進行下一個任務。
> 3. **記錄日誌**：請將詳細的執行過程與錯誤排除記錄在 `develop.log` 中。
> 4. **記憶管理 (重點)**：
>    - **主動壓縮**：每完成 3 個任務或感覺對話過長時，請主動呼叫 `compaction` 工具來壓縮歷史紀錄。
>    - **重啟重整**：如果遇到 `Context overflow` 錯誤，或者完成一個大里程碑（Milestone）時，請主動告訴我：『我已完成階段任務並更新計畫檔，請幫我**開一個新 Topic (新對話)**，我會在對話開始時重新讀取 `PROJECT_PLAN.md` 以清空大腦負擔。』
> 
> **現在請開始執行第一個未完成的任務。」**

---

## 3. 記憶管理機制說明

為了避免 Bot 因為對話太長而「頭痛」(Context Overflow)，你可以設定以下機制：

### A. 自動壓縮 (Compaction)
Clawdbot 設定檔 (`~/.clawdbot/clawdbot.json`) 中已有 `compaction` 設定。你可以確保它是開啟的：
- **建議設定**：`"mode": "aggressive"` 或 `"safeguard"`。
- **作用**：當對話太長時，Bot 會自動把前面的細節總結成一小段話，空出位置給新的任務。

### B. 階段性「換腦」(新對話)
當 Bot 完成一個 Milestone 後，最好的方式是：
1. **更新存檔**：讓 Bot 把所有關鍵邏輯寫入 `README.md` 或 `PROJECT_PLAN.md`。
2. **手動新開**：在 Telegram 點擊 **「New Topic」** (或相關重置指令)。
3. **讀取進度**：在新對話第一句說：『請讀取 `PROJECT_PLAN.md` 繼續任務。』
   - **效果**：Bot 會有一個乾淨的 128k/200k Context window，且因為讀了進度檔，它會知道「之前做完了什麼、現在該做什麼」，這比在舊對話裡苦撐更有效。

---

## 5. 進階自動化機制

除了手動下指令，你可以透過以下三種方式進一步強化 Bot 的自動化能力。

### A. 使用 Cron Job 定期執行 (定時檢查)
你可以設定 Bot 每隔一段時間自動檢查一次進度，避免任務中斷。
- **設定方式**：編輯 `~/.clawdbot/clawdbot.json` 中的 `cron` 區塊，或透過 Control UI 的 **Cron Jobs** 頁面。
- **範例設定**：
  ```json
  "cron": {
    "jobs": [
      {
        "id": "check-progress",
        "schedule": "0 * * * *", // 每小時執行一次
        "prompt": "請讀取 TASKS.md，如果還有未完成的任務，請繼續執行下一項。"
      }
    ]
  }
  ```
- **效果**：即使你沒在 Telegram 說話，Bot 每小時也會自動醒來處理一格任務。

### B. 利用 Agent 模式的「自治性」 (併發執行)
讓 Bot 具備同時處理多個子任務的能力。
- **調整設定**：在 `clawdbot.json` 確保併發限制足夠：
  ```json
  "agents": {
    "defaults": {
      "maxConcurrent": 4,   // 允許同時跑 4 個任務
      "subagents": {
        "maxConcurrent": 8  // 允許同時啟動 8 個子 Agent
      }
    }
  }
  ```
- **規則**：在 Prompt 中加入：「如果你發現任務可以拆分，請**主動啟動 subagent** 並行處理，不要等我授權。」

### C. 編寫「自定義技能 (Custom Skill)」腳本
如果你有一套固定的工作流程（例如：抓取網頁 ➔ 翻譯 ➔ 存成 PDF），可以寫成專用腳本。
- **做法**：在 `~/clawd/skills/` 建立一個 `.sh` 檔案（例如 `workflow.sh`）。
- **指令編寫**：
  ```bash
  #!/bin/bash
  # 讓 Bot 執行這個腳本來啟動連鎖反應
  agent-browser open $1
  agent-browser snapshot -i --json > snapshot.json
  # ... 更多邏輯
  ```
- **賦能**：在對話中跟 Bot 說：「我寫了一個 `workflow.sh` 技能放在 skills 資料夾，以後遇到 [某情境] 請直接執行它。」

---

## 6. 總結：全自動執行檢查清單 (Master Checklist)

- [ ] **計畫檔**：工作區有 `TASKS.md`。
- [ ] **記憶管理**：Prompt 已包含 `compaction` 與重啟提醒。
- [ ] **定時器**：已在 Control UI 設定 `cron` (選配)。
- [ ] **併發權限**：`maxConcurrent` 已設為 4 以上。
- [ ] **環境**：`agent-browser` 與 `remindctl` (若需要) 已安裝。
