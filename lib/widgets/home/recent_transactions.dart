import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import '../../screens/transactions/transactions_screen.dart';

class RecentTransactions extends StatefulWidget {
  const RecentTransactions({super.key});

  @override
  State<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<RecentTransactions> {
  final TransactionService transactionService = TransactionService();
  final CategoryService categoryService = CategoryService();

  Map<String, CategoryModel> categoryMap = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    categoryMap = await categoryService.getCategoryMap();
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return "Today";
    } else if (checkDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat("dd MMM yyyy").format(date);
    }
  }

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.payment_rounded;
    final lower = categoryName.toLowerCase();
    if (lower.contains("food") ||
        lower.contains("swiggy") ||
        lower.contains("restaurant") ||
        lower.contains("dine")) {
      return Icons.restaurant_rounded;
    } else if (lower.contains("salary") ||
        lower.contains("income") ||
        lower.contains("pay")) {
      return Icons.payments_rounded;
    } else if (lower.contains("shopping") ||
        lower.contains("clothes") ||
        lower.contains("store")) {
      return Icons.shopping_bag_rounded;
    } else if (lower.contains("bill") ||
        lower.contains("recharge") ||
        lower.contains("electricity")) {
      return Icons.receipt_rounded;
    } else if (lower.contains("travel") ||
        lower.contains("cab") ||
        lower.contains("taxi") ||
        lower.contains("uber")) {
      return Icons.local_taxi_rounded;
    } else if (lower.contains("education") || lower.contains("school")) {
      return Icons.school_rounded;
    } else if (lower.contains("health") || lower.contains("medic")) {
      return Icons.health_and_safety_rounded;
    }
    return Icons.widgets_rounded;
  }

  Color _getCategoryColor(String? categoryName) {
    if (categoryName == null) return Colors.blueGrey;
    final lower = categoryName.toLowerCase();
    if (lower.contains("food") || lower.contains("swiggy")) {
      return const Color(0xFFFF5E57); // Coral Red
    } else if (lower.contains("salary") || lower.contains("income")) {
      return const Color(0xFF26DE81); // Mint Green
    } else if (lower.contains("shopping")) {
      return const Color(0xFFA55EEA); // Orchid Purple
    } else if (lower.contains("bill")) {
      return const Color(0xFFFF9F43); // Amber Orange
    } else if (lower.contains("travel")) {
      return const Color(0xFF00A8FF); // Electric Cyan
    } else if (lower.contains("education") || lower.contains("school")) {
      return const Color(0xFF4B7BEC); // Royal Blue
    } else if (lower.contains("health") || lower.contains("medic")) {
      return const Color(0xFFE84393); // Warm Pink
    }
    return const Color(0xFF5F27CD); // Deep Purple
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (loading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Transactions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: themeProvider.textPrimary,
                fontFamily: 'Outfit',
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                );
              },
              child: Text(
                "View All",
                style: TextStyle(
                  color: themeProvider.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<TransactionModel>>(
          stream: transactionService.getTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final transactions = snapshot.data ?? [];

            if (transactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "No transactions yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Your expenses and income will appear here.",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final recent = transactions.take(5).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final transaction = recent[index];
                final isIncome = transaction.type == "Income";
                final category = categoryMap[transaction.categoryId];
                final categoryName = category?.name ?? "General";
                final catColor = category != null
                    ? Color(category.color)
                    : _getCategoryColor(categoryName);
                final catIcon = category != null
                    ? IconData(category.icon, fontFamily: 'MaterialIcons')
                    : _getCategoryIcon(categoryName);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: themeProvider.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.015),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Category icon representation
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Icon(catIcon, color: catColor, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text columns
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textPrimary,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              categoryName,
                              style: TextStyle(
                                fontSize: 12,
                                color: themeProvider.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right columns (Amount and date)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${isIncome ? "+" : "-"}${NumberFormat.currency(locale: 'en_IN', symbol: "₹", decimalDigits: 0).format(transaction.amount)}",
                            style: TextStyle(
                              color: isIncome
                                  ? const Color(0xFF10B981) // Green
                                  : const Color(0xFFEF4444), // Pink/Red
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatRelativeDate(transaction.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: themeProvider.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
