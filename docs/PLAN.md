# PLAN.md - Implementation Strategy

## Phase 1: Foundation & Architecture (ecc-research-first)
1. **Initialize Flutter Project:** `flutter create ocr_expense_tracker`
2. **Dependencies:** `google_mlkit_text_recognition`, `camera`, `image_cropper`, `isar` (or `sqflite`), `flutter_riverpod` (or provider/bloc for state), `path_provider`.
3. **Architecture Setup:** Domain-Driven Design (DDD) or Feature-first folder structure. Define Models (Transaction, Category).

## Phase 2: Database & Storage Layer (persistent-memory)
1. **Schema Design:** Define `Transaction` entity with fields: id, amount, date, merchant, category, imagePath.
2. **Local DB Implementation:** Setup Isar/Sqflite CRUD operations.
3. **Image Storage:** Utility to save cropped images to local app directory.

## Phase 3: Core AI & Processing (ts-strict-engineering adapted for Dart)
1. **Camera UI:** Implement viewfinder with overlay/cropping.
2. **ML Kit Integration:** Pass cropped image to `TextRecognizer`.
3. **Regex Parser:** Build robust Regex to extract:
   - Date: `r'\b(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2,4})\b'`
   - Amount: `r'(?:\d{1,3}(?:[.,]\d{3})*|\d+)(?:[.,]\d{1,2})?\s*(?:VND|đ|d)'`
   - Merchant: Heuristics based on text block position (e.g., top lines).
4. **Review Screen:** UI to allow users to verify and edit parsed data before DB insertion.

## Phase 4: UI & Custom Visualization (ui-ux-pro-max & impeccable-design)
1. **Dashboard UI:** List recent transactions, filter by category/week.
2. **Charts (`CustomPainter`):**
   - `DonutChartPainter`: Calculate arcs based on category totals. Add sweep animation.
   - `BarChartPainter`: Draw axes and bars for weekly spending. Add vertical grow animation.
3. **Dark Mode & Polish:** Enforce premium design, consistent color palette, fluid typography.

## Phase 5: Finalization & Deliverables
1. **Testing:** Verify parsing accuracy, UI responsiveness, and offline capabilities.
2. **APK Build:** Generate `app-release.apk`.
3. **Documentation:** Write `README.md` with setup instructions.
4. **Report:** Compile PDF report based on template.
