<div align=center>
<img src="icon.png" style="width:100px;" width="100"/>
<h2>PonyDownloader</h2>
</div>

[English](/README.md) | [简体中文](/README_zh-CN.md) | [繁體中文](/README_zh-TW.md) | [日本語](/README_ja-JP.md) | [Tiếng Việt](/README_vi-VN.md)

### 一、功能簡述
- 一款使用 Go 與 Flutter 打造的高速、現代、免費開源下載器，支援 HTTP、HTTPS、BitTorrent、磁力連結與 ed2k 等協定。
- 覆蓋 Windows、macOS、Linux、Android、iOS 與 Web 平台，提供原生桌面端、行動端以及可自行架設的 Web 管理介面。
- 支援多任務並行、HTTP 多連線分段傳輸、BT DHT 節點發現、uTP 傳輸、Web Seed、按檔案選擇下載、Tracker 管理與做種限制。
- 提供 REST API、命令列工具、JavaScript 擴充套件、瀏覽器接管、Webhook 與 MCP 介面，可自由擴充並讓 AI Agent 以自然語言管理下載。
- 支援跟隨系統、淺色與深色主題，多種強調色與 20+ 種介面語言。

### 二、部署方式
1. 桌面端與行動端：從 [GitHub Releases](https://github.com/Mutantcat-Working-Group/PonyDownloader/releases) 下載對應平台安裝包，安裝後即可使用。
2. 自行架設 Web 服務：啟動發佈包中的 Web 程式，預設監聽 `0.0.0.0:9999`，瀏覽器開啟 `http://localhost:9999` 即可進入管理介面。
   ```
   可選啟動參數：
   -A 綁定位址（預設 0.0.0.0）
   -P 綁定埠號（預設 9999）
   -u Web 登入使用者名稱
   -p Web 登入密碼（未設定則不啟用 Web 認證）
   -T API Token（啟用 Web 認證後呼叫 HTTP API 時必填）
   -d 儲存目錄
   ```
3. Docker 部署：倉庫根目錄提供 `docker-compose.yml`，對映 9999 埠號並掛載下載目錄，執行 `docker compose up -d` 即可。
4. 開發者自行編譯：需要 Go 1.25+ 與 Flutter 3.41+，後端使用 `go build`，前端使用 `flutter build`。

### 三、使用教學
1. 桌面端/行動端：開啟應用程式，點選新增任務，貼上 HTTP/HTTPS 連結、磁力連結或種子檔，選擇儲存目錄後開始下載。
2. Web 管理介面：開啟 `http://localhost:9999`，可以建立任務、查看進度、管理分類與設定；設定帳號密碼後需登入使用。
3. 批次與續傳：支援暫停、繼續、重試、批次操作、依狀態篩選與分類管理，程式重新啟動後會自動恢復未完成任務。
4. 瀏覽器接管：安裝相容的瀏覽器擴充套件後，可將網頁下載請求直接送到 PonyDownloader。
5. AI 接入：啟用 MCP（`--mcp-enable`）後，AI Agent 可透過 `http://localhost:9999/mcp` 建立、查詢與管理下載任務。

### 四、API 文件
1. 取得服務資訊 - `GET /api/v1/info`
   ```
   回傳版本、執行環境、系統架構等基礎資訊。
   ```
2. 解析下載資源 - `POST /api/v1/resolve`
   - 請求範例：
   ```json
   {
       "req": {
           "url": "https://example.com/file.zip"
       }
   }
   ```
   - 回傳資源中繼資料與檔案清單，建立任務前可先解析。
3. 建立下載任務 - `POST /api/v1/tasks`
   - 請求範例：
   ```json
   {
       "req": {
           "url": "https://example.com/file.zip",
           "extra": {
               "connections": 16
           }
       },
       "opts": {
           "path": "/downloads"
       }
   }
   ```
   - 也可使用解析得到的資源 ID 作為 `rid`。
4. 查詢任務 - `GET /api/v1/tasks`
   - 支援依任務 ID 或狀態篩選，例如 `GET /api/v1/tasks?status=running`。
5. 暫停與繼續 - `PUT /api/v1/tasks/{id}/pause`、`PUT /api/v1/tasks/{id}/continue`
6. 刪除任務 - `DELETE /api/v1/tasks/{id}`，可加 `?force=true` 同時刪除檔案。
7. MCP 介面 - `POST /mcp`
   - 啟用 MCP 後可接入 AI Agent，以自然語言管理下載任務。

### 五、專注的重點
- 充分利用頻寬：多任務並行、HTTP 多連線分段下載與 BitTorrent P2P 下載相結合。
- 一個入口管理多種協定：HTTP/HTTPS、BitTorrent、磁力連結、ed2k 統一在一個介面中處理。
- 原生跨平台體驗：使用 Flutter 原生渲染，非 Electron 套殼，安裝包更輕、佔用更低、回應更快。
- 開放的自動化能力：REST API、CLI、Webhook、下載後指令碼、JavaScript 擴充套件與 MCP 皆可用於自動化。
- 輕量自行架設：單一 Web 程式即可部署，適合放在伺服器或 NAS 上長期執行。

### 六、開發進度
- [X] HTTP/HTTPS 多連線下載
- [X] BitTorrent / 磁力連結
- [X] ed2k 下載
- [X] 任務管理（暫停、繼續、重試、批次、篩選、分類）
- [X] 斷點續傳與啟動恢復
- [X] Web 管理介面與帳號認證
- [X] REST API 與 API Token
- [X] MCP / AI Agent 接入
- [X] 瀏覽器接管
- [X] JavaScript 擴充套件
- [X] Docker 部署
- [ ] 正式版本發佈與自動化測試完善
