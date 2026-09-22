<div align=center>
<img src="icon.png" style="width:100px;" width="100"/>
<h2>PonyDownloader</h2>
</div>

[English](/README.md) | [简体中文](/README_zh-CN.md)

### 1. Overview
- A fast, modern, free and open-source download manager built with Go and Flutter, supporting HTTP, HTTPS, BitTorrent, magnet links and ed2k.
- Available on Windows, macOS, Linux, Android, iOS and the Web, with native desktop and mobile clients plus a self-hostable web management UI.
- Multi-task concurrency, multi-connection HTTP transfers, BitTorrent DHT discovery, uTP transport, Web Seeds, selective file downloads, tracker management and seeding limits.
- REST API, CLI, JavaScript extensions, browser integration, webhooks and an MCP endpoint for automation and AI-agent integration.
- Follows the system theme, supports light/dark mode, multiple accent colors and 20+ UI languages.
- Resumes interrupted downloads automatically after the host wakes from sleep or the display turns off, so a screen-off or suspend cycle never breaks active tasks.

### 2. Deployment
1. Desktop and mobile: download the installer for your platform from [GitHub Releases](https://github.com/Mutantcat-Working-Group/PonyDownloader/releases) and install it. Windows ships an NSIS installer (x64), macOS ships a universal ad-hoc signed DMG (Intel and Apple Silicon), and Linux ships AppImages for x64 and arm64.
2. Self-hosted Web service: run the Web binary from the release package. It listens on `0.0.0.0:9999` by default, then visit `http://localhost:9999` in your browser.
   ```
   Optional flags:
   -A bind address (default 0.0.0.0)
   -P bind port (default 9999)
   -u Web login username
   -p Web login password (Web auth stays disabled when empty)
   -T API token (required for the HTTP API when Web auth is enabled)
   -d storage directory
   ```
3. Docker: the `docker-compose.yml` in the repo root maps port 9999 and mounts a download directory; run `docker compose up -d`.

### 3. Usage
1. Desktop and mobile: create a task, paste an HTTP/HTTPS URL, magnet link or torrent file, choose a save directory and start downloading.
2. Web UI: open `http://localhost:9999` to create tasks, view progress, manage categories and change settings; sign in when authentication is enabled.
3. Task management: pause, resume, retry, batch operations, status filtering and categories are supported, and unfinished tasks are recovered after a restart.
4. Browser integration: send download requests from compatible browsers directly to PonyDownloader through the browser extension.
5. AI integration: enable MCP with `--mcp-enable`, then AI agents can manage tasks through `http://localhost:9999/mcp` in natural language.

### 4. API Documentation
1. Service info - `GET /api/v1/info`
   - Returns basic information such as version, runtime, OS and architecture.
2. Resolve a resource - `POST /api/v1/resolve`
   - Request example:
   ```json
   {
       "req": {
           "url": "https://example.com/file.zip"
       }
   }
   ```
   - Returns resource metadata and the file list; resolve before creating a task when needed.
3. Create a task - `POST /api/v1/tasks`
   - Request example:
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
   - You can also pass the resource ID returned by resolve as `rid`.
4. Query tasks - `GET /api/v1/tasks`
   - Supports filtering by task ID or status, for example `GET /api/v1/tasks?status=running`.
5. Pause and continue - `PUT /api/v1/tasks/{id}/pause` and `PUT /api/v1/tasks/{id}/continue`
6. Delete a task - `DELETE /api/v1/tasks/{id}`, with optional `?force=true` to remove files as well.
7. MCP endpoint - `POST /mcp`
   - Connect AI agents to manage downloads with natural language after MCP is enabled.

### 5. Focus
- Fully use bandwidth by combining multi-task concurrency, multi-connection HTTP downloads and BitTorrent P2P downloads.
- Manage multiple protocols through one entry: HTTP/HTTPS, BitTorrent, magnet links and ed2k in the same interface.
- Native cross-platform experience: rendered natively with Flutter instead of an Electron shell, with a lighter package and lower overhead.
- Open automation capabilities: REST API, CLI, webhooks, post-download scripts, JavaScript extensions and MCP.
- Lightweight self-hosting: a single Web binary can be deployed and run on servers or NAS devices for long periods.

### 6. Roadmap
- [X] HTTP/HTTPS multi-connection downloads
- [X] BitTorrent and magnet links
- [X] ed2k downloads
- [X] Task management (pause, resume, retry, batch, filtering, categories)
- [X] Resume and startup recovery
- [X] Web management UI with account authentication
- [X] REST API with API token
- [X] MCP / AI-agent integration
- [X] Browser integration
- [X] JavaScript extensions
- [X] Docker deployment
- [X] Wake/sleep watchdog that resumes interrupted downloads
- [ ] Stable release and complete automated tests

### 7. Build from Source

Building from source requires Go 1.25+ and Flutter 3.41+. Build the backend with `go build` and the frontend with `flutter build`.

This section only covers building from source. Regular users should download ready-made installers from [GitHub Releases](https://github.com/Mutantcat-Working-Group/PonyDownloader/releases).

---

## Acknowledgments

This repository is a fork of [GopeedLab/gopeed](https://github.com/GopeedLab/gopeed). Thanks to the original authors for their open-source work; this repository continues to build upon it.
