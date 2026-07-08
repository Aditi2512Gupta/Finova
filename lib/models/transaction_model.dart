import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String categoryId;
  final String walletId;
  final DateTime date;
  final String note;
  final bool isRecurring;
  final String recurrence;
  final DateTime? nextOccurrence;
  final Timestamp createdAt;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.walletId,
    required this.date,
    required this.note,
    required this.isRecurring,
    required this.recurrence,
    required this.nextOccurrence,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "amount": amount,
      "type": type,
      "categoryId": categoryId,
      "walletId": walletId,
      "date": Timestamp.fromDate(date),
      "note": note,
      "isRecurring": isRecurring,
      "recurrence": recurrence,
      "nextOccurrence": nextOccurrence == null
          ? null
          : Timestamp.fromDate(nextOccurrence!),
      "createdAt": createdAt,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map["id"],
      title: map["title"],
      amount: (map["amount"] as num).toDouble(),
      type: map["type"],
      categoryId: map["categoryId"],
      walletId: map["walletId"],
      date: (map["date"] as Timestamp).toDate(),
      note: map["note"],
      isRecurring: map["isRecurring"] ?? false,
      recurrence: map["recurrence"] ?? "",
      nextOccurrence: map["nextOccurrence"] == null
          ? null
          : (map["nextOccurrence"] as Timestamp).toDate(),
      createdAt: map["createdAt"],
    );
  }
}
