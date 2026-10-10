import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../models/transaction.dart';
import '../services/ocr_service.dart';
import '../providers/transaction_provider.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String imagePath;
  const ReviewScreen({super.key, required this.imagePath});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final OcrService _ocrService = OcrService();
  bool _isLoading = true;
  ParsedReceipt? _receipt;
  
  late TextEditingController _merchantCtrl;
  late TextEditingController _amountCtrl;
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  bool _showRawText = false;

  @override
  void initState() {
    super.initState();
    _merchantCtrl = TextEditingController();
    _amountCtrl = TextEditingController();
    _processImage();
  }

  Future<void> _processImage() async {
    final result = await _ocrService.processImage(widget.imagePath);
    setState(() {
      _receipt = result;
      _merchantCtrl.text = result.merchant;
      _amountCtrl.text = result.amount > 0 
          ? (result.amount == result.amount.toInt() ? result.amount.toInt().toString() : result.amount.toString())
          : '';
      _selectedCategory = result.category;
      _selectedDate = result.date;
      _isLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTransaction() {
    final rawAmountStr = _amountCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    final double finalAmount = double.tryParse(rawAmountStr) ?? 0.0;
    
    if (finalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid expense amount')),
      );
      return;
    }

    final newTx = Transaction()
      ..amount = finalAmount
      ..date = _selectedDate
      ..merchant = _merchantCtrl.text.trim().isEmpty ? 'Receipt Expense' : _merchantCtrl.text.trim()
      ..category = _selectedCategory
      ..imagePath = widget.imagePath;

    ref.read(transactionNotifierProvider.notifier).addTransaction(newTx);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved: ${newTx.merchant} (${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(finalAmount)})'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    _merchantCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Review & Confirm'),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'AI ML Kit is extracting receipt details...',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Receipt Image Preview Card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(
                      File(widget.imagePath),
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // AI Status Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: (_receipt?.amount ?? 0) > 0 
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_receipt?.amount ?? 0) > 0 ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          (_receipt?.amount ?? 0) > 0 ? Icons.check_circle_outline : Icons.info_outline,
                          color: (_receipt?.amount ?? 0) > 0 ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            (_receipt?.amount ?? 0) > 0
                                ? 'Details successfully extracted by AI OCR'
                                : 'Amount not detected clearly. Please verify or type below.',
                            style: TextStyle(
                              color: (_receipt?.amount ?? 0) > 0 ? const Color(0xFF166534) : const Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Merchant Field
                  TextField(
                    controller: _merchantCtrl,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      labelText: 'Merchant / Business Name',
                      prefixIcon: Icon(Icons.storefront_outlined, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount Field
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      labelText: 'Total Amount (VND) *',
                      prefixIcon: Icon(Icons.payments_outlined, color: Color(0xFF64748B)),
                      suffixText: '₫',
                      suffixStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker Tile
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF64748B)),
                          const SizedBox(width: 12),
                          const Text(
                            'Transaction Date:',
                            style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined, color: Color(0xFF64748B)),
                    ),
                    items: ExpenseCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 18, color: cat.color),
                            const SizedBox(width: 10),
                            Text(cat.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Raw OCR Text Viewer
                  TextButton.icon(
                    onPressed: () => setState(() => _showRawText = !_showRawText),
                    icon: Icon(_showRawText ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                    label: Text(_showRawText ? 'Hide extracted raw OCR text' : 'View extracted raw OCR text'),
                  ),
                  if (_showRawText)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _receipt?.rawText ?? '',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF475569)),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.save_outlined, size: 20),
                    label: const Text(
                      'SAVE TRANSACTION',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    onPressed: _saveTransaction,
                  ),
                ],
              ),
            ),
    );
  }
}
