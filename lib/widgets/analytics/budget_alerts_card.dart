import 'package:flutter/material.dart';
import '../../models/budget_model.dart';
import '../../models/category_model.dart';

class BudgetAlertsCard extends StatelessWidget {
  final Map<String, double> categoryExpenses;
  final Map<String, BudgetModel> categoryBudgets;
  final Map<String, CategoryModel> categoryMap;

  const BudgetAlertsCard({
    super.key,
    required this.categoryExpenses,
    required this.categoryBudgets,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    final alerts = <Widget>[];

    categoryExpenses.forEach((id, spent) {
      final budget = categoryBudgets[id];

      if (budget == null) return;

      final ratio = spent / budget.amount;

      String message;
      Color color;
      IconData icon;

      if (ratio >= 1) {
        message =
            "${categoryMap[id]?.name ?? "Category"} exceeded by ₹${(spent - budget.amount).toStringAsFixed(0)}";

        color = Colors.red;
        icon = Icons.warning_rounded;
      } else if (ratio >= .8) {
        message =
            "${categoryMap[id]?.name ?? "Category"} is ${(ratio * 100).toStringAsFixed(0)}% used";

        color = Colors.orange;
        icon = Icons.error_outline;
      } else {
        return;
      }

      alerts.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
    });

    if (alerts.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Budget Alerts",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...alerts,
          ],
        ),
      ),
    );
  }
}