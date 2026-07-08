import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class BudgetProgress extends StatelessWidget {
  final double spent;
  final double budget;

  const BudgetProgress({
    super.key,
    required this.spent,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final limit = budget <= 0 ? 30000.0 : budget;
    final progress = (spent / limit).clamp(0.0, 1.0);
    final remaining = (limit - spent).clamp(0.0, double.infinity);
    final percent = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Monthly Budget Limit",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textSecondary,
                  fontFamily: 'Outfit',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$percent% Spent",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: themeProvider.primaryColor,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Amounts
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "₹${spent.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: themeProvider.textPrimary,
                  fontFamily: 'Outfit',
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                " / ₹${limit.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textSecondary.withOpacity(0.7),
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: themeProvider.backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(themeProvider.primaryColor),
            ),
          ),
          const SizedBox(height: 12),

          // Remaining Status text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Remaining Budget",
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.textSecondary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "₹${remaining.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 12,
                  color: progress >= 0.9 ? Colors.redAccent : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}