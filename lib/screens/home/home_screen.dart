import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../widgets/home/recent_transactions.dart';
import '../../widgets/home/hero_balance_card.dart';
import '../../widgets/home/quick_actions.dart';
import '../../widgets/home/budget_progress.dart';
import '../../widgets/home/home_header.dart';
import '../../services/dashboard_service.dart';
import '../../services/budget_service.dart';
import '../../services/ai_health_service.dart';
import '../../widgets/home/financial_health_card.dart';
import '../../services/ai_insights_service.dart';
import '../../widgets/home/ai_insight_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService dashboardService = DashboardService();
  final BudgetService budgetService = BudgetService();
  final AIHealthService _healthService = AIHealthService();
  final AIInsightsService _insightService = AIInsightsService();
  String? _aiInsight;
  bool _isGeneratingInsight = false;

  @override
  @override
  void initState() {
    super.initState();
    _loadAIInsights();
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

  Future<void> _loadAIInsights() async {
    if (_isGeneratingInsight) return;

    setState(() {
      _isGeneratingInsight = true;
    });

    final prefs = await SharedPreferences.getInstance();

    try {
      final insight = await _insightService.getInsights();

      await prefs.setString("cached_ai_insight", insight);

      if (!mounted) return;

      setState(() {
        _aiInsight = insight.replaceAll("**", "").replaceAll("*", "");
      });
    } catch (e) {
      debugPrint("AI Insight Error: $e");

      final cached = prefs.getString("cached_ai_insight");

      if (!mounted) return;

      setState(() {
        _aiInsight = cached;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingInsight = false;
        });
      }
    }
  }

  Future<void> _refreshAIInsights() async {
    if (_isGeneratingInsight) return;

    setState(() {
      _isGeneratingInsight = true;
    });

    final prefs = await SharedPreferences.getInstance();

    try {
      final insight = await _insightService.refreshInsights();

      await prefs.setString("cached_ai_insight", insight);

      if (!mounted) return;

      setState(() {
        _aiInsight = insight;
      });
    } catch (e) {
      debugPrint("Refresh Insight Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't refresh AI insights. Please try again later.",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingInsight = false;
        });
      }
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
                      final score = _healthService.calculateScore(
                        income: income,
                        expense: expense,
                        completedGoals: 0,
                        totalGoals: 0,
                        exceededBudgets: expense > budget ? 1 : 0,
                      );

                      final label = _healthService.getHealthLabel(score);

                      final suggestion = _healthService.getSuggestion(score);

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

                                BudgetProgress(spent: expense, budget: budget),

                                const SizedBox(height: 24),

                                FinancialHealthCard(
                                  score: score,
                                  label: label,
                                  suggestion: suggestion,
                                ),

                                const SizedBox(height: 28),

                                QuickActions(),

                                const SizedBox(height: 28),

                                if (_isGeneratingInsight)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else if (_aiInsight != null)
                                  AIInsightCard(
                                    insight: _aiInsight!,
                                    onRefresh: _refreshAIInsights,
                                  )
                                else
                                  AIInsightCard(
                                    insight:
                                        "Nova couldn't generate today's insight. Tap Refresh or Ask Nova for personalized advice.",
                                    onRefresh: _refreshAIInsights,
                                  ),
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
