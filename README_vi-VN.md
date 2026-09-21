<div align=center>
<img src="icon.png" style="width:100px;" width="100"/>
<h2>PonyDownloader</h2>
</div>

[English](/README.md) | [简体中文](/README_zh-CN.md) | [繁體中文](/README_zh-TW.md) | [日本語](/README_ja-JP.md) | [Tiếng Việt](/README_vi-VN.md)

### 1. Giới thiệu tính năng
- Trình quản lý tải xuống nhanh, hiện đại, miễn phí và mã nguồn mở được xây dựng bằng Go và Flutter, hỗ trợ HTTP, HTTPS, BitTorrent, liên kết magnet và ed2k.
- Hỗ trợ Windows, macOS, Linux, Android, iOS và Web, với ứng dụng desktop/mobile gốc cùng giao diện Web có thể tự lưu trữ.
- Hỗ trợ đa nhiệm đồng thời, tải HTTP đa kết nối, khám phá nút DHT của BitTorrent, giao thức uTP, Web Seed, tải chọn tệp, quản lý tracker và giới hạn seed.
- Cung cấp REST API, CLI, tiện ích JavaScript, tích hợp trình duyệt, webhook và endpoint MCP để tự động hóa và kết nối AI Agent.
- Hỗ trợ theo chủ đề hệ thống, chế độ sáng/tối, nhiều màu nhấn và hơn 20 ngôn ngữ giao diện.

### 2. Cách triển khai
1. Desktop và mobile: tải trình cài đặt cho nền tảng của bạn từ [GitHub Releases](https://github.com/Mutantcat-Working-Group/PonyDownloader/releases).
2. Web tự lưu trữ: chạy tệp thực thi Web trong gói phát hành. Mặc định nó lắng nghe tại `0.0.0.0:9999`, sau đó mở `http://localhost:9999` trong trình duyệt.
   ```
   Các cờ tùy chọn:
   -A địa chỉ bind (mặc định 0.0.0.0)
   -P cổng bind (mặc định 9999)
   -u tên người dùng đăng nhập Web
   -p mật khẩu đăng nhập Web (không đặt thì không bật xác thực Web)
   -T API token (bắt buộc khi gọi HTTP API nếu đã bật xác thực Web)
   -d thư mục lưu trữ
   ```
3. Docker: `docker-compose.yml` trong thư mục gốc ánh xạ cổng 9999 và gắn thư mục tải xuống; chạy `docker compose up -d`.
4. Biên dịch từ mã nguồn: cần Go 1.25+ và Flutter 3.41+; backend dùng `go build`, frontend dùng `flutter build`.

### 3. Hướng dẫn sử dụng
1. Desktop/mobile: tạo tác vụ, dán URL HTTP/HTTPS, liên kết magnet hoặc tệp torrent, chọn thư mục lưu và bắt đầu tải.
2. Giao diện Web: mở `http://localhost:9999` để tạo tác vụ, theo dõi tiến độ, quản lý danh mục và cài đặt; đăng nhập khi đã bật xác thực.
3. Quản lý tác vụ: hỗ trợ tạm dừng, tiếp tục, thử lại, thao tác hàng loạt, lọc theo trạng thái và danh mục; tác vụ chưa xong sẽ được khôi phục sau khi khởi động lại.
4. Tích hợp trình duyệt: gửi yêu cầu tải từ trình duyệt tương thích trực tiếp đến PonyDownloader qua tiện ích mở rộng.
5. Tích hợp AI: bật MCP bằng `--mcp-enable`, AI Agent có thể quản lý tác vụ qua `http://localhost:9999/mcp` bằng ngôn ngữ tự nhiên.

### 4. Tài liệu API
1. Thông tin dịch vụ - `GET /api/v1/info`
   - Trả về thông tin cơ bản như phiên bản, runtime, hệ điều hành và kiến trúc.
2. Phân giải tài nguyên - `POST /api/v1/resolve`
   - Ví dụ yêu cầu:
   ```json
   {
       "req": {
           "url": "https://example.com/file.zip"
       }
   }
   ```
   - Trả về siêu dữ liệu tài nguyên và danh sách tệp; có thể phân giải trước khi tạo tác vụ.
3. Tạo tác vụ - `POST /api/v1/tasks`
   - Ví dụ yêu cầu:
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
   - Cũng có thể truyền ID tài nguyên nhận được từ resolve qua trường `rid`.
4. Truy vấn tác vụ - `GET /api/v1/tasks`
   - Hỗ trợ lọc theo ID hoặc trạng thái, ví dụ `GET /api/v1/tasks?status=running`.
5. Tạm dừng và tiếp tục - `PUT /api/v1/tasks/{id}/pause` và `PUT /api/v1/tasks/{id}/continue`
6. Xóa tác vụ - `DELETE /api/v1/tasks/{id}`, thêm `?force=true` để xóa cả tệp đã tải.
7. Endpoint MCP - `POST /mcp`
   - Kết nối AI Agent để quản lý tác vụ tải bằng ngôn ngữ tự nhiên sau khi bật MCP.

### 5. Trọng tâm
- Tận dụng tối đa băng thông bằng cách kết hợp đa nhiệm, tải HTTP đa kết nối và tải P2P BitTorrent.
- Quản lý nhiều giao thức qua một điểm vào: HTTP/HTTPS, BitTorrent, liên kết magnet và ed2k trong cùng một giao diện.
- Trải nghiệm đa nền tảng gốc: được hiển thị bằng Flutter thay vì shell Electron, nhẹ hơn và tiêu tốn ít tài nguyên hơn.
- Khả năng tự động hóa mở: REST API, CLI, webhook, tập lệnh sau tải, tiện ích JavaScript và MCP.
- Tự lưu trữ nhẹ: chỉ cần một tệp thực thi Web để chạy lâu dài trên máy chủ hoặc NAS.

### 6. Tiến độ phát triển
- [X] Tải xuống HTTP/HTTPS đa kết nối
- [X] BitTorrent và liên kết magnet
- [X] Tải xuống ed2k
- [X] Quản lý tác vụ (tạm dừng, tiếp tục, thử lại, hàng loạt, lọc, danh mục)
- [X] Tải tiếp và khôi phục khi khởi động
- [X] Giao diện Web và xác thực tài khoản
- [X] REST API và API token
- [X] Tích hợp MCP / AI Agent
- [X] Tích hợp trình duyệt
- [X] Tiện ích JavaScript
- [X] Triển khai Docker
- [ ] Phát hành ổn định và hoàn thiện kiểm thử tự động
