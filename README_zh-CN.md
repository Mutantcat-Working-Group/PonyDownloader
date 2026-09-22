<div align=center>
<img src="icon.png" style="width:100px;" width="100"/>
<h2>PonyDownloader</h2>
</div>

[English](/README.md) | [简体中文](/README_zh-CN.md)

### 一、功能简述
- 一款使用 Go 与 Flutter 构建的高速、现代、免费开源下载器，支持 HTTP、HTTPS、BitTorrent、磁力链接与 ed2k 等协议。
- 覆盖 Windows、macOS、Linux、Android、iOS 与 Web 平台，提供原生桌面端、移动端以及可自托管的 Web 管理界面。
- 支持多任务并发、HTTP 多连接分段传输、BT DHT 节点发现、uTP 传输、Web Seed、按文件选择下载、Tracker 管理与做种限制。
- 提供 REST API、命令行工具、JavaScript 扩展、浏览器接管、Webhook 与 MCP 接口，可自由扩展并接入 AI Agent 实现自然语言管理下载。
- 支持跟随系统、浅色与深色主题，多种强调色与 20+ 种界面语言。
- 宿主机关闭屏幕或进入休眠后，看门狗会自动恢复被中断的下载任务，屏幕熄灭与挂起唤醒不会破坏正在进行的任务。

### 二、部署方式
1. 桌面端与移动端：从 [GitHub Releases](https://github.com/Mutantcat-Working-Group/PonyDownloader/releases) 下载对应平台安装包，安装后即可使用。Windows 提供 NSIS 安装包（x64），macOS 提供 ad-hoc 签名的通用 DMG（同时支持 Intel 与 Apple Silicon），Linux 提供 x64 与 arm64 的 AppImage。
2. 自托管 Web 服务：启动发布包中的 Web 程序，默认监听 `0.0.0.0:9999`，浏览器访问 `http://localhost:9999` 即可进入管理界面。
   ```
   可选启动参数：
   -A 绑定地址（默认 0.0.0.0）
   -P 绑定端口（默认 9999）
   -u Web 登录用户名
   -p Web 登录密码（不设置则不启用 Web 认证）
   -T API Token（启用 Web 认证后调用 HTTP API 时必填）
   -d 存储目录
   ```
3. Docker 部署：仓库根目录提供了 `docker-compose.yml`，映射 9999 端口并挂载下载目录，执行 `docker compose up -d` 即可。
### 三、使用教程
1. 桌面端/移动端：打开应用，点击新建任务，粘贴 HTTP/HTTPS 链接、磁力链接或种子文件，选择保存目录后开始下载。
2. Web 管理界面：访问 `http://localhost:9999`，可以创建任务、查看进度、管理分类与设置；若设置了用户名和密码，登录后使用。
3. 批量与续传：支持暂停、继续、重试、批量操作、按状态筛选和分类管理，程序重启后会自动恢复未完成任务。
4. 浏览器接管：安装兼容的浏览器扩展后，可将网页下载请求直接发送到 PonyDownloader。
5. AI 接入：启用 MCP（`--mcp-enable`）后，AI Agent 可通过 `http://localhost:9999/mcp` 创建、查询与管理下载任务。

### 四、接口文档
1. 获取服务信息 - `GET /api/v1/info`
   ```
   返回版本、运行环境、系统架构等基础信息。
   ```
2. 解析下载资源 - `POST /api/v1/resolve`
   - 请求示例：
   ```json
   {
       "req": {
           "url": "https://example.com/file.zip"
       }
   }
   ```
   - 返回资源元数据与文件列表，创建任务前可先解析。
3. 创建下载任务 - `POST /api/v1/tasks`
   - 请求示例：
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
   - 也可以使用解析得到的资源 ID 作为 `rid`。
4. 查询任务 - `GET /api/v1/tasks`
   - 支持按任务 ID 或状态筛选，例如 `GET /api/v1/tasks?status=running`。
5. 暂停与继续 - `PUT /api/v1/tasks/{id}/pause`、`PUT /api/v1/tasks/{id}/continue`
6. 删除任务 - `DELETE /api/v1/tasks/{id}`，可加 `?force=true` 同时删除文件。
7. MCP 接口 - `POST /mcp`
   - 启用 MCP 后可接入 AI Agent，以自然语言管理下载任务。

### 五、专注的点
- 充分利用带宽：多任务并发、HTTP 多连接分段下载与 BitTorrent P2P 下载相结合。
- 一个入口管理多种协议：HTTP/HTTPS、BitTorrent、磁力链接、ed2k 统一在一个界面中处理。
- 原生跨平台体验：使用 Flutter 原生渲染，非 Electron 套壳，安装包更轻、占用更低、响应更快。
- 开放的自动化能力：REST API、CLI、Webhook、下载后脚本、JavaScript 扩展与 MCP 均可用于自动化。
- 轻量自托管：单文件 Web 程序即可部署，适合放在服务器或 NAS 上长期运行。

### 六、开发进度
- [X] HTTP/HTTPS 多连接下载
- [X] BitTorrent / 磁力链接
- [X] ed2k 下载
- [X] 任务管理（暂停、继续、重试、批量、筛选、分类）
- [X] 断点续传与启动恢复
- [X] Web 管理界面与账号认证
- [X] REST API 与 API Token
- [X] MCP / AI Agent 接入
- [X] 浏览器接管
- [X] JavaScript 扩展
- [X] Docker 部署
- [X] 睡眠/唤醒看门狗，自动恢复休眠期间中断的下载任务
- [ ] 正式版本发布与自动化测试完善

### 七、从源码构建

自行编译需要 Go 1.25+ 与 Flutter 3.41+，后端使用 `go build`，前端使用 `flutter build`。普通用户请从 [GitHub Releases](https://github.com/Mutantcat-Working-Group/PonyDownloader/releases) 下载对应平台的安装包，无需准备编译环境。
