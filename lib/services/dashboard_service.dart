import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import 'category_service.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CategoryService _categoryService = CategoryService();

  String get uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get walletCollection =>
      _firestore.collection('users').doc(uid).collection('wallets');

  CollectionReference<Map<String, dynamic>> get transactionCollection =>
      _firestore.collection('users').doc(uid).collection('transactions');

  Stream<double> getTotalBalance() {
    return walletCollection.snapshots().map((snapshot) {
      double total = 0;

      for (final doc in snapshot.docs) {
        total += WalletModel.fromMap(doc.data()).balance;
      }

      return total;
    });
  }

  Stream<double> getTotalIncome() {
    return transactionCollection.snapshots().map((snapshot) {
      double total = 0;

      for (final doc in snapshot.docs) {
        final transaction = TransactionModel.fromMap(doc.data());

        if (transaction.type == "Income") {
          total += transaction.amount;
        }
      }

      return total;
    });
  }

  Stream<double> getTotalExpense() {
    return transactionCollection.snapshots().map((snapshot) {
      double total = 0;

      for (final doc in snapshot.docs) {
        final transaction = TransactionModel.fromMap(doc.data());

        if (transaction.type == "Expense") {
          total += transaction.amount;
        }
      }

      return total;
    });
  }

  Future<Map<String, double>> getCategoryTotals() async {
    final categoryMap = await _categoryService.getCategoryMap();

    final snapshot = await transactionCollection.get();

    final Map<String, double> totals = {};

    for (final doc in snapshot.docs) {
      final transaction = TransactionModel.fromMap(doc.data());

      if (transaction.type != "Expense") continue;

      final categoryName = categoryMap[transaction.categoryId]?.name ?? "Other";

      totals.update(
        categoryName,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return totals;
  }
}
