# Clawdbot / OpenClaw 常見日誌錯誤與處理參考

本文件整理**常見日誌錯誤類型與建議處理方式**，供學員排查時參考。實際日誌檔位置為 `~/.clawdbot/logs/`（OpenClaw 為 `~/.openclaw/logs/`）。  
若您使用 OpenClaw，請將下列指令中的 `clawdbot` 改為 `openclaw`。

---

## 錯誤類型與處理狀態參考

| 錯誤類型 | 常見原因 | 建議處理 |
|----------|----------|----------|
| AbortError / 操作被中止 | 網路中斷、請求逾時 | 多為暫時性，程序通常會繼續運行；若頻繁出現可檢查網路、VPN、防火牆或 API 狀態 |
| fetch failed | 網路連線失敗、API 不可達 | 同上，屬暫時性網路問題；確認 API 金鑰與服務狀態 |
| PDF：Unicode / emoji 錯誤 | LaTeX 不支援該字元 | 可從內容移除 emoji，或將 PDF 引擎改為 xelatex（支援 Unicode） |
| PDF：中文等 Unicode 字元錯誤 | 未安裝 TeX CJK 語言套件 | 安裝後即可支援中文：`sudo tlmgr install collection-langcjk` |
| sudo 需要密碼 | 在無 TTY 環境執行 sudo | 需在**本機終端機**手動執行需 sudo 的指令，無法由 Bot 自動輸入密碼 |

---

## 1. AbortError / fetch failed（網路相關）

**日誌範例**：
```
Unhandled promise rejection: AbortError: This operation was aborted
Unhandled promise rejection: TypeError: fetch failed
```

**說明**：多為暫時性網路或 API 問題。若運行環境已將這類錯誤視為 transient（不觸發 process.exit），程序會繼續運行。

**建議**：若仍常出現，可檢查網路、VPN、防火牆或各 API 服務狀態；必要時重啟 gateway。

---

## 2. PDF 生成：Unicode / emoji 錯誤

**日誌範例**：
```
LaTeX Error: Unicode character 📘 (U+1F4D8) not set up for use with LaTeX.
```

**建議**：
- 從產生 PDF 的來源內容中移除 emoji，或
- 將 PDF 產生流程改為使用 **xelatex**（支援 Unicode），避免 pdflatex 不支援之字元。

---

## 3. PDF 生成：中文等 Unicode 字元錯誤

**日誌範例**：
```
LaTeX Error: Unicode character 常 (U+5E38) not set up for use with LaTeX.
```

**建議**：
- 使用 **xelatex** 作為 PDF 引擎（可處理 Unicode/中文）。
- 安裝 TeX CJK 語言套件（需在本機終端機執行）：
  ```bash
  sudo tlmgr install collection-langcjk
  ```
  安裝完成後再試一次 PDF 生成。

---

## 4. sudo 需要密碼

**日誌範例**：
```
sudo: a terminal is required to read the password
sudo: a password is required
Command exited with code 1
```

**說明**：在無 TTY 的環境（例如由 daemon 或 Bot 觸發的指令）無法互動輸入 sudo 密碼。

**建議**：所有需要 `sudo` 的指令（例如 `tlmgr install`）應**由使用者在終端機手動執行**，完成後再透過 Bot 進行 PDF 生成等操作。

---

## 總結對照

| 項目 | 建議處理 |
|------|----------|
| AbortError / fetch failed | 多為暫時性；檢查網路與 API，必要時重啟 |
| PDF emoji / Unicode 錯誤 | 移除 emoji 或改用 xelatex |
| PDF 中文錯誤 | 使用 xelatex + `sudo tlmgr install collection-langcjk` |
| sudo 在 Bot/daemon 內執行 | 改為在本機終端機手動執行 |

---

## 建議下一步（依情況選用）

1. **若需 PDF 中文支援**，在終端機執行（僅需做一次）：
   ```bash
   sudo tlmgr install collection-langcjk
   ```

2. **若日誌仍常出現 AbortError / fetch failed**：屬網路或 API 暫時問題，程序多會繼續運行；可檢查 API 金鑰、服務狀態與網路環境。

3. **查看即時日誌**：
   ```bash
   clawdbot logs --follow
   ```
   或直接查看 `~/.clawdbot/logs/gateway.err.log`、`gateway.log`。
