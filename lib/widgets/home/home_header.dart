import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/theme_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/transaction_service.dart';
import '../../services/budget_service.dart';
import '../../services/goal_service.dart';
import '../../models/user_model.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) return "Good Morning";
    if (hour >= 12 && hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  Future<List<Map<String, dynamic>>> _getRealNotifications(String uid) async {
    final List<Map<String, dynamic>> alerts = [];
    try {
      final transactions = await TransactionService().getTransactions().first;
      final budget = await BudgetService().getBudget().first;
      final goals = await GoalService().getGoals().first;

      // 1. Budget Exceeded or warning check
      double totalExpense = 0;
      for (var t in transactions) {
        if (t.type == "Expense") {
          totalExpense += t.amount;
        }
      }

      if (budget > 0) {
        if (totalExpense > budget) {
          alerts.add({
            'title': 'Budget Exceeded Alert',
            'body': 'Warning: You spent ₹${totalExpense.toStringAsFixed(0)} which exceeds your monthly budget of ₹${budget.toStringAsFixed(0)}!',
            'icon': Icons.warning_amber_rounded,
            'color': Colors.redAccent,
            'time': 'Just now',
          });
        } else if (totalExpense >= budget * 0.8) {
          alerts.add({
            'title': 'Budget Alert',
            'body': 'You have used ${(totalExpense / budget * 100).toStringAsFixed(0)}% of your monthly budget (₹${totalExpense.toStringAsFixed(0)} spent out of ₹${budget.toStringAsFixed(0)}).',
            'icon': Icons.warning_amber_rounded,
            'color': Colors.orange,
            'time': '1h ago',
          });
        }
      }

      // 2. Goal progress alerts
      for (var goal in goals) {
        final pct = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount * 100).toInt() : 0;
        if (pct >= 100) {
          alerts.add({
            'title': 'Savings Goal Achieved!',
            'body': 'Congratulations! You reached 100% of your target for goal "${goal.title}"! 🎉',
            'icon': Icons.check_circle_outline_rounded,
            'color': Colors.green,
            'time': 'Recent',
          });
        } else if (pct > 0) {
          alerts.add({
            'title': 'Savings Goal Reminder',
            'body': 'Keep it up! You saved ₹${goal.currentAmount.toStringAsFixed(0)} / ₹${goal.targetAmount.toStringAsFixed(0)} for "${goal.title}" ($pct%).',
            'icon': Icons.track_changes_rounded,
            'color': Colors.green,
            'time': '1d ago',
          });
        }
      }

      // 3. Recurring reminder checks
      for (var t in transactions) {
        if (t.isRecurring) {
          alerts.add({
            'title': 'Recurring Reminder',
            'body': 'Your recurring payment for "${t.title}" of ₹${t.amount.toStringAsFixed(0)} is active.',
            'icon': Icons.replay_rounded,
            'color': Colors.blue,
            'time': 'Scheduled',
          });
        }
      }

      // 4. Default welcome notice if empty
      if (alerts.isEmpty) {
        alerts.add({
          'title': 'Nova AI Insight',
          'body': 'Welcome to Finova alerts! Add transactions, set a budget, or create savings goals to see personalized notifications here.',
          'icon': Icons.info_outline_rounded,
          'color': Colors.purple,
          'time': 'Now',
        });
      }
    } catch (e) {
      debugPrint("Alert generation error: $e");
    }
    return alerts;
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getRealNotifications(uid),
          builder: (context, snapshot) {
            final list = snapshot.data ?? [];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: themeProvider.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Recent Alerts",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (list.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Text(
                            "No new alerts. You're all caught up!",
                            style: TextStyle(color: themeProvider.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...list.map((n) => _buildNotificationItem(
                        context,
                        title: n['title'],
                        body: n['body'],
                        icon: n['icon'],
                        color: n['color'],
                        time: n['time'],
                      )),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String body,
    required IconData icon,
    required Color color,
    required String time,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: themeProvider.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: themeProvider.textSecondary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: themeProvider.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Clean Brand Name typography
            Text(
              "Finova",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: themeProvider.textPrimary,
                fontFamily: 'Outfit',
                letterSpacing: -0.6,
              ),
            ),

            const Spacer(),

            // Notification Bell (Functional!)
            GestureDetector(
              onTap: () => _showNotificationsBottomSheet(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: themeProvider.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: themeProvider.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: themeProvider.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Text(
          "${greeting()},",
          style: TextStyle(
            color: themeProvider.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Outfit',
          ),
        ),

        const SizedBox(height: 2),

        FutureBuilder<UserModel>(
          future: FirestoreService().getUser(uid),
          builder: (context, snapshot) {
            final name = snapshot.data?.name ?? FirebaseAuth.instance.currentUser?.displayName ?? "User";
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: themeProvider.textPrimary,
                    fontFamily: 'Outfit',
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeProvider.primaryColor.withOpacity(0.24)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        color: themeProvider.primaryColor,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Verified Member",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.primaryColor,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
