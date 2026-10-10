# AI OCR EXPENSE TRACKER - BÁO CÁO DỰ ÁN

Học phần: Phát triển ứng dụng Đa Nền Tảng (Cross-Platform Application Development)
Trường Đại học Công nghệ Thông tin và Truyền thông Việt - Hàn (VKU)
Sinh viên thực hiện: Võ Thành Long
Mã sinh viên: 23IT147

---

## 1. TỔNG QUAN DỰ ÁN (PROJECT OVERVIEW)

AI OCR Expense Tracker là ứng dụng di động quản lý chi tiêu cá nhân thông minh được xây dựng bằng Flutter, tích hợp công nghệ trí tuệ nhân tạo nhận diện ký tự quang học Google ML Kit Text Recognition chạy trực tiếp trên thiết bị (on-device AI).

Mục tiêu của dự án là giải quyết vấn đề nhập liệu chi tiêu thủ công tốn thời gian và dễ sai sót. Ứng dụng cho phép người dùng chỉ cần chụp hóa đơn giấy hoặc chọn ảnh chụp màn hình từ thư viện, hệ thống sẽ tự động bóc tách tên cửa hàng, ngày giờ, số tiền thanh toán và tự động phân loại chi tiêu chính xác.

---

## 2. KIẾN TRÚC VÀ CÔNG NGHỆ (ARCHITECTURE & TECH STACK)

- Framework: Flutter 3.38+ / Dart 3.x
- Quản lý trạng thái (State Management): Flutter Riverpod 2.5+
- Cơ sở dữ liệu cục bộ (Local Database): Isar Database 3.1.0+ (NoSQL tốc độ cao, hỗ trợ indexing và schema type-safe)
- Xử lý thị giác máy tính & OCR:
  - Google ML Kit Text Recognition (chạy offline, bảo mật dữ liệu)
  - image_picker (chụp ảnh camera, chọn ảnh từ thư viện)
  - image_cropper (căn chỉnh góc, xoay và cắt hóa đơn trước khi nhận diện)
- Kiến trúc phần mềm: Feature-first Architecture kết hợp Clean Architecture, tách biệt rõ ràng giữa Data Models, Services, Riverpod Providers, Screens và Reusable Widgets.

---

## 3. CÁC TÍNH NĂNG CHÍNH (KEY FEATURES)

### 3.1. Quét hóa đơn tự động (AI OCR Engine)
- Hỗ trợ 2 nguồn hình ảnh: Chụp trực tiếp từ Camera (có khung căn chỉnh, bật/tắt flash) hoặc chọn ảnh có sẵn từ Thư viện (Gallery).
- Cắt và xoay ảnh: Giúp tối ưu hóa vùng chứa văn bản hóa đơn trước khi đưa qua mô hình học máy.
- Thuật toán bóc tách dữ liệu thông minh (Multi-pass Regex Extraction):
  - Nhận diện chính xác tổng tiền với mọi định dạng hóa đơn Việt Nam (VND, đ, dấu chấm phân cách hàng nghìn, số thập phân).
  - Khử nhiễu tiêu đề: Tự động loại trừ các dòng tiêu đề bảng như "Đơn giá", "Thành tiền", "SL", "Số HĐ" để trích xuất đúng tên thương hiệu (CGV Cinema, Highlands Coffee, Phúc Long, WinMart...).
  - Quy tắc phân loại ưu tiên: Hóa đơn vé xem phim rạp CGV tự động được phân loại chuẩn vào Entertainment (Giải trí) ngay cả khi có mua kèm bắp rang và nước ngọt.

### 3.2. Trực quan hóa dữ liệu và biểu đồ tương tác
- Biểu đồ tròn Spending Breakdown (Donut Chart): Phân tích tỷ trọng chi tiêu theo từng danh mục, hiển thị phần trăm và số tiền trực quan.
- Biểu đồ cột Last 7 Days Activity (Interactive Bar Chart):
  - Tương tác chạm để lọc (Tap-to-Filter): Chạm vào bất kỳ cột ngày nào trên biểu đồ để xem danh sách chi tiêu của riêng ngày đó. Chạm lại để bỏ lọc.
  - Hiển thị nhãn số tiền compact và hiệu ứng chuyển động mượt mà.

### 3.3. Bộ lọc chi tiêu đa chiều và quản lý giao dịch
- Lọc theo thời gian: Tất cả (All), Hôm nay (Today), Tuần này (This Week), Tháng này (This Month) và lọc theo ngày cụ thể được chọn từ biểu đồ.
- Lọc theo danh mục: Ăn uống (Food & Dining), Đi lại (Transportation), Giải trí (Entertainment), Học tập (Education), Thiết bị (Electronics & Gear), Khác (General / Other).
- Xem chi tiết giao dịch (Pop-up Bottom Sheet): Nhấn vào từng giao dịch để xem đầy đủ thông tin: Thứ, ngày, giờ chi tiết, mã ID giao dịch, nguồn nhập, số tiền.
- Thao tác nhanh: Vuốt để xóa (Swipe to delete) với hộp thoại xác nhận an toàn.
- Nhập thủ công (Manual Entry): Dành cho các khoản chi tiêu nhỏ lẻ không có hóa đơn giấy.

