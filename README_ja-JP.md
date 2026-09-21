<div align=center>
<img src="icon.png" style="width:100px;" width="100"/>
<h2>PonyDownloader</h2>
</div>

[English](/README.md) | [简体中文](/README_zh-CN.md) | [繁體中文](/README_zh-TW.md) | [日本語](/README_ja-JP.md) | [Tiếng Việt](/README_vi-VN.md)

### 一、機能概要
- Go と Flutter で作られた高速・モダン・無料のオープンソースダウンローダーで、HTTP、HTTPS、BitTorrent、マグネットリンク、ed2k に対応しています。
- Windows、macOS、Linux、Android、iOS、Web に対応し、ネイティブのデスクトップ・モバイルクライアントと、セルフホスト可能な Web 管理画面を提供します。
- マルチタスク同時実行、HTTP マルチコネクション分割転送、BitTorrent の DHT ノード探索、uTP、Web Seed、ファイル選択ダウンロード、Tracker 管理、シード制限に対応。
- REST API、CLI、JavaScript 拡張、ブラウザ連携、Webhook、MCP エンドポイントを提供し、自動化や AI エージェントとの連携が可能です。
- システムテーマ追従、ライト/ダークモード、複数のアクセントカラー、20 以上の UI 言語に対応しています。

### 二、デプロイ方法
1. デスクトップ・モバイル：[GitHub Releases](https://github.com/Mutantcat-Working-Group/PonyDownloader/releases) から各プラットフォームのインストーラをダウンロードしてインストールします。
2. セルフホスト Web サービス：配布パッケージ内の Web バイナリを起動します。デフォルトで `0.0.0.0:9999` で待ち受けるので、ブラウザで `http://localhost:9999` を開きます。
   ```
   主な起動オプション：
   -A バインドアドレス（デフォルト 0.0.0.0）
   -P バインドポート（デフォルト 9999）
   -u Web ログインユーザー名
   -p Web ログインパスワード（未設定なら Web 認証は無効）
   -T API トークン（Web 認証有効時に HTTP API で必須）
   -d ストレージディレクトリ
   ```
3. Docker：リポジトリ直下の `docker-compose.yml` が 9999 ポートとダウンロードディレクトリをマウントするので、`docker compose up -d` を実行します。
4. ソースからのビルド：Go 1.25+ と Flutter 3.41+ が必要です。バックエンドは `go build`、フロントエンドは `flutter build` でビルドします。

### 三、使い方
1. デスクトップ・モバイル：タスクを作成し、HTTP/HTTPS リンク、マグネットリンク、トレントファイルを貼り付けて保存先を選び、ダウンロードを開始します。
2. Web 管理画面：`http://localhost:9999` を開いて、タスク作成、進捗確認、カテゴリ管理、設定変更ができます。認証を有効にした場合はログインが必要です。
3. タスク管理：一時停止、再開、再試行、一括操作、ステータスフィルタ、カテゴリに対応し、再起動後も未完了タスクを自動復元します。
4. ブラウザ連携：対応ブラウザの拡張機能から、Web ページのダウンロード要求を PonyDownloader に直接送信できます。
5. AI 連携：MCP を有効化（`--mcp-enable`）すると、AI エージェントが `http://localhost:9999/mcp` 経由で自然言語によりタスクを管理できます。

### 四、API ドキュメント
1. サービス情報 - `GET /api/v1/info`
   - バージョン、ランタイム、OS、アーキテクチャなどの基本情報を返します。
2. リソースの解析 - `POST /api/v1/resolve`
   - リクエスト例：
   ```json
   {
       "req": {
           "url": "https://example.com/file.zip"
       }
   }
   ```
   - リソースのメタデータとファイル一覧を返します。必要に応じてタスク作成前に解析できます。
3. タスクの作成 - `POST /api/v1/tasks`
   - リクエスト例：
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
   - 解析で得たリソース ID を `rid` として渡すこともできます。
4. タスクの取得 - `GET /api/v1/tasks`
   - タスク ID やステータスで絞り込み可能です（例：`GET /api/v1/tasks?status=running`）。
5. 一時停止と再開 - `PUT /api/v1/tasks/{id}/pause`、`PUT /api/v1/tasks/{id}/continue`
6. タスクの削除 - `DELETE /api/v1/tasks/{id}`、`?force=true` でファイルも削除可能。
7. MCP エンドポイント - `POST /mcp`
   - MCP 有効化後、AI エージェントが自然言語でダウンロードタスクを管理できます。

### 五、注力している点
- 帯域幅を最大限活用：マルチタスク同時実行、HTTP マルチコネクション分割ダウンロード、BitTorrent P2P を組み合わせます。
- 複数プロトコルを 1 つのエントリで管理：HTTP/HTTPS、BitTorrent、マグネットリンク、ed2k を同じ UI で処理します。
- ネイティブなクロスプラットフォーム体験：Electron ではなく Flutter でネイティブ描画し、軽量で低オーバーヘッドです。
- オープンな自動化基盤：REST API、CLI、Webhook、ダウンロード後スクリプト、JavaScript 拡張、MCP を自動化に利用できます。
- 軽量なセルフホスト：単一の Web バイナリだけでサーバーや NAS に長期運用できます。

### 六、開発進捗
- [X] HTTP/HTTPS マルチコネクションダウンロード
- [X] BitTorrent / マグネットリンク
- [X] ed2k ダウンロード
- [X] タスク管理（一時停止、再開、再試行、一括、フィルタ、カテゴリ）
- [X] レジュームと再起動後の復元
- [X] Web 管理画面とアカウント認証
- [X] REST API と API トークン
- [X] MCP / AI エージェント連携
- [X] ブラウザ連携
- [X] JavaScript 拡張
- [X] Docker デプロイ
- [ ] 安定版リリースと自動テストの整備
