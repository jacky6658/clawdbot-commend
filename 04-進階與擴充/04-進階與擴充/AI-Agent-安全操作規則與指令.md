
# 🤖 AI Agent 安全操作電腦規則（含指令說明版）

> 本文件用於規範 AI Agent / Bot 在本機或伺服器上執行終端機（Terminal）與檔案操作時的 **安全邏輯、允許範圍、禁止行為與防呆流程**。  
> 同時，本文件也 **明確定義每一個允許指令的用途與使用情境**，避免 AI 誤用指令。

適用於：Clawdbot、Moltbot、自製 Agent、n8n + Shell、Cursor Agent 等。

---

## 🎯 目標

- 防止 AI 誤刪系統或重要資料
- 防止 AI 在錯誤路徑執行危險指令
- 確保所有操作 **可預期、可回溯、可審計**
- 所有破壞性行為必須先確認
- 明確告訴 AI：「每個指令是幹嘛用的」

---

## 🧱 一、操作沙盒原則（Sandbox Rule）

### ✅ 1. 僅允許在以下目錄操作

> 所有讀寫、刪除、建立檔案 **只能發生在白名單資料夾內**

範例：

```
/Users/xxx/AI_WORKSPACE
/Users/xxx/Downloads
```

### ❌ 2. 嚴禁操作以下路徑

```
/
/System
/usr
/bin
/sbin
/etc
/Applications
/Library
~/Desktop
~/Documents   （除非明確允許）
```

---

## 🛂 二、允許指令白名單（含用途說明）

> AI 只能使用以下指令，且必須依照用途使用，不得混用、不當使用。

---

### 📍 pwd — 顯示目前所在目錄

用途：
- 確認目前工作路徑
- 任何高風險操作前必須先執行

```bash
pwd
```

---

### 📂 ls — 列出資料夾內容

用途：
- 查看目前或指定資料夾內有什麼檔案
- 刪除 / 移動 / 覆蓋前必須先執行

```bash
ls
ls ~/AI_WORKSPACE
```

---

### 📁 cd — 切換工作目錄

用途：
- 進入指定資料夾後再操作檔案

```bash
cd ~/AI_WORKSPACE
```

規則：
- 禁止 cd /
- 禁止 cd .. 連續跳出沙盒

---

### 🪟 open — 用系統預設程式開啟檔案或資料夾

用途：
- 開啟檔案給人類查看
- 打開資料夾

```bash
open report.pdf
open .
```

---

### 📄 cat — 顯示文字檔內容

用途：
- 讀取小型文字檔內容
- 僅限文字檔

```bash
cat config.txt
```

---

### 📖 less — 分頁檢視大型文字檔

用途：
- 檢視 log 或大型文件
- 不會修改檔案

```bash
less big.log
```

---

### ✏️ nano — 編輯文字檔

用途：
- 編輯設定檔 / 腳本 / md 文件

```bash
nano file.txt
```

---

### 📄 touch — 建立空檔案

用途：
- 建立新檔案佔位

```bash
touch new.md
```

---

### 📁 mkdir — 建立資料夾

用途：
- 建立新工作目錄

```bash
mkdir new_folder
```

---

### 📦 cp — 複製檔案或資料夾

用途：
- 複製檔案
- 備份檔案

```bash
cp a.txt b.txt
cp -r src backup
```

規則：
- 若目標存在 → 必須先詢問

---

### 🚚 mv — 移動或重新命名檔案

用途：
- 移動檔案
- 改檔名

```bash
mv a.txt ~/AI_WORKSPACE/a.txt
```

風險：
- 可能覆蓋檔案 → 必須先檢查

---

### 🔍 find — 搜尋檔案

用途：
- 在指定目錄內找檔案

```bash
find . -name "*.md"
```

---

## ⚠️ 三、高風險指令（需多重檢查）

### 🗑 rm — 刪除檔案或資料夾（不可復原）

用途：
- 刪除明確指定的檔案

```bash
rm file.txt
rm -r folder
rm -rf folder
```

嚴格規則：

1. 必須先執行：
```
pwd
ls
```
2. 必須確認：
- 路徑在白名單內
- 路徑不是： / 或 ~ 或 .. 或 *
3. 不得刪除：
- 不確定用途的檔案
- 系統檔案
4. 若不確定 → 停止並詢問人類

---

## ❌ 四、永久禁止指令（無條件禁止）

> AI **不得在任何情況下** 使用以下指令

```
sudo
chmod
chown
dd
mkfs
kill
killall
reboot
shutdown
rm -rf /
rm -rf ~
```

---

## 🚨 五、路徑安全規則

### ❌ 禁止使用以下路徑作為操作目標

```
/
~
..
../..
*
```

### ✅ 所有操作必須使用：

```
/Users/xxx/AI_WORKSPACE/明確檔名
```

或

```
~/AI_WORKSPACE/明確檔名
```

---

## 🧠 六、AI 決策原則

1. ❌ 永遠不可假設路徑是正確的
2. ❌ 永遠不可自行猜測使用者意圖
3. ✅ 所有破壞性操作必須基於明確指令
4. ✅ 路徑不存在 → 停止
5. ✅ 有風險 → 詢問人類

---

## 🔒 七、工程實作建議

- Shell 指令過濾器（Allowlist）
- 路徑必須通過白名單檢查
- rm 指令必須記錄 log
- 可加入 dry-run 模式

---

## 🏁 八、最高原則

> 寧可 AI 什麼都不做，也不能做錯一次。

---

## 📌 建議檔名

```
AI_AGENT_SAFETY_RULES_WITH_COMMANDS.md
```

---
