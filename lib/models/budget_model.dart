import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String categoryId;
  final double amount;
  final Timestamp createdAt;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "categoryId": categoryId,
      "amount": amount,
      "createdAt": createdAt,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map["id"],
      categoryId: map["categoryId"],
      amount: (map["amount"] as num).toDouble(),
      createdAt: map["createdAt"],
    );
  }
}
