# MINI-PROJECT SHORT TECHNICAL REPORT
**Course:** Cross-Platform Mobile App Development (VKU)
**Mini-Project Title:** Mini-Project 3: OCR Expense Tracker & Receipt Parser
**Team / Student Name:** [Your Name]
**Submission Date:** [DD/MM/YYYY]

---

## 1. GENERAL INFORMATION & DELIVERABLE LINKS
* **Team Members:**
  1. [Your Full Name] — Student ID: [22ITxxx] — Role: Fullstack & Architecture — Contribution: 100%
* **🔗 Live Demo URL:** [Link to your Google Drive containing app-release.apk]
* **💻 GitHub Repository:** [https://github.com/your-username/ocr_expense_tracker]
* **🎥 Video Demo (Optional):** [https://youtu.be/xxx or Drive Video Link]

---

## 2. FEATURE IMPLEMENTATION CHECKLIST
| # | Required Feature | Status | Implementation Details & Acceptance Level |
|:---:|---|:---:|---|
| 1 | Camera Capture & Image Cropping | ✅ Complete | Live viewfinder with focus/flash toggle. Uses `image_cropper` for framing. |
| 2 | ML Kit Text Recognition & Regex | ✅ Complete | Offline sub-100ms text extraction. Regex parses Amount, Date, and Merchant. |
| 3 | Local Database & Persistence | ✅ Complete | Uses `Isar` DB for lightning-fast CRUD operations and offline persistence. |
| 4 | Custom Canvas Visualizations | ✅ Complete | 100% custom `CustomPainter` for animated Donut Chart and Bar Chart. No 3rd party chart libraries used. |
| 5 | (Bonus) Auto-Categorization | ✅ Complete | Uses a Keyword Map heuristic to automatically categorize merchants based on OCR text. |
| 6 | (Bonus) Export Data to CSV | ✅ Complete | Uses `share_plus` to export Isar DB transactions to a shareable CSV file. |

---

## 3. TECHNICAL ARCHITECTURE & PROJECT STRUCTURE
**Directory Structure (Feature/Layer-first):**
* `lib/models/`: Contains Isar data models (`transaction.dart`).
* `lib/services/`: Core logic decoupled from UI (`ocr_service.dart`, `isar_service.dart`).
* `lib/providers/`: State management using Riverpod for reactivity (`transaction_provider.dart`).
* `lib/screens/`: UI Views (`camera_screen.dart`, `review_screen.dart`, `dashboard_screen.dart`).

**State Management Flows:**
We utilized **Riverpod** (`StateNotifierProvider`). The UI listens to `transactionNotifierProvider`. When a receipt is scanned and saved, the state invalidates and fetches updated data from Isar DB, automatically redrawing the charts and lists without calling `setState`.

**Exception Handling:**
Try-catch blocks are wrapped around the camera initialization and ML Kit parsing logic. If parsing fails, fallbacks (default date to `DateTime.now()`, default category to `other`) are safely applied so the app never crashes.

---

## 4. EMPIRICAL EVIDENCE & SCREENSHOTS
*(*Hướng dẫn trên Word: Xoá dòng này và dán 4 ảnh chụp màn hình vào đây: 1 Ảnh trang chủ, 1 Ảnh chụp hóa đơn, 1 Ảnh Crop, 1 Ảnh màn hình Review xác nhận số tiền.*)*

---

## 5. TECHNICAL CHALLENGES & RESOLUTIONS
* **Bottleneck 1: Extracting Money Format from Vietnam Receipts**
  * *Challenge:* Vietnamese receipts use multiple formats (`150.000`, `150,000`, `150.000 đ`, `150000 VND`). 
  * *Resolution:* Built a robust multi-condition Regex heuristic and a fallback algorithm that extracts the largest double value in the OCR text block if the word "Total/Tổng" is unreadable.
* **Bottleneck 2: Building Animations with CustomPainter**
  * *Challenge:* Standard `CustomPainter` is static.
  * *Resolution:* Used `AnimatedBuilder` wrapped with a `CurvedAnimation` controller to pass a 0.0 to 1.0 progress value into the Painter's `canvas.drawArc` and `canvas.drawRRect` methods, achieving 60FPS fluid animations.
