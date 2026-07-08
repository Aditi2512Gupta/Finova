import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/chart_data.dart';

class IncomeExpenseChart extends StatelessWidget {
  final List<ChartData> chartData;

  const IncomeExpenseChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    double totalIncome = 0;
    double totalExpense = 0;

    for (final item in chartData) {
      totalIncome += item.income;
      totalExpense += item.expense;
    }

    double maxVal = 1000;

    for (final item in chartData) {
      if (item.income > maxVal) maxVal = item.income;
      if (item.expense > maxVal) maxVal = item.expense;
    }

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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Income vs Expense",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 16),

          // Side-by-side aggregate stats
          Row(
            children: [
              // Income Stat
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "₹${totalIncome.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: themeProvider.textPrimary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Income",
                    style: TextStyle(
                      fontSize: 11,
                      color: themeProvider.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Expense Stat
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "₹${totalExpense.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: themeProvider.textPrimary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Expense",
                    style: TextStyle(
                      fontSize: 11,
                      color: themeProvider.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Double Bar Chart
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(), // Clean: no left axis lines
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= chartData.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            chartData[index].label,
                            style: TextStyle(
                              color: themeProvider.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(chartData.length, (index) {
                  final data = chartData[index];

                  final incVal = data.income;

                  final expVal = data.expense;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      // Income Rod
                      BarChartRodData(
                        toY: incVal == 0
                            ? 3.0
                            : incVal, // Small min value so rod is visible
                        width: 6,
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // Expense Rod
                      BarChartRodData(
                        toY: expVal == 0 ? 3.0 : expVal,
                        width: 6,
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