### 3.4. Báo cáo tài chính và sao kê
- Xuất file CSV chi tiết: Chứa đầy đủ thông tin ngày lập, kỳ báo cáo, bảng tổng hợp theo từng danh mục và danh sách chi tiết các giao dịch.
- Tạo bản in sao kê (Print Statement HTML / PDF): Định dạng chuẩn ngân hàng sẵn sàng in hoặc lưu PDF.

---

## 4. BẢNG KIỂM THỬ TỰ ĐỘNG (AUTOMATED TEST SUITE)

Dự án tích hợp bộ unit test toàn diện cho module xử lý hóa đơn trong file test/ocr_service_test.dart:
- Test case 1: Trích xuất hóa đơn vé xem phim CGV và phân loại Entertainment.
- Test case 2: Trích xuất hóa đơn trà sữa (TRA SUA SA) và loại bỏ dòng rác.
- Test case 3: Bóc tách tiền khi định dạng "Tổng cộng: 80.000" không có ký hiệu tiền tệ.
- Test case 4: Nhận diện hóa đơn điện tử giá trị gia tăng (HÓA ĐƠN GTGT NQ).
- Test case 5: Xử lý trường hợp nhãn tổng tiền ở dòng trên và giá trị số ở dòng dưới.
- Test case 6: Xử lý dấu phân cách hàng nghìn bằng dấu phẩy và chấm.
- Test case 7: Bóc tách số tiền có ký hiệu đ hoặc VND.
- Test case 8: Thuật toán dự phòng tìm số tiền lớn nhất khi không có từ khóa tổng cộng.
- Test case 9: Lọc sạch các dòng nhiễu như "Please Scan to share" hoặc "Ma HD".

Kết quả: 9/9 test cases passed.

---

## 5. HƯỚNG DẪN CÀI ĐẶT VÀ KHỞI CHẠY ỨNG DỤNG (SETUP GUIDE)

### Yêu cầu môi trường
- Flutter SDK phiên bản 3.2.0 trở lên
- Dart SDK phiên bản 3.2.0 trở lên
- Thiết bị Android thật hoặc Android Emulator (API level 21+)

### Các bước cài đặt:

1. Clone repository về máy:
```bash
git clone https://github.com/vothanhlong16072005-creator/VoThanhLong_23IT147_Project3_OCR_Expense_Tracker.git
cd VoThanhLong_23IT147_Project3_OCR_Expense_Tracker
```

2. Cài đặt các gói thư viện phụ thuộc:
```bash
flutter pub get
```

3. Sinh mã nguồn cho cơ sở dữ liệu Isar (nếu cần):
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Kiểm tra mã nguồn và chạy kiểm thử tự động:
```bash
flutter analyze
flutter test test/ocr_service_test.dart
```

5. Khởi chạy ứng dụng trên thiết bị:
```bash
flutter run
```

---

## 6. CẤU TRÚC THƯ MỤC NGUỒN (PROJECT STRUCTURE)

```
ocr_expense_tracker/
|-- lib/
|   |-- main.dart                      # Cấu hình Theme, ProviderScope, Entry point
|   |-- models/
|   |   |-- transaction.dart           # Entity Isar Database & Enum ExpenseCategory
|   |-- providers/
|   |   |-- transaction_provider.dart  # Riverpod StateNotifier, Auto-seed data
|   |-- screens/
|   |   |-- dashboard_screen.dart      # Màn hình chính, Biểu đồ, Bộ lọc, Chi tiết
|   |   |-- camera_screen.dart         # Màn hình chụp hóa đơn & nút chọn thư viện
|   |   |-- review_screen.dart         # Màn hình xác nhận & chỉnh sửa kết quả OCR
|   |-- services/
|   |   |-- ocr_service.dart           # ML Kit parsing regex & Category heuristics
|   |   |-- isar_service.dart          # CRUD Isar Database
|   |-- utils/
|   |   |-- export_service.dart        # Xuất CSV & Bản in HTML/PDF
|   |-- widgets/
|       |-- charts/                    # DonutChart & Interactive BarChart
|       |-- add_manual_expense_sheet.dart
|-- test/
|   |-- ocr_service_test.dart          # 9 Unit test cases kiểm tra OCR
|-- docs/
    |-- sample_receipts.html           # Mẫu 5 hóa đơn nhiệt dùng để test OCR
```
