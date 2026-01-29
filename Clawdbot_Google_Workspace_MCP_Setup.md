# Clawdbot + Google Workspace MCP 安裝與設定教學

> 目標：讓 Clawdbot 可以用自然語言操作  
> Gmail / Google Calendar / Google Drive / Google Docs / Google Sheets

---

## 🧱 架構說明

Clawdbot  
→ mcpporter（MCP 管理器）  
→ google-workspace-mcp（工具伺服器）  
→ Google APIs

---

## ✅ 前置條件

請先確認已安裝：

- Node.js
- npm
- Clawdbot

---

## ✅ Step 1：安裝 Google Workspace MCP

```bash
npm install -g @presto-ai/google-workspace-mcp
```

---

## ✅ Step 2：第一次啟動並完成 Google OAuth 登入

```bash
npx @presto-ai/google-workspace-mcp
```

1. 會自動打開瀏覽器
2. 登入 Google 帳號
3. 點擊允許
4. 看到「Authentication successful」即完成

完成後可關閉該視窗。

---

## ✅ Step 3：進入 Clawdbot 設定

```bash
clawdbot configure
```

---

## ✅ Step 4：在 Clawdbot 內安裝 mcpporter

在設定流程中：

1. 選擇：Skills  
2. 勾選：Install missing skill dependencies  
3. 勾選：mcpporter  
4. 安裝完成

---

## ✅ Step 5：註冊 Google Workspace MCP

在終端機執行：

```bash
mcpporter config add google-workspace \
  --command "npx" \
  --arg "-y" \
  --arg "@presto-ai/google-workspace-mcp" \
  --scope home
```

---

## ✅ Step 6：啟動 Clawdbot

```bash
clawdbot
```

---

## ✅ Step 7：測試

在 Clawdbot 輸入：

- 幫我查 Gmail 未讀信
- 幫我新增明天下午三點行事曆

---

## 🧪 檢查 MCP 是否存在

```bash
cat ~/.mcpporter/mcpporter.json
```

---

## ⚠️ 注意

- 不要長期手動執行 npx @presto-ai/google-workspace-mcp
- 應由 Clawdbot 自動呼叫

---

## 🎉 完成

你的 Clawdbot 已正式連接 Google Workspace！
