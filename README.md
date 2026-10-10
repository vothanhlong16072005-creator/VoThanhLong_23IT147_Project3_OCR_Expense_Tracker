# AI OCR Expense Tracker (Mobile Mini-Project 3)

**Học phần**: Phát triển ứng dụng Đa Nền Tảng (Cross-Platform Application Development)  
**Trường**: Đại học Công nghệ Thông tin và Truyền thông Việt - Hàn (VKU)  
**Sinh viên thực hiện**: Võ Thành Long  
**Mã sinh viên**: 23IT147  

---

## 📱 Giới thiệu dự án (Overview)

**AI OCR Expense Tracker** là ứng dụng di động quản lý chi tiêu cá nhân thông minh được xây dựng bằng **Flutter**, tích hợp công nghệ **Google ML Kit Text Recognition (AI OCR)** trên thiết bị di động (on-device). Ứng dụng giải quyết bài toán nhập liệu chi tiêu thủ công tốn thời gian bằng cách tự động nhận diện, trích xuất dữ liệu hóa đơn (Tên cửa hàng, Ngày giờ, Tổng số tiền) và tự động phân loại chi tiêu thông minh.

---

## ✨ Tính năng nổi bật (Key Features)

### 1. 📷 Quét hóa đơn tự động bằng AI OCR (Core Feature)
- **Hỗ trợ 2 nguồn ảnh**:
  - Chụp ảnh trực tiếp từ Camera với khung ngắm căn chỉnh và bật/tắt đèn Flash.
  - Chọn ảnh hóa đơn/ảnh chụp màn hình sẵn có từ Thư viện (Gallery).
- **Cắt xén ảnh (Image Cropper)**: Cho phép xoay, lật, căn chỉnh góc hóa đơn trước khi quét.
- **Trích xuất đa tầng (Multi-pass Regex Extraction)**:
  - Tự động bóc tách tổng tiền chính xác với mọi định dạng (VND, đ, dấu chấm/phẩy, ký hiệu tiền tệ).
  - Lọc nhiễu thông minh: Tự loại bỏ các dòng tiêu đề bảng như `Đơn giá`, `Thành tiền`, `SL`, `Mã HD` để nhận diện đúng thương hiệu (CGV Cinema, Highlands, Phúc Long, WinMart...).
  - Ưu tiên danh mục chuẩn xác: Vé xem phim CGV luôn được phân loại vào **Entertainment** (Giải trí) dù hóa đơn có chứa bắp nước/combo.

### 2. 📊 Trực quan hóa dữ liệu & Biểu đồ tương tác (Interactive Analytics)
- **Biểu đồ tròn (Spending Breakdown Donut Chart)**: Thống kê tỷ trọng chi tiêu theo từng danh mục có phần trăm và nhãn rõ ràng.
- **Biểu đồ cột 7 ngày (Interactive 7-Day Activity Chart)**:
  - **Chạm để lọc (Tap-to-Filter)**: Nhấn vào bất kỳ cột ngày nào để xem riêng danh sách giao dịch của ngày hôm đó.
  - Hiển thị nhãn số tiền compact và hiệu ứng chuyển động mượt mà.

### 3. 🔍 Bộ lọc đa chiều & Quản lý giao dịch
- **Lọc theo thời gian**: `All Time`, `Today`, `This Week`, `This Month` và lọc theo ngày cụ thể.
- **Lọc theo danh mục**: Ăn uống (Food), Đi lại (Transportation), Giải trí (Entertainment), Học tập (Education), Công nghệ (Gear), Khác (General).
- **Xem chi tiết (Pop-up Details)**: Chạm vào giao dịch để mở bảng chi tiết đầy đủ thông tin (Thứ, Ngày, Giờ, Mã ID, Nguồn hóa đơn, Số tiền).
- **Vuốt để xóa (Swipe-to-delete)**: Thao tác nhanh với hộp thoại xác nhận an toàn.
- **Nhập chi tiêu thủ công**: Dành cho các khoản chi tiêu không có hóa đơn giấy.

