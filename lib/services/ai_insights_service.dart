import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ai_insight_model.dart';
import 'dashboard_service.dart';
import 'gemini_service.dart';

class AIInsightsService {
  final GeminiService _gemini = GeminiService();
  final DashboardService _dashboardService = DashboardService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _insightDoc => _firestore
      .collection("users")
      .doc(uid)
      .collection("ai")
      .doc("monthly_insight");

  Future<String> getInsights() async {
    final snapshot = await _insightDoc.get();

    if (snapshot.exists) {
      final model = AIInsightModel.fromMap(snapshot.data()!);

      final generated = model.generatedAt.toDate();

      if (DateTime.now().difference(generated).inHours < 24) {
        return model.insight;
      }
    }

    return await refreshInsights();
  }

  Future<String> refreshInsights() async {
    final income = await _dashboardService.getTotalIncome().first;

    final expense = await _dashboardService.getTotalExpense().first;

    final categoryTotals = await _dashboardService.getCategoryTotals();

    final savings = income - expense;

    final prompt = StringBuffer();

    prompt.writeln("""
You are Nova, the AI Financial Coach inside Finova.

Analyze the user's financial data.

Return EXACTLY 3 bullet points.

Rules:
- Never greet.
- Do not use headings.
- Do not use markdown.
- Do not number the points.
- Start every line with "- ".
- First bullet: biggest financial concern.
- Second bullet: biggest spending observation.
- Third bullet: one practical recommendation.
- Each bullet must be one sentence.
- Maximum 18 words per bullet.
- Never invent numbers.
""");

    prompt.writeln("Income: ₹$income");
    prompt.writeln("Expense: ₹$expense");
    prompt.writeln("Savings: ₹$savings");

    prompt.writeln("\nCategory Spending:");

    categoryTotals.forEach((key, value) {
      prompt.writeln("$key : ₹${value.toStringAsFixed(0)}");
    });

    final insight = await _gemini.askGemini(prompt.toString());

    await _insightDoc.set(
      AIInsightModel(insight: insight, generatedAt: Timestamp.now()).toMap(),
    );

    return insight;
  }
}
