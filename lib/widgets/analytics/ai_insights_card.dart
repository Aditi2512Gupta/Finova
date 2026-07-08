import 'package:flutter/material.dart';

import '../../models/transaction_model.dart';

class AIInsightsCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final double budget;

  const AIInsightsCard({
    super.key,
    required this.transactions,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    double income = 0;
    double expense = 0;

    final Map<String, double> categoryExpense = {};

    for (final t in transactions) {
      if (t.type == "Income") {
        income += t.amount;
      } else {
        expense += t.amount;

        categoryExpense.update(
          t.categoryId,
          (value) => value + t.amount,
          ifAbsent: () => t.amount,
        );
      }
    }

    String topCategory = "-";
    double topAmount = 0;

    categoryExpense.forEach((key, value) {
      if (value > topAmount) {
        topAmount = value;
        topCategory = key;
      }
    });

    final percent =
        budget == 0 ? 0 : ((expense / budget) * 100).clamp(0, 999);

    String advice;

    if (expense > budget) {
      advice =
          "⚠️ You have exceeded your monthly budget by ₹${(expense - budget).toStringAsFixed(0)}.";
    } else if (percent > 80) {
      advice =
          "⚠️ You have already used ${percent.toStringAsFixed(0)}% of your monthly budget.";
    } else {
      advice = "✅ Your spending is under control this month.";
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🤖 AI Spending Insights",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text("💰 Income : ₹${income.toStringAsFixed(0)}"),

            const SizedBox(height: 8),

            Text("💸 Expense : ₹${expense.toStringAsFixed(0)}"),

            const SizedBox(height: 8),

            Text("🏆 Top Spending Category : $topCategory"),

            const SizedBox(height: 8),

            Text("📊 Budget Used : ${percent.toStringAsFixed(1)}%"),

            const Divider(height: 28),

            Text(
              advice,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}