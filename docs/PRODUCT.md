# PRODUCT.md - OCR Expense Tracker & Receipt Parser

## 1. Project Overview
* **Title:** Mini-Project 3: OCR Expense Tracker & Receipt Parser
* **Tech Stack:** Flutter 3.x, Dart 3, Google ML Kit, SQLite/Isar.
* **Goal:** A personal finance app with offline, on-device AI to parse receipts, extract totals/dates/merchants via Regex, and visualize data using `CustomPainter`.

## 2. Core Features (The "What")
1. **Camera & Cropping:**
   * Live viewfinder, flash toggle, tap-to-focus.
   * Image framing / crop overlay.
2. **On-Device Text Recognition (Google ML Kit):**
   * Offline text extraction (< 100ms).
   * Regex heuristics to parse:
     * Totals (e.g., 150,000 VND, 150.000 đ).
     * Dates (DD/MM/YYYY).
     * Merchant names.
   * Interactive review screen for manual edits.
3. **Local Database (Isar / Sqflite):**
   * Categories: Food, Study, Travel, Gear, Entertainment.
   * Caching receipt thumbnails in local storage.
4. **Custom Visualization (`CustomPainter`):**
   * Animated category donut/pie chart.
   * Weekly spending bar chart.
   * *Constraint:* NO third-party chart libraries allowed.

## 3. Deliverables Checklist
- [ ] Source Code (Flutter 3.x, clean architecture).
- [ ] Live Demo (Release APK via GitHub Releases / Drive) + 2-3 min Video Demo.
- [ ] PDF Report (2-4 pages, using official template).

## 4. UI/UX Guidelines (ui-ux-pro-max)
* **Fluid Layouts:** Responsive across mobile viewports.
* **Aesthetics:** Modern, clean, dark mode support, micro-animations for charts.
* **Accessibility:** High contrast text, touch targets >= 48dp.
