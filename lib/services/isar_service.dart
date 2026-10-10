import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [TransactionSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // Create
  Future<void> saveTransaction(Transaction newTx) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.transactions.putSync(newTx));
  }

  // Read all
  Future<List<Transaction>> getAllTransactions() async {
    final isar = await db;
    return await isar.transactions.where().sortByDateDesc().findAll();
  }

  // Delete
  Future<void> deleteTransaction(int id) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.transactions.deleteSync(id));
  }
  
  // Clean all (For debugging)
  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }
}
