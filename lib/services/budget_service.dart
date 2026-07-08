import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get budgetDoc => _firestore
      .collection("users")
      .doc(uid)
      .collection("settings")
      .doc("budget");

  Stream<double> getBudget() {
    return budgetDoc.snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return 30000; // Default monthly budget
      }

      return BudgetModel.fromMap(doc.data()!).amount;
    });
  }

  CollectionReference<Map<String, dynamic>> get categoryBudgetCollection =>
      _firestore.collection("users").doc(uid).collection("category_budgets");

  Stream<Map<String, BudgetModel>> getCategoryBudgets() {
    return categoryBudgetCollection.snapshots().map((snapshot) {
      final map = <String, BudgetModel>{};

      for (final doc in snapshot.docs) {
        final budget = BudgetModel.fromMap(doc.data());
        map[budget.categoryId] = budget;
      }

      return map;
    });
  }

  Future<void> saveBudget(double amount) async {
    final budget = BudgetModel(
      id: "budget",
      categoryId: "overall",
      amount: amount,
      createdAt: Timestamp.now(),
    );

    await budgetDoc.set(budget.toMap());
  }

  Future<void> saveCategoryBudget({
    required String categoryId,
    required double amount,
  }) async {
    final budget = BudgetModel(
      id: categoryId,
      categoryId: categoryId,
      amount: amount,
      createdAt: Timestamp.now(),
    );

    await categoryBudgetCollection.doc(categoryId).set(budget.toMap());
  }

  Future<bool> hasAlertBeenShown({
    required String monthKey,
    required String categoryId,
    required String alertType,
  }) async {
    final doc = await _firestore
        .collection("users")
        .doc(uid)
        .collection("budget_alerts")
        .doc(monthKey)
        .get();

    if (!doc.exists) return false;

    final data = doc.data();

    if (data == null) return false;

    if (!data.containsKey(categoryId)) return false;

    final categoryData = Map<String, dynamic>.from(data[categoryId]);

    return categoryData[alertType] == true;
  }

  Future<void> markAlertAsShown({
    required String monthKey,
    required String categoryId,
    required String alertType,
  }) async {
    await _firestore
        .collection("users")
        .doc(uid)
        .collection("budget_alerts")
        .doc(monthKey)
        .set({
          categoryId: {alertType: true},
        }, SetOptions(merge: true));
  }
}
