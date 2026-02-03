# OpenClaw (ClawdBot) 防護與安裝健檢報告（2026-02-02）

依據《OpenClaw (原 ClawdBot) 全方位實作與安全指南》對本機現況所做的對照檢查。  
本機為 **macOS**，路徑為 **~/.clawdbot**（ClawdBot 使用此目錄，等同指南中的 ~/.openclaw）。

---

## 一、環境與安裝狀況

| 指南項目 | 本機狀態 | 說明 |
|----------|----------|------|
| **作業系統** | ✓ macOS 15.7.3 (x64) | 符合「macOS / Linux / WSL2」 |
| **Node.js ≥ 22** | ✓ v24.13.0 | 符合需求 |
| **安裝方式** | ✓ 已安裝 (clawdbot 2026.1.24-3) | 使用 npm 安裝 ClawdBot |
| **Gateway 埠** | ✓ 18789，bind=loopback | 僅本機可連，未對外暴露 |
| **Gateway 狀態** | ✓ reachable | 目前正常連線 |
| **Memory** | ✓ 10 files · 20 chunks · vector ready | 記憶功能正常 |

---

## 二、應用層級防護（對應指南「七、應用層級安全強化」）

| 安全措施 | 指南建議 | 本機狀態 | 備註 |
|----------|----------|----------|------|
| **鎖定 DM 權限** | 將使用權限鎖定給特定使用者 ID | ✓ 已做 | `channels.telegram.dmPolicy: "pairing"`（陌生人須配對核准）；`allowFrom` 含特定 ID 與 `"*"`（配對後允許）。若只要「僅允許名單內」可改為 `dmPolicy: "allowlist"` 並從 `allowFrom` 移除 `"*"`。 |
| **DM 會話隔離** | 避免多使用者共用同一 session | ✓ 已做 | `session.dmScope: "per-channel-peer"`，每個 Telegram 使用者獨立 session。 |
| **憑證目錄權限** | chmod 600 憑證檔／僅擁有者可讀 | ✓ 已做 | `~/.clawdbot/credentials` 為 `700`（僅本人可進）；目錄內目前無檔案。若有新增憑證檔，建議設為 `chmod 600`。 |
| **安全審核** | 執行 security audit | ✓ 已做 | 已執行 `clawdbot security audit`，見下方「安全審核結果」。 |

---

## 三、安全審核結果（clawdbot security audit）

- **Critical：0**（無嚴重問題）
- **Warn：3**
  - **Reverse proxy headers not trusted**：未設定 `gateway.trustedProxies`。你目前 **bind=loopback**，Control UI 僅本機存取，可不設定；若未來改為經由 reverse proxy 對外，再依指南設定 trusted proxies。
  - **Control UI allows insecure HTTP auth**：`gateway.controlUi.allowInsecureAuth: true`，允許 token 透過 HTTP。因 **僅 listen 127.0.0.1**，實際僅本機使用，風險可接受；若改為對外或 HTTPS，建議關閉或改為 HTTPS。
  - **Some models below recommended tiers**：部分 fallbacks 為較小／舊模型（如 gpt-4o、gpt-4o-mini、claude-haiku）。若希望更抗 prompt 注入，可優先使用較新／大模型。
- **Info：1**
  - Attack surface 摘要：groups allowlist、elevated/browser 等狀態，供參考。

**建議**：本機目前 **0 critical**，其餘為可選優化；若要更完整掃描可執行 `clawdbot security audit --deep`。

---

## 四、指南中「本機不適用」或「已由現況涵蓋」的項目

| 指南章節 | 說明 |
|----------|------|
| **三、VPS 與伺服器層級** | 指南建議在 VPS 上跑、SSH 金鑰、UFW、Fail2Ban、Tailscale。你是在 **本機 Mac** 跑，未對外開埠，故 **gateway 只聽 loopback** 即等同「不對公網暴露」；若未來改到 VPS，再依指南做 SSH／防火牆／Tailscale。 |
| **存取 Dashboard** | 指南建議用 SSH tunnel 連到 VPS 上的 18789。你本機直接開 `http://127.0.0.1:18789/` 即可，無需 tunnel。 |
| **配對 (pairing)** | 已啟用 `dmPolicy: "pairing"`，新使用者須經 `clawdbot pairing list telegram` / `clawdbot pairing approve telegram <code>` 核准，與指南一致。 |

---

## 五、可選加強（若要比照指南更嚴格）

1. **allowFrom 更嚴格**  
   若希望「僅允許特定 Telegram 使用者」、不依賴配對後 `*`：  
   - 設 `dmPolicy: "allowlist"`  
   - `allowFrom` 只保留允許的 Telegram user ID（數字），**移除 `"*"`**  

2. **Control UI 僅本機**  
   維持 `gateway.bind: "loopback"`，不把 18789 暴露到 0.0.0.0，即符合「Control UI 僅本機」建議。  

3. **憑證檔權限**  
   日後若在 `~/.clawdbot/credentials/` 下新增檔案，建議執行：  
   `chmod 600 ~/.clawdbot/credentials/*`  

4. **技能 (Skills) 安全**  
   指南提醒：從 ClawdHub 安裝技能前，從可信來源下載並**自行審核程式碼**。本機未做額外掃描，僅提醒安裝前留意來源與內容。  

---

## 六、健檢總結

| 類別 | 結果 |
|------|------|
| **安裝與環境** | ✓ Node、Gateway、Memory 正常，埠僅 loopback |
| **應用層防護** | ✓ DM 配對、session 隔離、credentials 目錄權限、已跑過 security audit |
| **安全審核** | ✓ 0 critical；3 warn 屬本機可接受或可選優化 |
| **與指南差異** | 本機為 Mac、未用 VPS；其餘應用層建議多已落實或可選加強 |

**結論**：本機已具備指南中「應用層級」的相關防護（DM 鎖定／配對、session 隔離、憑證目錄權限、安全審核）；Gateway 僅 listen loopback，未對外暴露。若未來改為 VPS 或對外提供服務，再依指南補做「三、伺服器層級」與 reverse proxy / HTTPS 設定即可。

---

*報告產出時間：2026-02-02*