### 4. 📑 Báo cáo tài chính & Xuất file chuyên nghiệp
- **Xuất CSV chi tiết (Detailed CSV Statement)**: Đầy đủ metadata ngày lập báo cáo, kỳ báo cáo, bảng tổng hợp theo danh mục và sổ cái chi tiết.
- **In báo cáo sao kê (Print Statement HTML / PDF)**: Tạo bản sao kê chuẩn hóa có thể in trực tiếp hoặc lưu file PDF.

---

## 🛠️ Công nghệ sử dụng (Tech Stack)

| Thành phần | Công nghệ / Thư viện | Vai trò |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.38+ (Dart 3.x) | Phát triển giao diện đa nền tảng |
| **State Management** | Flutter Riverpod 2.5+ | Quản lý trạng thái phân tán, phản ứng nhanh |
| **Local Database** | Isar Database 3.1.0+1 | Cơ sở dữ liệu NoSQL cục bộ hiệu năng cao, type-safe |
| **AI OCR Engine** | Google ML Kit Text Recognition | Nhận diện ký tự quang học offline trên thiết bị |
| **Image Processing** | `image_picker` + `image_cropper` | Chụp, chọn và cắt ảnh hóa đơn |
| **Architecture** | Feature-first / Clean Architecture | Phân tách rõ ràng models, services, providers, screens, widgets |

---

## 🚀 Hướng dẫn cài đặt & Chạy ứng dụng (Getting Started)

### Yêu cầu môi trường
- Flutter SDK >= 3.2.0
- Dart SDK >= 3.2.0
- Android SDK (API level 21 trở lên, compileSdk 34)
- Thiết bị Android thật hoặc Android Emulator

### Các bước thực hiện:
```bash
# 1. Clone repository
git clone <URL_REPO_CUA_BAN>
cd ocr_expense_tracker

# 2. Cài đặt các dependencies
flutter pub get

# 3. Chạy build runner nếu cần sinh mã Isar
dart run build_runner build --delete-conflicting-outputs

# 4. Chạy kiểm tra code và chạy test
flutter analyze
flutter test test/ocr_service_test.dart

# 5. Khởi chạy ứng dụng
flutter run
```

---

## 🧪 Kiểm thử tự động (Automated Testing)
Dự án đã tích hợp bộ kiểm thử đơn vị cho thuật toán trích xuất OCR (`test/ocr_service_test.dart`) bao gồm 9 kịch bản thực tế (Hóa đơn rạp phim CGV, trà sữa, hóa đơn điện tử VAT, vé xe Grab, nhà sách Fahasa...).
```bash
flutter test test/ocr_service_test.dart
```

---

## 📋 Cấu trúc thư mục (Directory Structure)
```
ocr_expense_tracker/
├── lib/
│   ├── main.dart                      # Cấu hình Theme, ProviderScope, Entry point
│   ├── models/
│   │   ├── transaction.dart           # Entity Isar & Enum ExpenseCategory
│   ├── providers/
│   │   ├── transaction_provider.dart  # Riverpod StateNotifier, Auto-seed data
│   ├── screens/
│   │   ├── dashboard_screen.dart      # Màn hình chính, Biểu đồ, Bộ lọc, Chi tiết
│   │   ├── camera_screen.dart         # Màn hình chụp hóa đơn & nút chọn thư viện
│   │   ├── review_screen.dart         # Màn hình xác nhận & chỉnh sửa kết quả OCR
│   ├── services/
│   │   ├── ocr_service.dart           # ML Kit parsing regex & Category heuristics
│   │   ├── isar_service.dart          # CRUD Isar Database
│   ├── utils/
│   │   ├── export_service.dart        # Xuất CSV & Bản in HTML/PDF
│   └── widgets/
│       ├── charts/                    # DonutChart & Interactive BarChart
│       └── add_manual_expense_sheet.dart
└── test/
    └── ocr_service_test.dart          # 9 Unit test cases kiểm tra OCR
```
