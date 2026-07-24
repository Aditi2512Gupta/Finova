import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';

class ExpensePieChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Map<String, CategoryModel> categoryMap;

  const ExpensePieChart({
    super.key,
    required this.transactions,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final Map<String, double> categoryTotals = {};
    double totalExpense = 0;

    for (final transaction in transactions) {
      if (transaction.type != "Expense") continue;

      categoryTotals.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
      totalExpense += transaction.amount;
    }

    if (categoryTotals.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: themeProvider.borderColor),
        ),
        child: Center(
          child: Text(
            "No expense data this period",
            style: TextStyle(color: themeProvider.textSecondary, fontFamily: 'Outfit'),
          ),
        ),
      );
    }

    final colors = [
      const Color(0xFFFF5E57), // Coral Red
      const Color(0xFF00A8FF), // Electric Cyan
      const Color(0xFFA55EEA), // Orchid Purple
      const Color(0xFFFF9F43), // Amber Orange
      const Color(0xFF4B7BEC), // Royal Blue
      const Color(0xFFE84393), // Warm Pink
      const Color(0xFF26DE81), // Mint Green
      const Color(0xFF0FB9B1), // Teal Green
      const Color(0xFFFFD200), // Sun Yellow
      const Color(0xFF5F27CD), // Deep Purple
    ];

    // Sort categories by amount descending
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Expense Overview",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Donut Chart on Left with Stack for center text
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 46,
                          startDegreeOffset: -90,
                          sections: List.generate(sortedEntries.length, (i) {
                            final entry = sortedEntries[i];
                            final categoryColorVal = categoryMap[entry.key]?.color;
                            final color = categoryColorVal != null && categoryColorVal != 0
                                ? Color(categoryColorVal)
                                : colors[i % colors.length];
                            return PieChartSectionData(
                              color: color,
                              value: entry.value,
                              radius: 12,
                              showTitle: false,
                            );
                          }),
                        ),
                      ),
                      // Center Hole Text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "₹${totalExpense.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: themeProvider.textPrimary,
                              fontFamily: 'Outfit',
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 11,
                              color: themeProvider.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Vertical Legend on Right
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(sortedEntries.length, (i) {
                    if (i >= 5) return const SizedBox.shrink(); // Limit list to top 5
                    final entry = sortedEntries[i];
                    
                    final categoryColorVal = categoryMap[entry.key]?.color;
                    final color = categoryColorVal != null && categoryColorVal != 0
                        ? Color(categoryColorVal)
                        : colors[i % colors.length];
                        
                    final name = categoryMap[entry.key]?.name ?? "Other";
                    final pct = ((entry.value / totalExpense) * 100).toStringAsFixed(0);
                    
                    final iconCode = categoryMap[entry.key]?.icon ?? Icons.category.codePoint;
                    final categoryIcon = IconData(iconCode, fontFamily: 'MaterialIcons');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              categoryIcon,
                              color: color,
                              size: 10,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textPrimary,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$pct%",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textSecondary,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
