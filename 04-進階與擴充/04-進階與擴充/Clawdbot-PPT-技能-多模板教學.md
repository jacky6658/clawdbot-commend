# 📘 Clawdbot 技能教學：安裝「多模板 AI 簡報產生器」模組（給已安裝好 Clawdbot 的用戶）

> 🎯 目標：讓你的 Bot 新增一個技能：  
> 使用者在 Telegram 輸入一句話 → Bot 在你的 Mac 上自動產生「有模板、有版型」的 PPT → 回傳給用戶。

> ❗ 本文件假設：你**已經安裝好 Clawdbot 並能正常運作**。本文件只教「如何新增一個做簡報的技能」。

---

# 🧱 一、最後會長這樣（先看成果）

使用者在 TG 輸入：
```
/ppt 模板=business 標題=公司簡介 內容=我們是AI公司。產品是自動化。願景是提升效率。
```

Bot 會回傳一個：
- 套用 **business.pptx** 模板
- 有字型 / 色彩 / 版型設計
- 檔名自動命名的 PPT

---

# 🗂 二、資料夾結構（照做）

在你的家目錄建立：

```
~/clawdbot-skills/ppt_generator/
 ├── generate_ppt.py
 └── templates/
      ├── business.pptx
      ├── pitchdeck.pptx
      └── course.pptx
```

---

# 🛠 三、Step 1：安裝必要套件（只做一次）

在終端機輸入：

```bash
pip3 install python-pptx
```

確認成功：

```bash
python3 -c "import pptx; print('ok')"
```

---

# 📁 四、Step 2：建立資料夾

```bash
mkdir -p ~/clawdbot-skills/ppt_generator/templates
cd ~/clawdbot-skills/ppt_generator
```

---

# 🎨 五、Step 3：準備模板（非常重要）

請你：

1. 用 PowerPoint 自己做三個檔案：
   - business.pptx（商務簡報風格）
   - pitchdeck.pptx（募資簡報風格）
   - course.pptx（教學簡報風格）

2. 設定好：
   - 字型
   - 顏色
   - 版型
   - 標題樣式
   - 內文樣式

3. 存到：

```
~/clawdbot-skills/ppt_generator/templates/
```

---

# 🧠 六、Step 4：建立產生簡報的腳本

建立檔案：

```bash
nano ~/clawdbot-skills/ppt_generator/generate_ppt.py
```

貼上 **完整可用腳本**：

```python
import sys
import os
import re
from datetime import datetime
from pptx import Presentation

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATE_DIR = os.path.join(BASE_DIR, "templates")
OUT_DIR = "/Users/user/.clawdbot/media/outbound"

def safe_filename(name: str) -> str:
    name = re.sub(r"[^\w\u4e00-\u9fff-]+", "_", name).strip("_")
    return name[:60] if name else "ppt"

if len(sys.argv) < 4:
    print("Usage: python3 generate_ppt.py <template> <title> <content>")
    sys.exit(1)

template_name = sys.argv[1]
title = sys.argv[2]
content = sys.argv[3]

template_path = os.path.join(TEMPLATE_DIR, f"{template_name}.pptx")
if not os.path.exists(template_path):
    print("Template not found:", template_path)
    sys.exit(1)

prs = Presentation(template_path)

# 封面頁
slide = prs.slides.add_slide(prs.slide_layouts[0])
slide.shapes.title.text = title

# 內容頁：用句號或換行切段
parts = content.replace("。", "\n").split("\n")

for i, p in enumerate(parts):
    p = p.strip()
    if not p:
        continue
    slide = prs.slides.add_slide(prs.slide_layouts[1])
    slide.shapes.title.text = f"第 {i+1} 頁"
    slide.placeholders[1].text = p

stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
fname = f"{safe_filename(title)}_{stamp}.pptx"
output_path = os.path.join(OUT_DIR, fname)

prs.save(output_path)
print("PPT generated at:", output_path)
```

存檔：
```
Ctrl + O → Enter → Ctrl + X
```

---

# 🧪 七、Step 5：本機先測試（非常重要）

```bash
python3 ~/clawdbot-skills/ppt_generator/generate_ppt.py business "公司簡介" "我們是AI公司。產品是自動化。願景是提升效率。"
```

然後：

```bash
ls /Users/user/.clawdbot/media/outbound
```

你應該會看到一個新 pptx 檔案。打開確認有套到你的模板樣式。

---

# 🤖 八、Step 6：讓 Clawdbot 使用這個技能

在 Telegram 對你的 Bot 說：

```
請執行：
python3 /Users/你的帳號/clawdbot-skills/ppt_generator/generate_ppt.py business "公司簡介" "我們是AI公司。產品是自動化。願景是提升效率。"
```

然後再說：

```
把 /Users/user/.clawdbot/media/outbound 裡最新的 pptx 傳給我
```

如果 Bot 能回傳檔案：
✅ 代表技能安裝完成

---

# 🪄 九、使用者指令格式（之後就用這個）

你之後只要規範用戶這樣輸入：

```
/ppt 模板=business 標題=公司簡介 內容=我們是AI公司。產品是自動化。願景是提升效率。
```

Bot 實際做的事就是：

```bash
python3 generate_ppt.py business "公司簡介" "我們是AI公司。產品是自動化。願景是提升效率。"
```

---

# 📦 十、你現在擁有的能力

- ✅ 多模板切換（business / pitchdeck / course）
- ✅ 所有設計由 PPT 模板控制（字型 / 色彩 / 版型）
- ✅ Bot 只負責填內容
- ✅ 產出的簡報是「專業設計版」，不是陽春版

---

# 🚀 十一、後續可擴充

- 接 GPT 自動生簡報大綱
- 每種模板固定頁型（封面 / 目錄 / 產品 / 結尾）
- 加 Logo / 公司資訊
- 商業化 SaaS

---

# ✅ 完成

> 你現在已經擁有：  
> 一個「可以賣錢的 AI 簡報產生技能模組」。

---

# ❗ 如果哪一步失敗

只檢查三件事：
1) 路徑對不對  
2) outbound 資料夾存在嗎  
3) python3 能不能跑  

---

# 🎯 你要我下一步幫你做什麼？

A. 幫你設計「business.pptx 專業模板結構」  
B. 幫你加「GPT 自動產生簡報大綱」  
C. 幫你封裝成「/ppt 指令」全自動流程  
