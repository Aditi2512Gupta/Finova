import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/theme_provider.dart';
import '../../models/analytics_summary.dart';

class AnalyticsDashboardSummary extends StatelessWidget {
  final AnalyticsSummary summary;

  const AnalyticsDashboardSummary({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Format currency helper
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    // Styling configurations
    final savingsChangeColor = summary.savingsChange >= 0
        ? const Color(0xFF10B981) // Green
        : const Color(0xFFEF4444); // Red

    final incomeChangeColor = summary.incomeChange >= 0
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    final expenseChangeColor = summary.expenseChange <= 0
        ? const Color(0xFF10B981) // Expense decrease is green/positive
        : const Color(0xFFEF4444); // Expense increase is red/negative

    return Column(
      children: [
        // 1. Savings Card (Highlighted Top Card)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeProvider.primaryColor,
                themeProvider.primaryColor.withOpacity(0.85),
                themeProvider.primaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: themeProvider.primaryColor.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Decorative abstract shapes for modern design
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  left: -20,
                  bottom: -40,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.03),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.16),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.savings_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Total Savings",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                          
                          // Trend Capsule
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  summary.savingsChange >= 0
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${summary.savingsChange.abs().toStringAsFixed(1)}%",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 14),
                      
                      Text(
                        currencyFormatter.format(summary.savings),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Outfit',
                          letterSpacing: -0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      Text(
                        "vs previous period",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 2. Income & Expenses (Side-by-Side Cards)
        Row(
          children: [
            // Income Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: themeProvider.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_downward_rounded,
                            color: Color(0xFF10B981),
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Income",
                          style: TextStyle(
                            color: themeProvider.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currencyFormatter.format(summary.income),
                      style: TextStyle(
                        color: themeProvider.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Outfit',
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          summary.incomeChange >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: incomeChangeColor,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${summary.incomeChange.abs().toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: incomeChangeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "vs last",
                            style: TextStyle(
                              color: themeProvider.textSecondary.withOpacity(0.5),
                              fontSize: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Expenses Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: themeProvider.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_upward_rounded,
                            color: Color(0xFFEF4444),
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Expenses",
                          style: TextStyle(
                            color: themeProvider.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currencyFormatter.format(summary.expense),
                      style: TextStyle(
                        color: themeProvider.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Outfit',
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          summary.expenseChange <= 0
                              ? Icons.trending_down_rounded
                              : Icons.trending_up_rounded,
                          color: expenseChangeColor,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${summary.expenseChange.abs().toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: expenseChangeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "vs last",
                            style: TextStyle(
                              color: themeProvider.textSecondary.withOpacity(0.5),
                              fontSize: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}