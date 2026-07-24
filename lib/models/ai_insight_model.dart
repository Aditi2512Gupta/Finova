import 'package:cloud_firestore/cloud_firestore.dart';

class AIInsightModel {
  final String insight;
  final Timestamp generatedAt;

  AIInsightModel({
    required this.insight,
    required this.generatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "insight": insight,
      "generatedAt": generatedAt,
    };
  }

  factory AIInsightModel.fromMap(Map<String, dynamic> map) {
    return AIInsightModel(
      insight: map["insight"] ?? "",
      generatedAt: map["generatedAt"] ?? Timestamp.now(),
    );
  }
}