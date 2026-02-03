# 安裝 remindctl（蘋果提醒事項 CLI）

**remindctl** 是在 macOS 上用命令列管理 **Apple 提醒事項**的 CLI：列出、新增、編輯、完成、刪除，支援清單、日期篩選與 JSON／純文字輸出。Clawdbot 若啟用「蘋果提醒事項」技能會用到 `remindctl`。

## 為什麼「透過 Homebrew 安裝」會失敗？

錯誤訊息：**「未滿足的依賴項導致此建置失敗」**

steipete/tap 的 **remindctl 公式** 有這行：

```ruby
depends_on macos: :sonoma
```

也就是說，**只支援 macOS 14 (Sonoma) 或更新**。若你目前是 **macOS 13** 或更舊，Homebrew 會判定依賴不滿足，無法安裝。

---

## 若你是 macOS 14 (Sonoma) 或更新

**安裝：**

```bash
brew install steipete/tap/remindctl
```

**第一次使用前要授權提醒事項：**

1. 在終端機執行：`remindctl authorize`
2. 跳出系統提示時，選「允許」。
3. 若沒跳出，到 **系統設定 → 隱私權與安全性 → 提醒事項**，把 **終端機**（或執行 remindctl 的 app）加入並允許。

**驗證：**

```bash
remindctl --version
remindctl status
remindctl          # 顯示今天的提醒
```

**常用指令（節錄）：**

```bash
remindctl today              # 今天
remindctl tomorrow           # 明天
remindctl list               # 清單
remindctl add "買牛奶"       # 新增
remindctl complete 1 2 3     # 標為完成
remindctl --json             # JSON 輸出
```

完整用法見：<https://github.com/steipete/remindctl>。

---

## 若你是 macOS 13 或更舊

**公式與官方二進位都要求 macOS 14+**，在 macOS 13 上 **無法** 用 `brew install steipete/tap/remindctl` 安裝預編譯版。

可選做法：

1. **升級到 macOS 14 (Sonoma) 或更新**  
   升級後再執行 `brew install steipete/tap/remindctl`。

2. **從原始碼試建（不保證可行）**  
   專案需求寫的是 macOS 14+、Swift 6.2+，若在 macOS 13 上編譯，可能仍會缺 API 或執行錯誤。僅供進階嘗試：
   ```bash
   git clone https://github.com/steipete/remindctl.git
   cd remindctl
   pnpm install
   pnpm build
   # 二進位在 ./bin/remindctl，可 cp 到 /usr/local/bin 或 ~/bin
   ```
   需已安裝 Node.js 與 pnpm（`npm install -g pnpm`）。

3. **改用其他 Apple 提醒事項 CLI**  
   例如：
   - **rmind**：<https://github.com/caroso1222/rmind>
   - **x mac re**（x-cmd）：<https://x-cmd.com/mod/mac/re>

---

## 安裝完成後與 Clawdbot 一起用

1. 確認終端機可執行：`remindctl --version`
2. 重啟 Clawdbot daemon，讓它偵測到 `remindctl`：
   ```bash
   clawdbot daemon restart
   ```
3. 打開 Control UI → **Skills**，找到「蘋果提醒事項」／remindctl；若原本顯示「缺失: bin:remindctl」，重新整理或啟用後應會偵測到已安裝。

---

## 快速對照

| 狀況 | 做法 |
|------|------|
| **macOS 14+** | `brew install steipete/tap/remindctl`，再 `remindctl authorize` |
| **macOS 13** | 公式不支援；可升級到 14 或試從原始碼建、或改用 rmind / x mac re |
| **Clawdbot 仍顯示缺失** | 確認 `which remindctl` 有路徑，執行 `clawdbot daemon restart`，再在 Control UI 重新整理／啟用技能 |
