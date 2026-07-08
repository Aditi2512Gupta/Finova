import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';
import 'notification_service.dart';
import 'budget_service.dart';
import 'category_service.dart';
import 'notification_service.dart';
import 'wallet_service.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BudgetService _budgetService = BudgetService();
  final CategoryService _categoryService = CategoryService();
  final WalletService _walletService = WalletService();

  String get uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get transactionCollection =>
      _firestore.collection('users').doc(uid).collection('transactions');

  DocumentReference<Map<String, dynamic>> walletDoc(String walletId) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('wallets')
          .doc(walletId);

  // ============================
  // Add Transaction (Firestore Transaction)
  // ============================
  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestore.runTransaction((firebaseTransaction) async {
      final walletRef = walletDoc(transaction.walletId);

      final walletSnapshot = await firebaseTransaction.get(walletRef);

      if (!walletSnapshot.exists) {
        throw Exception("Wallet not found.");
      }

      final walletData = walletSnapshot.data()!;

      double currentBalance = (walletData["balance"] as num).toDouble();

      double updatedBalance;

      if (transaction.type == "Income") {
        updatedBalance = currentBalance + transaction.amount;
      } else {
        updatedBalance = currentBalance - transaction.amount;
      }

      firebaseTransaction.set(
        transactionCollection.doc(transaction.id),
        transaction.toMap(),
      );

      firebaseTransaction.update(walletRef, {"balance": updatedBalance});
    });
    await _checkBudgetAlert(transaction);
    await _checkLowWalletBalance(transaction);
  }

  // ============================
  // Read Transactions
  // ============================
  Stream<List<TransactionModel>> getTransactions() {
    return transactionCollection
        .orderBy("date", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // ============================
  // Update Transaction (Firestore Transaction)
  // ============================
  Future<void> updateTransaction({
    required TransactionModel oldTransaction,
    required TransactionModel newTransaction,
  }) async {
    await _firestore.runTransaction((firebaseTransaction) async {
      final oldWalletRef = walletDoc(oldTransaction.walletId);
      final newWalletRef = walletDoc(newTransaction.walletId);

      final oldWalletSnapshot = await firebaseTransaction.get(oldWalletRef);

      if (!oldWalletSnapshot.exists) {
        throw Exception("Old wallet not found.");
      }

      double oldWalletBalance = (oldWalletSnapshot.data()!["balance"] as num)
          .toDouble();

      // Restore old transaction effect
      if (oldTransaction.type == "Income") {
        oldWalletBalance -= oldTransaction.amount;
      } else {
        oldWalletBalance += oldTransaction.amount;
      }

      if (oldTransaction.walletId == newTransaction.walletId) {
        // Same wallet
        if (newTransaction.type == "Income") {
          oldWalletBalance += newTransaction.amount;
        } else {
          oldWalletBalance -= newTransaction.amount;
        }

        firebaseTransaction.update(oldWalletRef, {"balance": oldWalletBalance});
      } else {
        // Different wallet
        firebaseTransaction.update(oldWalletRef, {"balance": oldWalletBalance});

        final newWalletSnapshot = await firebaseTransaction.get(newWalletRef);

        if (!newWalletSnapshot.exists) {
          throw Exception("New wallet not found.");
        }

        double newWalletBalance = (newWalletSnapshot.data()!["balance"] as num)
            .toDouble();

        if (newTransaction.type == "Income") {
          newWalletBalance += newTransaction.amount;
        } else {
          newWalletBalance -= newTransaction.amount;
        }

        firebaseTransaction.update(newWalletRef, {"balance": newWalletBalance});
      }

      firebaseTransaction.update(
        transactionCollection.doc(newTransaction.id),
        newTransaction.toMap(),
      );
    });
  }

  // ============================
  // Delete Transaction (Firestore Transaction)
  // ============================
  Future<void> deleteTransaction(TransactionModel transaction) async {
    await _firestore.runTransaction((firebaseTransaction) async {
      final walletRef = walletDoc(transaction.walletId);

      final walletSnapshot = await firebaseTransaction.get(walletRef);

      if (walletSnapshot.exists) {
        final walletData = walletSnapshot.data()!;

        double currentBalance = (walletData["balance"] as num).toDouble();

        double updatedBalance;

        if (transaction.type == "Income") {
          updatedBalance = currentBalance - transaction.amount;
        } else {
          updatedBalance = currentBalance + transaction.amount;
        }

        firebaseTransaction.update(walletRef, {"balance": updatedBalance});
      }

      firebaseTransaction.delete(transactionCollection.doc(transaction.id));
    });
  }

  // ============================
  // Process Recurring Transactions
  // ============================
  DateTime calculateNextOccurrence(DateTime current, String recurrence) {
    switch (recurrence) {
      case "Daily":
        return current.add(const Duration(days: 1));
      case "Weekly":
        return current.add(const Duration(days: 7));
      case "Monthly":
        return DateTime(current.year, current.month + 1, current.day);
      case "Yearly":
        return DateTime(current.year + 1, current.month, current.day);
      default:
        return current.add(const Duration(days: 30));
    }
  }

  Future<void> _checkBudgetAlert(TransactionModel transaction) async {
    // Ignore income
    if (transaction.type != "Expense") return;

    final categoryBudgets = await _budgetService.getCategoryBudgets().first;

    final budget = categoryBudgets[transaction.categoryId];

    if (budget == null) return;

    final transactions = await getTransactions().first;

    double spent = 0;

    final now = DateTime.now();

    for (final t in transactions) {
      if (t.type == "Expense" &&
          t.categoryId == transaction.categoryId &&
          t.date.year == now.year &&
          t.date.month == now.month) {
        spent += t.amount;
      }
    }

    final percent = spent / budget.amount;

    final monthKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final category = (await _categoryService
        .getCategoryMap())[transaction.categoryId];

    final categoryName = category?.name ?? "Category";

    // --------------------------
    // 80%
    // --------------------------

    if (percent >= 0.8 && percent < 1.0) {
      final shown = await _budgetService.hasAlertBeenShown(
        monthKey: monthKey,
        categoryId: transaction.categoryId,
        alertType: "eighty",
      );

      if (!shown) {
        await NotificationService.instance.showBudget80Percent(
          category: categoryName,
        );

        await _budgetService.markAlertAsShown(
          monthKey: monthKey,
          categoryId: transaction.categoryId,
          alertType: "eighty",
        );
      }
    }

    // --------------------------
    // 100%
    // --------------------------

    if (percent >= 1.0) {
      final shown = await _budgetService.hasAlertBeenShown(
        monthKey: monthKey,
        categoryId: transaction.categoryId,
        alertType: "hundred",
      );

      if (!shown) {
        await NotificationService.instance.showBudgetReached(
          category: categoryName,
        );

        await _budgetService.markAlertAsShown(
          monthKey: monthKey,
          categoryId: transaction.categoryId,
          alertType: "hundred",
        );
      }
    }

    // --------------------------
    // Exceeded
    // --------------------------

    if (spent > budget.amount) {
      final shown = await _budgetService.hasAlertBeenShown(
        monthKey: monthKey,
        categoryId: transaction.categoryId,
        alertType: "exceeded",
      );

      if (!shown) {
        await NotificationService.instance.showBudgetExceeded(
          category: categoryName,
          exceededAmount: spent - budget.amount,
        );

        await _budgetService.markAlertAsShown(
          monthKey: monthKey,
          categoryId: transaction.categoryId,
          alertType: "exceeded",
        );
      }
    }
  }

  Future<void> _checkLowWalletBalance(TransactionModel transaction) async {
    if (transaction.type != "Expense") return;

    final wallet = await _firestore
        .collection("users")
        .doc(uid)
        .collection("wallets")
        .doc(transaction.walletId)
        .get();

    if (!wallet.exists) return;

    final data = wallet.data()!;

    final balance = (data["balance"] as num).toDouble();

    final alreadyShown = await _walletService.hasLowBalanceAlertShown(
      transaction.walletId,
    );

    if (balance <= 1000) {
      if (!alreadyShown) {
        await NotificationService.instance.showLowWalletBalance(
          walletName: data["name"],
          balance: balance,
        );

        await _walletService.setLowBalanceAlertShown(
          walletId: transaction.walletId,
          shown: true,
        );
      }
    } else {
      // Wallet recovered above threshold
      if (alreadyShown) {
        await _walletService.setLowBalanceAlertShown(
          walletId: transaction.walletId,
          shown: false,
        );
      }
    }
  }

  Future<void> processRecurringTransactions() async {
    if (_auth.currentUser == null) {
      return;
    }
    final now = DateTime.now();
    try {
      final transactions = await getTransactions().first;
      for (var t in transactions) {
        while (t.isRecurring &&
            t.nextOccurrence != null &&
            !t.nextOccurrence!.isAfter(now)) {
          // 1. Create a copy transaction representing the payment event
          final currentOccurrence = t.nextOccurrence!;
          final newId = _firestore.collection('users').doc().id;
          final paymentEvent = TransactionModel(
            id: newId,
            title: t.title,
            amount: t.amount,
            type: t.type,
            categoryId: t.categoryId,
            walletId: t.walletId,
            date: currentOccurrence,
            note: "Automatic payment for recurring transaction: ${t.title}",
            isRecurring: false,
            recurrence: "",
            nextOccurrence: null,
            createdAt: Timestamp.now(),
          );

          final updatedNext = calculateNextOccurrence(
            currentOccurrence,
            t.recurrence,
          );
          final updatedParent = TransactionModel(
            id: t.id,
            title: t.title,
            amount: t.amount,
            type: t.type,
            categoryId: t.categoryId,
            walletId: t.walletId,
            date: t.date,
            note: t.note,
            isRecurring: true,
            recurrence: t.recurrence,
            nextOccurrence: updatedNext,
            createdAt: t.createdAt,
          );

          // Update parent first
          await transactionCollection.doc(t.id).update(updatedParent.toMap());
          t = updatedParent;

          /// Check duplicate
          final existing = await transactionCollection
              .where(
                "note",
                isEqualTo:
                    "Automatic payment for recurring transaction: ${t.title}",
              )
              .where("date", isEqualTo: Timestamp.fromDate(currentOccurrence))
              .limit(1)
              .get();

          if (existing.docs.isEmpty) {
            await addTransaction(paymentEvent);
          }
          await NotificationService.instance.showRecurringTransaction(
            title: paymentEvent.title,
            amount: paymentEvent.amount,
          );
        }
      }
    } catch (e) {
      print("Recurring transaction engine error: $e");
    }
  }

  Future<void> checkUpcomingRecurringReminders() async {
    final now = DateTime.now();

    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final transactions = await getTransactions().first;

    for (final t in transactions) {
      if (!t.isRecurring || t.nextOccurrence == null) {
        continue;
      }

      final next = t.nextOccurrence!;

      if (next.year == tomorrow.year &&
          next.month == tomorrow.month &&
          next.day == tomorrow.day) {
        await NotificationService.instance.showUpcomingRecurringReminder(
          title: t.title,
          amount: t.amount,
        );
      }
    }
  }
}
