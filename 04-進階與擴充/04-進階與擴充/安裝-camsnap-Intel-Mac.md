# 在 Intel Mac 上安裝 camsnap

steipete/tap 的 `brew install camsnap` 只提供 **arm64** 二進位（公式有 `depends_on arch: :arm64`），在 **Intel Mac (x86_64)** 會出現「未滿足的依賴項導致此建置失敗」。改為從原始碼編譯安裝。

## 前置需求

- **Go** 1.24+（你已有 `go 1.25.6`，若指令找不到可先執行 `brew link go`）
- **ffmpeg**（見下方；若 `brew install ffmpeg` 編譯失敗，可改裝 Command Line Tools 後重試，或改用 MacPorts／靜態包）

## 步驟（請在本機終端機執行）

若之前 `brew install` 出現「directories are not writable」，可先修正權限（需輸入本機密碼）：

```bash
sudo chown -R $(whoami) /usr/local/Homebrew /usr/local/Cellar /usr/local/bin /usr/local/lib /usr/local/opt /usr/local/share /usr/local/var/homebrew /Users/user/Library/Logs/Homebrew
```

然後：

```bash
# 1. 安裝依賴（若 Go 已裝可略過）
brew install ffmpeg
brew link go   # 若 go 已安裝但未連結

# 2. 克隆並編譯
cd /tmp
rm -rf camsnap
git clone https://github.com/steipete/camsnap.git
cd camsnap
go build -o camsnap ./cmd/camsnap

# 3. 安裝到 PATH（擇一）
# 選項 A：複製到 /usr/local/bin（需本機密碼）
sudo cp camsnap /usr/local/bin/

# 選項 B：複製到你家目錄的 bin（不需 sudo；請確認 ~/bin 在 PATH）
mkdir -p ~/bin
cp camsnap ~/bin/
# 若 ~/bin 不在 PATH，在 ~/.zshrc 加一行： export PATH="$HOME/bin:$PATH"
```

## 驗證

```bash
camsnap --version
```

若出現版本號即安裝成功。使用方式見：<https://github.com/steipete/camsnap>。

---

## 完成之後

**若要在 Clawdbot 裡用 camsnap（Control UI 裡「camsnap」技能／捆綁）：**

1. 重啟 daemon，讓它讀到新的 `camsnap` 執行檔：
   ```bash
   clawdbot daemon restart
   ```
2. 打開 Control UI（`http://127.0.0.1:18789/`），到 **Skills** 或相關頁面，找到 **camsnap**；若顯示「已屏蔽」或「缺少 bin:camsnap」，現在 `camsnap` 已在 `/usr/local/bin`，可試著**重新整理**或**啟用／解除屏蔽**，讓 bot 偵測到已安裝。

**若只在終端機用 camsnap：**

- 看說明：`camsnap --help`
- 從 RTSP/ONVIF 攝影機擷取畫面或片段，用法見：<https://github.com/steipete/camsnap>

---

## 若 `brew install ffmpeg` 失敗（macOS 13／編譯 libsvtav1 錯誤）

錯誤裡通常會提到：
- **macOS 13**：Homebrew 列為 Tier 3，較不保證編譯成功。
- **Command Line Tools 過舊**：建議更新後再試。

**建議順序：**

1. **先更新 Xcode Command Line Tools**（本機終端機執行，需輸入密碼）：
   ```bash
   sudo rm -rf /Library/Developer/CommandLineTools
   sudo xcode-select --install
   ```
   在跳出的視窗選「安裝」。若系統設定裡有「軟體更新」出現 Command Line Tools，也可從那裡更新。建議裝 **Command Line Tools for Xcode 15.2** 或更新版；若沒有出現可到 <https://developer.apple.com/download/all/> 手動下載。

2. **再試一次**：
   ```bash
   brew install ffmpeg
   ```

3. **若還是編譯失敗**，可改用 **MacPorts** 裝 ffmpeg。注意：`port` 是 MacPorts 的指令，**要先安裝 MacPorts** 才會有 `port`；若執行 `sudo port install ffmpeg` 出現 **`port: command not found`**，代表尚未安裝 MacPorts。請先到 <https://www.macports.org/install.php> 安裝 MacPorts，再執行 `sudo port install ffmpeg`。

4. **推薦：用 ffmpeg 靜態編譯包（免編譯、免 MacPorts）**：見下方「用 ffmpeg 靜態包（evermeet）」。

---

## 用 ffmpeg 靜態包（evermeet）—brew 與 MacPorts 都失敗時

**適用**：`brew install ffmpeg` 一直編譯失敗，且你**沒有**裝 MacPorts（所以 `port` 會 command not found）。用靜態包不需編譯、不需 MacPorts。

**步驟（本機終端機執行）：**

1. **下載 ffmpeg 靜態包**  
   瀏覽器打開 <https://evermeet.cx/ffmpeg/>，下載 **ffmpeg** 的 **.zip**（例如「Download ffmpeg」或「Release」的 zip）。

2. **解壓並放到 PATH**  
   下載後解壓會得到一個 `ffmpeg` 執行檔。在終端機執行（路徑請改成你實際下載的位置；若在「下載」資料夾且檔名為 `ffmpeg-xxx.zip`）：
   ```bash
   cd ~/Downloads
   unzip ffmpeg-*.zip
   chmod +x ffmpeg
   mkdir -p ~/bin
   mv ffmpeg ~/bin/
   ```
   若 `~/bin` 不在 PATH，在 `~/.zshrc` 加一行後重開終端機：
   ```bash
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
   ```

3. **驗證**：
   ```bash
   which ffmpeg
   ffmpeg -version
   ```
   有路徑、有版本即成功。

4. **接著編譯 camsnap**（Go 已 link、ffmpeg 已在 PATH）：
   ```bash
   cd /tmp
   rm -rf camsnap
   git clone https://github.com/steipete/camsnap.git
   cd camsnap
   go build -o camsnap ./cmd/camsnap
   sudo cp camsnap /usr/local/bin/   # 或 cp camsnap ~/bin/
   camsnap --version
   ```

---

## 若 `go` 找不到，或 `/usr/local/opt/go/bin/go` 不存在

Homebrew 顯示「Already linked」但執行 `go` 或 `/usr/local/opt/go/bin/go` 時出現 **no such file or directory**，代表 Go 的執行檔不在預期路徑（安裝不完整或損壞）。

**做法一：重新安裝 Go（本機終端機執行）**

```bash
brew unlink go
brew reinstall go
brew link go
which go
go version
```

若 `which go` 仍沒有路徑，在同一視窗執行 `source ~/.zshrc` 或重開終端機再試。

**做法二：改用官方 Go 安裝包**

1. 到 <https://go.dev/dl/> 下載 **macOS 適用的 .pkg**（例如 `go1.22.x.darwin-amd64.pkg`，Intel Mac 選 amd64）。
2. 執行 .pkg 安裝，預設會裝到 `/usr/local/go`，執行檔在 `/usr/local/go/bin/go`。
3. 把 Go 的 bin 加到 PATH：在 `~/.zshrc` 加一行  
   `export PATH="/usr/local/go/bin:$PATH"`  
   然後執行 `source ~/.zshrc` 或重開終端機。
4. 驗證：`which go`、`go version`。  
5. 再回到 `/tmp/camsnap` 執行：`go build -o camsnap ./cmd/camsnap`。
