# MINI-PROJECT SHORT TECHNICAL REPORT
**Môn học:** Phát triển ứng dụng di động đa nền tảng (VKU)
**Tên Dự án:** Mini-Project 3: OCR Expense Tracker & Receipt Parser
**Sinh viên thực hiện:** [Tên của bạn]
**Ngày nộp:** [Ngày/Tháng/Năm]

---

## 1. THÔNG TIN CHUNG & LIÊN KẾT NỘP BÀI
* **Sinh viên thực hiện:**
  1. [Họ và Tên] — Mã SV: [22ITxxx] — Vai trò: Fullstack & Architecture — Đóng góp: 100%
* **🔗 Link tải APK (Demo):** [Dán link Google Drive chứa file app-release.apk vào đây]
* **💻 GitHub Repository:** [https://github.com/your-username/ocr_expense_tracker]
* **🎥 Video Demo:** [Dán link Youtube/Drive video quay màn hình quét hoá đơn]

---

## 2. CHECKLIST TÍNH NĂNG ĐÃ TRIỂN KHAI
| # | Tính năng yêu cầu | Trạng thái | Chi tiết triển khai & Mức độ hoàn thiện |
|:---:|---|:---:|---|
| 1 | Camera Capture & Image Cropping | ✅ Hoàn thành | Viewfinder trực tiếp, lấy nét, bật flash. Sử dụng `image_cropper` cắt ảnh. |
| 2 | ML Kit Text Recognition & Regex | ✅ Hoàn thành | Xử lý OCR offline (<100ms). Regex tự động bóc tách Số tiền, Ngày và Cửa hàng. |
| 3 | Local Database & Persistence | ✅ Hoàn thành | Lưu trữ cục bộ tốc độ cao với `Isar` Database. |
| 4 | Custom Canvas Visualizations | ✅ Hoàn thành | Tự vẽ 100% bằng `CustomPainter` (Biểu đồ Donut & Cột) kèm Animation mượt mà. Không dùng thư viện ngoài. |
| 5 | (Nâng cao) Auto-Categorization | ✅ Hoàn thành | Tự động phân loại danh mục (Food, Travel..) dựa trên tên cửa hàng OCR quét được. |
| 6 | (Nâng cao) Export Data to CSV | ✅ Hoàn thành | Nút xuất dữ liệu chi tiêu ra file `.csv` và chia sẻ trực tiếp qua Zalo/Email. |

---

## 3. KIẾN TRÚC KỸ THUẬT & CẤU TRÚC DỰ ÁN
**Cấu trúc thư mục (Clean Architecture / Feature-first):**
* `lib/models/`: Chứa các thực thể dữ liệu của Isar (`transaction.dart`).
* `lib/services/`: Tách biệt logic xử lý khỏi giao diện (`ocr_service.dart`, `isar_service.dart`).
* `lib/providers/`: Quản lý trạng thái bằng Riverpod (`transaction_provider.dart`).
* `lib/screens/`: Các giao diện chính của luồng thao tác.

**Luồng Quản lý Trạng thái (State Management):**
Dự án sử dụng **Riverpod** (`StateNotifierProvider`). Giao diện lắng nghe dữ liệu từ `transactionNotifierProvider`. Khi một hoá đơn được quét và lưu xuống Isar DB, State tự động làm mới, kéo theo biểu đồ và danh sách tự động vẽ lại (redraw) mà không cần gọi `setState`.

**Xử lý Ngoại lệ (Exception Handling):**
Các khối Try-Catch được bọc quanh cụm Camera và ML Kit. Khi OCR không nhận diện được ngày hoặc tiền, thuật toán Fallback tự động gán ngày hôm nay (`DateTime.now()`) hoặc tiền = 0 để tránh ứng dụng bị crash đột ngột.

---

## 4. MINH CHỨNG & ẢNH CHỤP MÀN HÌNH
*(*Hướng dẫn trên Word: Xoá dòng này và chèn 4 ảnh chụp màn hình vào đây: 1 Ảnh Dashboard có biểu đồ, 1 Ảnh đang mở Camera, 1 Ảnh Cắt hóa đơn, 1 Ảnh Review kết quả OCR.*)*

---

## 5. THÁCH THỨC KỸ THUẬT & CÁCH GIẢI QUYẾT
* **Vấn đề 1: Trích xuất đúng định dạng tiền tệ trên hoá đơn Việt Nam**
  * *Khó khăn:* Hoá đơn ghi rất nhiều định dạng khác nhau (`150.000`, `150,000`, `150.000 đ`, `150000 VND`). 
  * *Giải quyết:* Xây dựng Regex nhiều lớp. Nếu chữ "Tổng" bị mờ, thuật toán Fallback sẽ càn quét toàn bộ văn bản và lấy ra con số double lớn nhất làm số tiền chi tiêu hợp lý nhất.
* **Vấn đề 2: Tạo hiệu ứng chuyển động (Animation) cho CustomPainter**
  * *Khó khăn:* `CustomPainter` mặc định chỉ vẽ tĩnh một lần. Việc vẽ biểu đồ không có thư viện ngoài khá cứng nhắc.
  * *Giải quyết:* Bọc CustomPaint vào `AnimatedBuilder` kèm theo `CurvedAnimation`. Truyền giá trị `progress` (0.0 đến 1.0) vào Painter để điều khiển nét vẽ vòng cung (`drawArc`) và độ cao cột (`drawRRect`), tạo ra chuyển động 60FPS mượt mà theo chuẩn UI-UX hiện đại.
