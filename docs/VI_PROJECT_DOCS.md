# TÀI LIỆU DỰ ÁN: ỨNG DỤNG QUẢN LÝ CHI TIÊU & QUÉT HÓA ĐƠN OCR
*(Phiên dịch và bám sát 100% yêu cầu Mini-Project 3)*

## 1. TỔNG QUAN DỰ ÁN (Project Overview)
- **Mục tiêu:** Xây dựng ứng dụng quản lý tài chính cá nhân bằng Flutter, tích hợp trí tuệ nhân tạo trên thiết bị (on-device AI) để quét và phân tích hóa đơn mua hàng.
- **Công nghệ bắt buộc:** Flutter 3.x, Dart 3, Google ML Kit, SQLite / Isar.
- **Điểm nhấn kỹ thuật:** Xử lý OCR offline hoàn toàn (không tốn phí API đám mây), trích xuất dữ liệu bằng Regex, và tự vẽ biểu đồ bằng `CustomPainter`.

---

## 2. CHI TIẾT CÁC TÍNH NĂNG BẮT BUỘC (Core Specifications)

### 2.1. Camera và Cắt Ảnh (Camera & Cropping)
- Tích hợp màn hình Camera trực tiếp (Live viewfinder).
- Các chức năng: Bật/tắt Flash, Chạm để lấy nét (focus tap).
- Có một lớp phủ (overlay) hiển thị khung chữ nhật để người dùng căn lề và cắt (crop) ảnh hóa đơn.

### 2.2. Quét Chữ và Trích Xuất Dữ Liệu (OCR & Regex)
- Sử dụng package `google_mlkit_text_recognition` để quét chữ từ ảnh hóa đơn (tốc độ xử lý dưới 100ms, không cần mạng).
- Xây dựng một cỗ máy (engine) dùng **Regex** để tự động tìm và trích xuất:
  - **Tổng tiền:** Nhận diện các format như `150,000 VND`, `150.000 đ`.
  - **Ngày tháng:** Định dạng `DD/MM/YYYY`.
  - **Tên cửa hàng (Merchant):** Tìm kiếm dựa trên vị trí (thường nằm ở dòng đầu tiên).
- Cung cấp màn hình **Review (Xem xét lại)**: Cho phép người dùng sửa lại bằng tay nếu OCR quét sai trước khi bấm "Lưu".

### 2.3. Cơ Sở Dữ Liệu & Lưu Trữ (Local Database)
- Sử dụng `Sqflite` hoặc `Isar` để lưu dữ liệu offline.
- Giao dịch phải có các danh mục (Category) bắt buộc: `Food` (Ăn uống), `Study` (Học tập), `Travel` (Đi lại), `Gear` (Đồ dùng), `Entertainment` (Giải trí).
- Ảnh thumbnail (ảnh thu nhỏ) của hóa đơn sau khi cắt phải được lưu vào bộ nhớ cục bộ của ứng dụng.

### 2.4. Trực Quan Hóa Dữ Liệu (CustomPainter)
- **Biểu đồ Tròn (Donut/Pie Chart):** Thống kê chi tiêu theo danh mục. Phải có hiệu ứng chuyển động (Animation).
- **Biểu đồ Cột (Bar Chart):** Thống kê chi tiêu theo tuần.
- **LUẬT THÉP:** Tuyệt đối không được dùng thư viện biểu đồ bên thứ 3 (như `fl_chart`). Phải dùng `CustomPainter` và API Canvas của Flutter để tự vẽ các đường, khối, và trục.

---

## 3. HỒ SƠ NỘP BÀI (Deliverables)
Bạn cần nộp 3 phần bắt buộc:
1. **Demo Thực tế:** File cài đặt APK (Upload lên GitHub Releases hoặc Google Drive) + 1 đoạn Video ngắn 2-3 phút quay lại quá trình cầm máy quét hóa đơn thực tế.
2. **GitHub Repository (Mã nguồn):** Phải là Public. Lịch sử commit sạch sẽ, kiến trúc code chia module (clean architecture), và file `README.md` phải có hướng dẫn cài đặt.
3. **Báo cáo (PDF):** Dài 2 đến 4 trang, tuân thủ đúng Form Template (Mẫu báo cáo) mà đề bài đã cung cấp. Phải có Checklist, mô tả kiến trúc và ảnh chụp màn hình (screenshots).

---

## 4. TÍNH NĂNG MỞ RỘNG (ĐỂ LẤY ĐIỂM CỘNG / LÀM NỔI BẬT DỰ ÁN)

Vì bạn cần làm kiến trúc xịn (ui-ux-pro-max, clean architecture), đây là những tính năng mở rộng (Bonus) tôi đề xuất thêm vào để project ấn tượng hơn mà không tốn quá nhiều sức:

1. **Auto-Categorization (Tự động Phân loại):**
   - *Cách làm:* Khi ML Kit quét ra tên cửa hàng, dùng một Map (từ điển) đơn giản để tự chọn Category. Ví dụ: Nếu chữ có "Highlands", "Winmart" -> Tự động chọn `Food`. Có chữ "CGV" -> Chọn `Entertainment`. Tránh việc người dùng phải tự chọn tay.

2. **Chế độ Sáng/Tối (Dark/Light Mode Fluidity):**
   - *Cách làm:* Triển khai theme Sáng/Tối với màu sắc chuẩn mực. Điều này ghi điểm rất cao ở phần "Responsive & Design".

3. **Export Data (Xuất Báo Cáo CSV/PDF):**
   - *Cách làm:* Thêm nút "Xuất dữ liệu", gom toàn bộ DB lưu thành file Excel (.csv) cho người dùng chia sẻ qua Zalo/Email. Rất thực tế cho ứng dụng quản lý chi tiêu.

4. **Bảo mật Ứng dụng (Biometric Lock):**
   - *Cách làm:* Tích hợp thư viện `local_auth`. Khi mở app lên, yêu cầu quét Vân tay/FaceID mới cho xem biểu đồ chi tiêu. App tài chính thì bảo mật luôn là một điểm sáng chói.
