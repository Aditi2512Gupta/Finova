import 'package:flutter/material.dart';
import '../../widgets/home/recent_transactions.dart';
import '../../widgets/home/hero_balance_card.dart';
import '../../widgets/home/quick_actions.dart';
import '../../widgets/home/budget_progress.dart';
import '../../widgets/home/home_header.dart';
import '../../services/dashboard_service.dart';
import '../../services/budget_service.dart';
import '../../services/transaction_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService dashboardService = DashboardService();
  final BudgetService budgetService = BudgetService();

  @override
  void initState() {
    super.initState();
    // Run automated recurring transaction processor
    TransactionService().processRecurringTransactions();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  IconData getGreetingIcon() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return Icons.wb_sunny;
    } else if (hour < 17) {
      return Icons.wb_cloudy;
    } else {
      return Icons.nightlight_round;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<double>(
        stream: dashboardService.getTotalBalance(),
        builder: (context, balanceSnapshot) {
          return StreamBuilder<double>(
            stream: dashboardService.getTotalIncome(),
            builder: (context, incomeSnapshot) {
              return StreamBuilder<double>(
                stream: dashboardService.getTotalExpense(),
                builder: (context, expenseSnapshot) {
                  if (!balanceSnapshot.hasData ||
                      !incomeSnapshot.hasData ||
                      !expenseSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final balance = balanceSnapshot.data!;
                  final income = incomeSnapshot.data!;
                  final expense = expenseSnapshot.data!;

                  return StreamBuilder<double>(
                    stream: budgetService.getBudget(),
                    builder: (context, budgetSnapshot) {
                      final budget = budgetSnapshot.data ?? 30000.0;

                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),

                                const HomeHeader(),

                                const SizedBox(height: 26),
                                
                                HeroBalanceCard(
                                  balance: balance,
                                  income: income,
                                  expense: expense,
                                ),

                                const SizedBox(height: 28),

                                BudgetProgress(
                                  spent: expense,
                                  budget: budget,
                                ),

                                const SizedBox(height: 28),

                                QuickActions(),

                                const SizedBox(height: 34),

                                RecentTransactions(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
