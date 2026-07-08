import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
}
