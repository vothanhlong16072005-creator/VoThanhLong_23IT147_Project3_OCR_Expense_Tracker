import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/export_service.dart';
import '../widgets/charts/donut_chart.dart';
import '../widgets/charts/bar_chart.dart';
import '../widgets/add_manual_expense_sheet.dart';
import 'camera_screen.dart';
import 'review_screen.dart';

enum PeriodFilter { all, today, thisWeek, thisMonth }

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  PeriodFilter _selectedPeriod = PeriodFilter.all;
  DateTime? _selectedSpecificDate;
  ExpenseCategory? _selectedCategory;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Transaction> _filterTransactions(List<Transaction> source) {
    final now = DateTime.now();

    return source.where((tx) {
      // 1. Time / Date Filtering
      if (_selectedSpecificDate != null) {
        if (!_isSameDay(tx.date, _selectedSpecificDate!)) return false;
      } else {
        switch (_selectedPeriod) {
          case PeriodFilter.all:
            break;
          case PeriodFilter.today:
            if (!_isSameDay(tx.date, now)) return false;
            break;
          case PeriodFilter.thisWeek:
            final diff = now.difference(tx.date).inDays;
            if (diff < 0 || diff > 7) return false;
            break;
          case PeriodFilter.thisMonth:
            if (tx.date.year != now.year || tx.date.month != now.month) return false;
            break;
        }
      }

      // 2. Category Filtering
      if (_selectedCategory != null) {
        if (tx.category != _selectedCategory) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Receipt',
            toolbarColor: const Color(0xFF2563EB),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
          IOSUiSettings(
            title: 'Crop Receipt',
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
        ],
      );

      if (croppedFile != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewScreen(imagePath: croppedFile.path),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
    }
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Add Transaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),

              // Option 1: Camera Scan
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2563EB), size: 24),
                ),
                title: const Text('Scan Receipt (Camera)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: const Text('Take photo & extract details with AI OCR', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraScreen()));
                },
              ),
              const Divider(height: 12),

              // Option 2: Gallery
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: Color(0xFF16A34A), size: 24),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: const Text('Scan receipt from existing photos or screenshots', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery(context);
                },
              ),
              const Divider(height: 12),

              // Option 3: Manual Entry
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_note_outlined, color: Color(0xFF9333EA), size: 24),
                ),
                title: const Text('Manual Entry', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: const Text('Record custom expense without receipt', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                onTap: () {
                  Navigator.pop(ctx);
                  AddManualExpenseSheet.show(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportAndDataMenu(BuildContext context, List<Transaction> transactions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Reports & Data Tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),

              // Export Detailed CSV
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.table_chart_outlined, color: Color(0xFF2563EB), size: 24),
                ),
                title: const Text('Export Detailed CSV Statement', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: const Text('Complete ledger with summary headers & categories', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                onTap: () async {
                  Navigator.pop(ctx);
                  if (transactions.isNotEmpty) {
                    await ExportService.exportDetailedCsv(transactions);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No transaction records to export')),
                    );
                  }
                },
              ),
              const Divider(height: 12),

              // Print / PDF HTML Statement
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.print_outlined, color: Color(0xFF16A34A), size: 24),
                ),
                title: const Text('Print / View Statement (HTML / PDF)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: const Text('Generate bank-statement layout ready to print or save PDF', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                onTap: () async {
                  Navigator.pop(ctx);
                  if (transactions.isNotEmpty) {
                    await ExportService.exportPrintableHtmlStatement(transactions);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No transaction records to export')),
                    );
                  }
                },
              ),
              const Divider(height: 12),

              // Reset / Clean Data
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFEF4444), size: 24),
                ),
                title: const Text('Reset / Clear Transactions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFFEF4444))),
                subtitle: const Text('Clear all or restore clean demo records', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final action = await showDialog<String>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Manage Records'),
                      content: const Text('Choose whether to clear all records or reset to standard sample records for demonstration:'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, 'cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, 'clear'),
                          child: const Text('Clear All', style: TextStyle(color: Color(0xFFEF4444))),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dCtx, 'reset'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                          child: const Text('Reset to Sample Data', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  if (action == 'clear') {
                    await ref.read(transactionNotifierProvider.notifier).clearAllTransactions();
                  } else if (action == 'reset') {
                    await ref.read(transactionNotifierProvider.notifier).resetToSampleData();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header: Icon + Merchant Name
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: tx.category.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      tx.category.icon,
                      color: tx.category.color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.merchant ?? 'General Expense',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: tx.category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tx.category.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: tx.category.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Amount Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '-${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(tx.amount)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE11D48),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Transaction Info Details List
              _buildDetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: DateFormat('EEEE, dd/MM/yyyy').format(tx.date),
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),

              _buildDetailRow(
                icon: Icons.access_time_outlined,
                label: 'Time',
                value: DateFormat('HH:mm').format(tx.date),
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),

              _buildDetailRow(
                icon: Icons.tag_outlined,
                label: 'Transaction ID',
                value: '#${tx.id}',
              ),
              const Divider(height: 16, color: Color(0xFFF1F5F9)),

              _buildDetailRow(
                icon: Icons.receipt_outlined,
                label: 'Source',
                value: tx.imagePath != null ? 'Scanned Receipt (OCR)' : 'Manual Entry',
              ),

              const SizedBox(height: 24),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dCtx) => AlertDialog(
                            title: const Text('Delete Transaction'),
                            content: Text('Are you sure you want to delete "${tx.merchant}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(dCtx, true),
                                child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && context.mounted) {
                          Navigator.pop(ctx);
                          await ref.read(transactionNotifierProvider.notifier).removeTransaction(tx.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transaction deleted')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                      label: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final txState = ref.watch(transactionNotifierProvider);
    final categoryTotals = ref.watch(categoryTotalProvider);

    final allTransactions = (txState is AsyncData<List<Transaction>>) ? txState.value : <Transaction>[];
    final filteredTransactions = _filterTransactions(allTransactions);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Reports & Tools',
            onPressed: () => _showReportAndDataMenu(context, allTransactions),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: txState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_outlined, size: 54, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Transactions Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan a receipt or tap Add Expense to begin tracking',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddOptions(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Transaction'),
                    ),
                  ],
                ),
              ),
            );
          }

          final double totalSpent = transactions.fold(0.0, (sum, tx) => sum + tx.amount);
          final double filteredSpent = filteredTransactions.fold(0.0, (sum, tx) => sum + tx.amount);

          return CustomScrollView(
            slivers: [
              // Hero Outflow Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL OUTFLOW',
                              style: TextStyle(
                                color: Color(0xFFBFDBFE),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${transactions.length} Records',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(totalSpent),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Charts Cards Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Donut Chart Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Spending Breakdown',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 20),
                              Center(child: AnimatedDonutChart(dataMap: categoryTotals)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Interactive Bar Chart Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Last 7 Days Activity',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                  ),
                                  Text(
                                    _selectedSpecificDate != null
                                        ? 'Selected: ${DateFormat('dd/MM').format(_selectedSpecificDate!)}'
                                        : 'Tap bar to filter',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: _selectedSpecificDate != null ? FontWeight.w600 : FontWeight.w500,
                                      color: _selectedSpecificDate != null ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 185,
                                child: AnimatedBarChart(
                                  transactions: transactions,
                                  selectedDate: _selectedSpecificDate,
                                  onDateSelected: (date) {
                                    setState(() {
                                      _selectedSpecificDate = date;
                                      if (date != null) {
                                        _selectedPeriod = PeriodFilter.all; // Specific date takes priority
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Filter Controls Section
                      _buildFilterSection(transactions.length, filteredTransactions.length, filteredSpent),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Filtered Transactions List
              if (filteredTransactions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.filter_alt_off_outlined, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No transactions match this filter',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try selecting a different time range or category',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedPeriod = PeriodFilter.all;
                                _selectedSpecificDate = null;
                                _selectedCategory = null;
                              });
                            },
                            child: const Text('Reset All Filters'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = filteredTransactions[index];
                        return Dismissible(
                          key: Key('tx_${tx.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                          ),
                          confirmDismiss: (dir) async {
                            return await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Transaction'),
                                content: Text('Are you sure you want to remove "${tx.merchant}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (_) {
                            ref.read(transactionNotifierProvider.notifier).removeTransaction(tx.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transaction deleted')),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _showTransactionDetails(context, tx),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: tx.category.color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          tx.category.icon,
                                          color: tx.category.color,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.merchant ?? 'General Expense',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${DateFormat('dd/MM/yyyy').format(tx.date)} • ${tx.category.displayName}',
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '-${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(tx.amount)}',
                                            style: const TextStyle(
                                              color: Color(0xFFE11D48),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Icon(Icons.chevron_right, size: 16, color: Color(0xFFCBD5E1)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: filteredTransactions.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 84),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildFilterSection(int totalCount, int filteredCount, double filteredSpent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Time Period Filter Pills Row
        Row(
          children: [
            _buildPeriodChip('All', PeriodFilter.all),
            const SizedBox(width: 8),
            _buildPeriodChip('Today', PeriodFilter.today),
            const SizedBox(width: 8),
            _buildPeriodChip('This Week', PeriodFilter.thisWeek),
            const SizedBox(width: 8),
            _buildPeriodChip('This Month', PeriodFilter.thisMonth),
          ],
        ),

        // 2. Specific Date indicator banner (if bar clicked)
        if (_selectedSpecificDate != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event, size: 18, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Text(
                  'Filtered by day: ${DateFormat('dd/MM/yyyy').format(_selectedSpecificDate!)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpecificDate = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.close, size: 16, color: Color(0xFF1E40AF)),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // 3. Category Filter Chips (Horizontal Scroll)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildCategoryChip(
                label: 'All Categories',
                isSelected: _selectedCategory == null,
                icon: Icons.apps,
                color: const Color(0xFF2563EB),
                onTap: () => setState(() => _selectedCategory = null),
              ),
              ...ExpenseCategory.values.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildCategoryChip(
                    label: cat.displayName,
                    isSelected: _selectedCategory == cat,
                    icon: cat.icon,
                    color: cat.color,
                    onTap: () => setState(() => _selectedCategory = cat),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 4. Header title & active count/subtotal summary
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions ($filteredCount)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            Text(
              'Subtotal: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(filteredSpent)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String title, PeriodFilter filter) {
    final isSelected = _selectedSpecificDate == null && _selectedPeriod == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = filter;
            _selectedSpecificDate = null; // Clear day override
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
