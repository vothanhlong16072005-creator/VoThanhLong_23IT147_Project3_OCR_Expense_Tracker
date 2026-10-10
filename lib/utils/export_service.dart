import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class ExportService {
  /// Export Comprehensive Financial CSV Report
  static Future<void> exportDetailedCsv(List<Transaction> transactions) async {
    if (transactions.isEmpty) return;

    final now = DateTime.now();
    final double totalSpent = transactions.fold(0.0, (sum, tx) => sum + tx.amount);
    final double avgSpent = totalSpent / transactions.length;

    // Category breakdown
    final Map<ExpenseCategory, double> catTotals = {};
    for (var tx in transactions) {
      catTotals[tx.category] = (catTotals[tx.category] ?? 0) + tx.amount;
    }

    final sb = StringBuffer();
    sb.writeln('========================================================================');
    sb.writeln('EXPENSE TRACKER - FINANCIAL STATEMENT & LEDGER');
    sb.writeln('========================================================================');
    sb.writeln('Generated Date,${DateFormat('dd/MM/yyyy HH:mm').format(now)}');
    sb.writeln('Reporting Month,${DateFormat('MM/yyyy').format(now)}');
    sb.writeln('Total Transactions,${transactions.length}');
    sb.writeln('Total Outflow (VND),${totalSpent.toInt()}');
    sb.writeln('Average Outflow (VND),${avgSpent.toInt()}');
    sb.writeln('');

    sb.writeln('CATEGORY BREAKDOWN SUMMARY');
    sb.writeln('Category,Total Outflow (VND),Percentage');
    for (var entry in catTotals.entries) {
      final pct = (entry.value / totalSpent * 100).toStringAsFixed(1);
      sb.writeln('${entry.key.displayName},${entry.value.toInt()},$pct%');
    }
    sb.writeln('');

    sb.writeln('DETAILED TRANSACTION LEDGER');
    sb.writeln('No.,Date,Merchant / Business,Category,Amount (VND),Formatted Amount');
    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final dateStr = DateFormat('dd/MM/yyyy').format(tx.date);
      final merchantStr = tx.merchant?.replaceAll(',', ' ') ?? 'General';
      final formatted = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(tx.amount);
      sb.writeln('${i + 1},$dateStr,$merchantStr,${tx.category.displayName},${tx.amount.toInt()},"$formatted"');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Expense_Statement_${DateFormat('MM_yyyy').format(now)}_${now.millisecondsSinceEpoch}.csv');
    await file.writeAsString(sb.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Expense Tracker Detailed Statement (${DateFormat('MM/yyyy').format(now)})',
    );
  }

  /// Export Printable HTML / PDF Statement
  static Future<void> exportPrintableHtmlStatement(List<Transaction> transactions) async {
    if (transactions.isEmpty) return;

    final now = DateTime.now();
    final double totalSpent = transactions.fold(0.0, (sum, tx) => sum + tx.amount);
    final String monthStr = DateFormat('MM/yyyy').format(now);
    final String generatedDateStr = DateFormat('dd/MM/yyyy HH:mm').format(now);

    final Map<ExpenseCategory, double> catTotals = {};
    for (var tx in transactions) {
      catTotals[tx.category] = (catTotals[tx.category] ?? 0) + tx.amount;
    }

    final html = StringBuffer();
    html.writeln('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Financial Statement - $monthStr</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; margin: 40px; color: #0f172a; background: #fff; }
    .header { border-bottom: 2px solid #2563eb; padding-bottom: 16px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end; }
    h1 { color: #1e40af; margin: 0 0 4px; font-size: 24px; }
    .subtitle { color: #64748b; font-size: 14px; margin: 0; }
    .summary-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 28px; }
    .card { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 14px; }
    .card-label { font-size: 12px; color: #64748b; font-weight: 600; text-transform: uppercase; }
    .card-value { font-size: 20px; font-weight: 800; color: #0f172a; margin-top: 4px; }
    table { width: 100%; border-collapse: collapse; margin-top: 12px; font-size: 13px; }
    th { background: #f1f5f9; text-align: left; padding: 10px 12px; color: #475569; font-weight: 600; border-bottom: 1px solid #cbd5e1; }
    td { padding: 10px 12px; border-bottom: 1px solid #f1f5f9; }
    tr:nth-child(even) { background: #fafafa; }
    .amount { text-align: right; font-weight: 700; color: #e11d48; }
    .badge { display: inline-block; padding: 3px 8px; border-radius: 6px; font-size: 11px; font-weight: 600; background: #e0f2fe; color: #0369a1; }
    .footer { margin-top: 40px; display: flex; justify-content: space-between; font-size: 13px; color: #64748b; border-top: 1px dashed #cbd5e1; padding-top: 20px; }
    .sign-box { text-align: center; width: 200px; }
    .sign-line { margin-top: 60px; border-top: 1px solid #94a3b8; }
    @media print { body { margin: 20px; } button { display: none; } }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1>EXPENSE TRACKER FINANCIAL STATEMENT</h1>
      <p class="subtitle">Statement Period: Month $monthStr • Generated on $generatedDateStr</p>
    </div>
    <button onclick="window.print()" style="padding: 8px 16px; background: #2563eb; color: #fff; border: none; border-radius: 6px; cursor: pointer; font-weight: 600;">Print / Save PDF</button>
  </div>

  <div class="summary-grid">
    <div class="card">
      <div class="card-label">Total Outflow</div>
      <div class="card-value" style="color: #e11d48;">${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(totalSpent)}</div>
    </div>
    <div class="card">
      <div class="card-label">Total Transactions</div>
      <div class="card-value">${transactions.length} records</div>
    </div>
    <div class="card">
      <div class="card-label">Average Spending</div>
      <div class="card-value">${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(totalSpent / transactions.length)}</div>
    </div>
  </div>

  <h3 style="margin: 20px 0 8px; font-size: 16px;">Category Distribution</h3>
  <table>
    <thead>
      <tr>
        <th>Category</th>
        <th style="text-align: right;">Amount (VND)</th>
        <th style="text-align: right;">Share</th>
      </tr>
    </thead>
    <tbody>''');

    for (var entry in catTotals.entries) {
      final pct = (entry.value / totalSpent * 100).toStringAsFixed(1);
      html.writeln('''
      <tr>
        <td><strong>${entry.key.displayName}</strong></td>
        <td style="text-align: right; font-weight: 600;">${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(entry.value)}</td>
        <td style="text-align: right;">$pct%</td>
      </tr>''');
    }

    html.writeln('''
    </tbody>
  </table>

  <h3 style="margin: 28px 0 8px; font-size: 16px;">Transaction Ledger</h3>
  <table>
    <thead>
      <tr>
        <th style="width: 40px;">No.</th>
        <th style="width: 100px;">Date</th>
        <th>Merchant / Business</th>
        <th>Category</th>
        <th style="text-align: right;">Amount</th>
      </tr>
    </thead>
    <tbody>''');

    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      html.writeln('''
      <tr>
        <td>${i + 1}</td>
        <td>${DateFormat('dd/MM/yyyy').format(tx.date)}</td>
        <td><strong>${tx.merchant ?? 'General'}</strong></td>
        <td><span class="badge">${tx.category.displayName}</span></td>
        <td class="amount">-${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(tx.amount)}</td>
      </tr>''');
    }

    html.writeln('''
    </tbody>
  </table>

  <div class="footer">
    <div>OCR Expense Tracker System • Cross-Platform Mobile Development</div>
    <div class="sign-box">
      <div>Report Sign-off</div>
      <div class="sign-line"></div>
    </div>
  </div>
</body>
</html>''');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Financial_Statement_${DateFormat('MM_yyyy').format(now)}_${now.millisecondsSinceEpoch}.html');
    await file.writeAsString(html.toString());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Printable Financial Statement ($monthStr)',
    );
  }
}
