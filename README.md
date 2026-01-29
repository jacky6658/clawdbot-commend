# Cawdbot Skills Extension Guide

## 簡介
歡迎！本指南說明如何根據下載的教學，為您的 Cawdbot 實例擴充新技能。在安裝 Cawdbot 後，您可以遵循教學來整合新的功能，並提升您的 AI Agent 的能力。

## 如何新增技能

Cawdbot 的彈性來自於其模組化的技能系統。您可以透過新增新的技能或腳本來擴展其功能。

**關鍵步驟：**

1.  **取得技能腳本：**
    *   下載必要的技能腳本或程式。這些可能是 Python 腳本、Shell 腳本或其他可執行檔。
    *   確保您已安裝這些技能所需的依賴項（例如，透過 `pip` 安裝 Python 函式庫，或透過 `brew` 安裝其他 CLI 工具）。請參考特定技能的說明文件以獲取安裝指示。

2.  **將技能放置於指定目錄：**
    *   所有自訂技能和供 Cawdbot 使用的腳本，都應放置在 `~/clawd/skills/` 這個目錄下。
    *   您可以在 `~/clawd/skills/` 中建立子目錄來邏輯地組織您的技能（例如，針對 Cursor 相關的腳本，可以放在 `~/clawd/skills/auto_cursor/`）。

3.  **確保執行權限（如適用）：**
    *   對於 Shell 腳本 (`.sh`) 或 Python 腳本 (`.py`)，如果您打算直接執行它們，請確保它們具備執行權限。您可以在終端機中執行以下命令來賦予權限：
        ```bash
        chmod +x ~/clawd/skills/your_skill_script.sh
        # 或 Python 腳本
        # chmod +x ~/clawd/skills/your_python_script.py
        ```
    *   請將 `your_skill_script.sh` 或 `your_python_script.py` 替換為您的實際技能檔案名稱。

4.  **與 Cawdbot 互動：**
    *   一旦技能已放置並具備正確權限，您就可以指示 Cawdbot 使用它們。
    *   例如，如果您有一個名為 `~/clawd/skills/my_new_skill.py` 的腳本，您可以告訴 Cawdbot 執行它。
    *   Cawdbot 也可以利用具有特定命令的技能，就像我們之前看到的 `~/clawd/skills/solar-weather/solar-weather.py` 或 `~/clawd/skills/auto_cursor/auto_cursor.sh` 一樣。

## 使用範例

*   **執行 Shell 腳本：**
    ```bash
    ~/clawd/skills/auto_cursor/auto_cursor.sh "您的提示詞"
    ```
*   **列出可用的技能：**
    ```bash
    ls ~/clawd/skills
    ```

## 貢獻
如果您開發了新的技能或改進，歡迎透過提交 Pull Request 的方式貢獻。如果有的話，請遵循貢獻指南。

---
