import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/isar_service.dart';

// 1. Isar Service Provider
final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

// 2. Transaction List StateNotifier
class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final IsarService _isarService;

  TransactionNotifier(this._isarService) : super(const AsyncValue.loading()) {
    loadTransactions(autoSeedIfEmpty: true);
  }

  Future<void> loadTransactions({bool autoSeedIfEmpty = false}) async {
    try {
      final transactions = await _isarService.getAllTransactions();
      if (transactions.isEmpty && autoSeedIfEmpty) {
        await seedDemoTransactions();
        return;
      }
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTransaction(Transaction tx) async {
    await _isarService.saveTransaction(tx);
    await loadTransactions();
  }

  Future<void> removeTransaction(int id) async {
    await _isarService.deleteTransaction(id);
    await loadTransactions();
  }

  /// Populate realistic, multi-category transactions across the past 7 days + current month
  Future<void> seedDemoTransactions() async {
    final now = DateTime.now();

    final demoData = [
      // Today (Day 0) - CGV Movie Ticket (Entertainment) & Phuc Long Tea
      Transaction()
        ..amount = 335000
        ..date = DateTime(now.year, now.month, now.day, 19, 30)
        ..merchant = 'CGV Cinema'
        ..category = ExpenseCategory.entertainment,
      Transaction()
        ..amount = 65000
        ..date = DateTime(now.year, now.month, now.day, 11, 15)
        ..merchant = 'Phuc Long Coffee & Tea'
        ..category = ExpenseCategory.food,

      // Yesterday (Day 1) - WinMart Groceries
      Transaction()
        ..amount = 185000
        ..date = DateTime(now.year, now.month, now.day - 1, 18, 45)
        ..merchant = 'WinMart Supermarket'
        ..category = ExpenseCategory.food,

      // Day 2 - Electronics & Gear
      Transaction()
        ..amount = 450000
        ..date = DateTime(now.year, now.month, now.day - 2, 14, 20)
        ..merchant = 'FPT Shop Accessories'
        ..category = ExpenseCategory.gear,

      // Day 3 - Coffee & Transportation
      Transaction()
        ..amount = 85000
        ..date = DateTime(now.year, now.month, now.day - 3, 9, 30)
        ..merchant = 'Highlands Coffee'
        ..category = ExpenseCategory.food,
      Transaction()
        ..amount = 42000
        ..date = DateTime(now.year, now.month, now.day - 3, 17, 10)
        ..merchant = 'GrabBike Ride'
        ..category = ExpenseCategory.travel,

      // Day 4 - Bookstore & Study
      Transaction()
        ..amount = 249000
        ..date = DateTime(now.year, now.month, now.day - 4, 15, 0)
        ..merchant = 'Fahasa Bookstore'
        ..category = ExpenseCategory.study,

      // Day 5 - Ride
      Transaction()
        ..amount = 120000
        ..date = DateTime(now.year, now.month, now.day - 5, 8, 40)
        ..merchant = 'Be Car Transportation'
        ..category = ExpenseCategory.travel,

      // Day 6 - Dining & Gaming
      Transaction()
        ..amount = 155000
        ..date = DateTime(now.year, now.month, now.day - 6, 12, 30)
        ..merchant = 'Lotteria Fast Food'
        ..category = ExpenseCategory.food,
      Transaction()
        ..amount = 220000
        ..date = DateTime(now.year, now.month, now.day - 6, 20, 15)
        ..merchant = 'Steam Game Store'
        ..category = ExpenseCategory.entertainment,

      // Earlier this month
      Transaction()
        ..amount = 350000
        ..date = DateTime(now.year, now.month, 1, 10, 0)
        ..merchant = 'Coursera IT Certification'
        ..category = ExpenseCategory.study,
      Transaction()
        ..amount = 95000
        ..date = DateTime(now.year, now.month, 2, 16, 20)
        ..merchant = 'Office Supplies & Stationery'
        ..category = ExpenseCategory.other,
    ];

    for (final tx in demoData) {
      await _isarService.saveTransaction(tx);
    }
    await loadTransactions(autoSeedIfEmpty: false);
  }

  Future<void> clearAllTransactions() async {
    final all = await _isarService.getAllTransactions();
    for (final tx in all) {
      await _isarService.deleteTransaction(tx.id);
    }
    await loadTransactions(autoSeedIfEmpty: false);
  }

  Future<void> resetToSampleData() async {
    await clearAllTransactions();
    await seedDemoTransactions();
  }
}

// 3. Provider expose StateNotifier
final transactionNotifierProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  final isarService = ref.read(isarServiceProvider);
  return TransactionNotifier(isarService);
});

// 4. Provider for Donut Chart (grouped by category)
final categoryTotalProvider = Provider<Map<ExpenseCategory, double>>((ref) {
  final txState = ref.watch(transactionNotifierProvider);
  final map = <ExpenseCategory, double>{};
  
  if (txState is AsyncData<List<Transaction>>) {
    for (var tx in txState.value) {
      map[tx.category] = (map[tx.category] ?? 0) + tx.amount;
    }
  }
  return map;
});
