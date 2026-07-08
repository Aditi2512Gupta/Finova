import 'package:month_year_picker/month_year_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/analytics_service.dart';
import '../../models/transaction_model.dart';
import '../../widgets/analytics/expense_pie_chart.dart';
import '../../services/category_service.dart';
import '../../widgets/analytics/income_expense_chart.dart';
import '../../models/category_model.dart';
import '../../services/budget_service.dart';
import '../../models/analytics_period.dart';
import '../../widgets/analytics/analytics_summary_card.dart';
import '../../models/budget_model.dart';
import '../../models/analytics_summary.dart';
import '../../widgets/analytics/budget_alerts_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService analyticsService = AnalyticsService();
  final CategoryService categoryService = CategoryService();
  final BudgetService budgetService = BudgetService();

  Map<String, CategoryModel> categoryMap = {};
  bool loading = true;
  AnalyticsPeriod selectedPeriod = AnalyticsPeriod.thisMonth;

  DateTime selectedMonth = DateTime.now();
  String filterType = "All";

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  String getPeriodText() {
    switch (selectedPeriod) {
      case AnalyticsPeriod.thisMonth:
        return "This Month";

      case AnalyticsPeriod.lastMonth:
        return "Last Month";

      case AnalyticsPeriod.last3Months:
        return "Last 3 Months";

      case AnalyticsPeriod.last6Months:
        return "Last 6 Months";

      case AnalyticsPeriod.thisYear:
        return "This Year";

      case AnalyticsPeriod.customMonth:
        return "${_monthName(selectedMonth.month)} ${selectedMonth.year}";
    }
  }

  String _monthName(int month) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return months[month];
  }

  Future<void> loadCategories() async {
    categoryMap = await categoryService.getCategoryMap();
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Filter Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Transaction Type",
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ["All", "Expense", "Income"].map((t) {
                        final isSelected = filterType == t;
                        return ChoiceChip(
                          label: Text(t),
                          selected: isSelected,
                          selectedColor: themeProvider.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : themeProvider.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() {
                                filterType = t;
                              });
                              setState(() {
                                filterType = t;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: themeProvider.primaryColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Apply Filter",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPeriodBottomSheet() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Choose Period",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                ),

                const SizedBox(height: 24),

                _periodTile("This Month", AnalyticsPeriod.thisMonth),

                _periodTile("Last Month", AnalyticsPeriod.lastMonth),

                _periodTile("Last 3 Months", AnalyticsPeriod.last3Months),

                _periodTile("Last 6 Months", AnalyticsPeriod.last6Months),

                _periodTile("This Year", AnalyticsPeriod.thisYear),

                const Divider(height: 32),

                ListTile(
                  leading: Icon(
                    Icons.calendar_today,
                    color: themeProvider.primaryColor,
                  ),
                  title: const Text("Custom Month"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                  onTap: () async {
                    Navigator.pop(context);
                    print("Custom Month clicked");

                    final picked = await showMonthYearPicker(
                      context: context,
                      initialDate: selectedMonth,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            dialogTheme: const DialogThemeData(
                              insetPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 24,
                              ),
                            ),
                          ),
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaler: const TextScaler.linear(0.85),
                            ),
                            child: Center(child: FittedBox(child: child!)),
                          ),
                        );
                      },
                    );

                    if (picked != null) {
                      setState(() {
                        selectedMonth = picked;
                        selectedPeriod = AnalyticsPeriod.customMonth;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _periodTile(String title, AnalyticsPeriod period) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final selected = selectedPeriod == period;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? themeProvider.primaryColor : Colors.grey,
      ),

      title: Text(title),

      onTap: () {
        setState(() {
          selectedPeriod = period;
        });

        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<double>(
                stream: budgetService.getBudget(),
                builder: (context, budgetSnapshot) {
                  final budget = budgetSnapshot.data ?? 30000;

                  return StreamBuilder<Map<String, BudgetModel>>(
                    stream: budgetService.getCategoryBudgets(),
                    builder: (context, budgetMapSnapshot) {
                      final categoryBudgets = budgetMapSnapshot.data ?? {};

                      return StreamBuilder<List<TransactionModel>>(
                        stream: analyticsService.getTransactions(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final allTransactions = snapshot.data!;

                          List<TransactionModel> transactions = analyticsService
                              .filterTransactions(
                                transactions: allTransactions,
                                period: selectedPeriod,
                                selectedMonth: selectedMonth,
                                filterType: filterType,
                              );

                          final previousTransactions = analyticsService
                              .filterPreviousTransactions(
                                transactions: allTransactions,
                                period: selectedPeriod,
                                selectedMonth: selectedMonth,
                                filterType: filterType,
                              );

                          final summary = analyticsService.buildSummary(
                            current: transactions,
                            previous: previousTransactions,
                          );

                          final chartData = analyticsService.buildChartData(
                            transactions: transactions,
                            period: selectedPeriod,
                            selectedMonth: selectedMonth,
                          );

                          // Aggregate expenses by category for budget overview
                          final Map<String, double> categoryExpenses = {};
                          double totalExpense = 0;
                          for (var t in transactions) {
                            if (t.type == "Expense") {
                              categoryExpenses.update(
                                t.categoryId,
                                (v) => v + t.amount,
                                ifAbsent: () => t.amount,
                              );
                              totalExpense += t.amount;
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Custom Dropdown Header Row
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Period Selector Dropdown
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: _showPeriodBottomSheet,
                                        child: Container(
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: themeProvider.surfaceColor,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: themeProvider.borderColor,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_month_rounded,
                                                size: 18,
                                                color:
                                                    themeProvider.primaryColor,
                                              ),

                                              const SizedBox(width: 10),

                                              Expanded(
                                                child: Text(
                                                  getPeriodText(),
                                                  style: TextStyle(
                                                    color: themeProvider
                                                        .textPrimary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                              Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color:
                                                    themeProvider.textSecondary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Filter Icon
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: themeProvider.surfaceColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: themeProvider.borderColor,
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.tune_rounded,
                                          color: themeProvider.textPrimary,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _showFilterBottomSheet(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Scrollable charts
                              Expanded(
                                child: ListView(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    8,
                                    20,
                                    110,
                                  ),
                                  children: [
                                    AnalyticsDashboardSummary(summary: summary),

                                    const SizedBox(height: 18),

                                    BudgetAlertsCard(
                                      categoryExpenses: categoryExpenses,
                                      categoryBudgets: categoryBudgets,
                                      categoryMap: categoryMap,
                                    ),

                                    const SizedBox(height: 18),

                                    ExpensePieChart(
                                      transactions: transactions,
                                      categoryMap: categoryMap,
                                    ),

                                    const SizedBox(height: 18),

                                    IncomeExpenseChart(chartData: chartData),

                                    const SizedBox(height: 18),

                                    _buildBudgetOverviewCard(
                                      context,
                                      budget: budget,
                                      totalExpense: totalExpense,
                                      categoryExpenses: categoryExpenses,
                                      categoryBudgets: categoryBudgets,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }, // Transaction StreamBuilder builder
                      ); // Transaction StreamBuilder
                    }, // Category Budget StreamBuilder builder
                  ); // Category Budget StreamBuilder
                }, // Budget StreamBuilder builder
              ), // Budget StreamBuilder
      ),
    );
  }

  Widget _buildBudgetOverviewCard(
    BuildContext context, {
    required double budget,
    required double totalExpense,
    required Map<String, double> categoryExpenses,
    required Map<String, BudgetModel> categoryBudgets,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Mock category budgets if not fully stored, matching design overview
    final List<Map<String, dynamic>> budgetItems = [];

    // Monthly overall budget progress
    budgetItems.add({
      'name': 'Total Budget',
      'spent': totalExpense,
      'limit': budget,
      'color': themeProvider.primaryColor,
    });

    // Populate category progresses
    int index = 0;
    final catColors = [
      const Color.fromARGB(255, 119, 239, 68),
      const Color(0xFFEC4899),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
    ];
    categoryExpenses.forEach((catId, spent) {
      final name = categoryMap[catId]?.name ?? "General";
      final limit = categoryBudgets[catId]?.amount ?? spent * 1.2;
      budgetItems.add({
        'id': catId,
        'name': name,
        'spent': spent,
        'limit': limit,
        'color': catColors[index % catColors.length],
      });
      index++;
    });

    // Default mock item if empty
    if (budgetItems.length == 1) {
      budgetItems.add({
        'name': 'Groceries',
        'spent': 2300.0,
        'limit': 4000.0,
        'color': const Color(0xFF8B5CF6),
      });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Budget Overview",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Column(
            children: budgetItems.map((item) {
              final name = item['name'] as String;
              final spent = item['spent'] as double;
              final limit = item['limit'] as double;
              final color = item['color'] as Color;

              final rawProgress = spent / limit;
              final progress = rawProgress.clamp(0.0, 1.0);

              String status;

              if (rawProgress >= 1.0) {
                status = "Over Budget";
              } else if (rawProgress >= 0.8) {
                status = "Almost Full";
              } else {
                status = "Within Budget";
              }
              final percent = (progress * 100).toStringAsFixed(0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        Text(
                          "₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: themeProvider.backgroundColor,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "$percent%",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: rawProgress >= 1
                            ? Colors.red
                            : rawProgress >= 0.8
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
