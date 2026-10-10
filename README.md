# AI OCR EXPENSE TRACKER - PROJECT REPORT

Course: Cross-Platform Application Development  
Institution: Vietnam - Korea University of Information and Communication Technology (VKU)  
Student Name: Vo Thanh Long  
Student ID: 23IT147  

---

## 1. PROJECT OVERVIEW

AI OCR Expense Tracker is a smart personal finance management mobile application built using the Flutter framework. It integrates on-device Optical Character Recognition (OCR) powered by Google ML Kit Text Recognition to process receipts directly without relying on external cloud APIs or risking user privacy.

The primary objective of the system is to solve the time-consuming and error-prone process of manual expense tracking. By capturing paper receipts with a smartphone camera or selecting digital receipts from the gallery, users can instantly extract key transaction metadata—such as Merchant Name, Date and Time, and Total Amount—while leveraging heuristic categorization to organize expenditures automatically.

---

## 2. ARCHITECTURE AND TECHNOLOGY STACK

- Framework: Flutter 3.38+ / Dart 3.x
- State Management: Flutter Riverpod 2.5+ (reactive, declarative, and decoupled state lifecycle)
- Local Database: Isar Database 3.1.0+ (embedded high-performance NoSQL database featuring type-safe querying, schema auto-generation, and ACID transactions)
- Computer Vision and OCR Pipeline:
  - Google ML Kit Text Recognition (offline on-device inference)
  - image_picker (camera capture and gallery selection)
  - image_cropper (manual perspective alignment and image pre-processing)
- Software Architecture: Clean Architecture with Feature-First modularization, strictly separating Entities/Models, Repositories/Services, State Providers, Screens, and UI Widgets.

---

## 3. CORE FEATURES

### 3.1. Intelligent Receipt Scanning (AI OCR Engine)
- Dual Input Channels: Supports real-time camera capture with an alignment guide and flash toggle, as well as importing receipt photos or screenshots from the device photo gallery.
- Perspective Alignment: Built-in crop and rotation utilities allow users to adjust receipt framing for optimal OCR accuracy.
- Multi-Pass Regular Expression Parser:
  - Robust Amount Extraction: Accurately identifies totals across diverse Vietnamese currency formats (including VND, d, dot/comma thousand separators, and decimal notation).
  - Table Header Noise Rejection: Automatically ignores common invoice table columns such as "Don gia", "Thanh tien", "SL", and "Ma HD", correctly pinpointing the authentic merchant brand (e.g., CGV Cinema, Highlands Coffee, Phuc Long, WinMart).
  - Priority Categorization Heuristics: Receipts from cinema brands (such as CGV Cinema) are prioritized into the Entertainment category, even when accompanied by food and drink items like popcorn or beverages.

### 3.2. Interactive Analytics and Visualizations
- Spending Breakdown (Animated Donut Chart): Visualizes relative expenditure distribution across categories with calculated percentages and labeled legends.
- Last 7 Days Activity (Interactive Bar Chart):
  - Tap-to-Filter Capability: Tapping any bar in the 7-day chart highlights that specific date and automatically filters the transaction list below to show only expenses from that day. Tapping the bar again clears the selection.
  - Compact currency labels and animated height scaling for an intuitive user experience.

### 3.3. Multidimensional Filtering and Expense Management
- Temporal Filters: All Time, Today, This Week, This Month, and day-specific selections.
- Category Filters: Horizontally scrollable chips covering Food and Dining, Transportation, Entertainment, Education, Electronics and Gear, and General / Other.
- Transaction Details Modal: Tapping any transaction in the list opens an informative pop-up bottom sheet displaying weekday, timestamp, transaction ID, origin type (OCR scan vs. manual record), and full monetary value.
- Quick Actions: Swipe-to-delete with confirmation dialogs and manual expense entry for undocumented cash purchases.

### 3.4. Export and Statement Generation
- Itemized CSV Statement: Generates financial exports complete with report metadata, statement period, category breakdown tables, and sequential ledger rows.
- Printable Statement (HTML / PDF): Produces a bank-grade statement layout suitable for printing or saving to PDF.

---

## 4. AUTOMATED TEST SUITE

The OCR extraction engine is verified by comprehensive unit tests in test/ocr_service_test.dart:
- Test 1: Extract total amount, date, merchant, and assign Entertainment category for CGV Cinema tickets.
- Test 2: Extract amount and merchant from milk tea receipts (TRA SUA SA) while removing noise lines.
- Test 3: Extract amount when formatted without currency units (e.g., "Tong cong: 80.000").
- Test 4: Extract totals from Vietnamese VAT electronic invoices (HOA DON GTGT NQ).
- Test 5: Parse multi-line labels where the descriptor and value occupy adjacent lines.
- Test 6: Handle comma and dot thousand separators reliably.
- Test 7: Recognize explicit currency indicators (d, VND).
- Test 8: Fallback heuristic identifying maximum monetary values when explicit total keywords are absent.
- Test 9: Filter noise phrases such as "Please Scan to share" and receipt reference numbers.

Test Results: 9/9 tests passed (0 failures).

---

## 5. SETUP AND INSTALLATION GUIDE

### Prerequisites
- Flutter SDK version 3.2.0 or higher
- Dart SDK version 3.2.0 or higher
- Android SDK (API level 24 or higher, compileSdk 34)
- Physical Android device with USB debugging enabled, or an Android Emulator

### Installation Steps

1. Clone the repository:
```bash
git clone https://github.com/vothanhlong16072005-creator/VoThanhLong_23IT147_Project3_OCR_Expense_Tracker.git
cd VoThanhLong_23IT147_Project3_OCR_Expense_Tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Isar Database code (if required):
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Verify code quality and execute the automated test suite:
```bash
flutter analyze
flutter test test/ocr_service_test.dart
```

5. Run the application:
```bash
flutter run
```

---

## 6. PROJECT DIRECTORY STRUCTURE

```
ocr_expense_tracker/
|-- lib/
|   |-- main.dart                      # App entry point, Theme configuration, ProviderScope
|   |-- models/
|   |   |-- transaction.dart           # Isar entity model and ExpenseCategory enumeration
|   |-- providers/
|   |   |-- transaction_provider.dart  # Riverpod StateNotifier and auto-seeding demo logic
|   |-- screens/
|   |   |-- dashboard_screen.dart      # Main dashboard with charts, filters, and detail pop-up
|   |   |-- camera_screen.dart         # OCR camera viewfinder and gallery picker entry
|   |   |-- review_screen.dart         # OCR review and field verification screen
|   |-- services/
|   |   |-- ocr_service.dart           # ML Kit parsing regex and category heuristics
|   |   |-- isar_service.dart          # Local database CRUD abstraction
|   |-- utils/
|   |   |-- export_service.dart        # CSV ledger and printable HTML/PDF statement exporter
|   |-- widgets/
|       |-- charts/                    # Animated donut chart and interactive bar chart
|       |-- add_manual_expense_sheet.dart
|-- test/
|   |-- ocr_service_test.dart          # 9 Unit test cases verifying OCR heuristics
|-- docs/
    |-- sample_receipts.html           # 5 Realistic thermal receipt samples for OCR demonstration
```
