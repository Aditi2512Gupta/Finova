import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/theme_provider.dart';
import '../../screens/transactions/add_transaction_screen.dart';
import '../../screens/receipt/receipt_scanner_screen.dart';
import '../../services/transaction_service.dart';
import '../../services/export_service.dart';
import '../../services/firestore_service.dart';
import '../../services/ai_health_service.dart';
import '../../services/budget_service.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  Future<void> _previewPDF(BuildContext context) async {
    final exportService = ExportService();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    try {
      final transactions = await TransactionService().getTransactions().first;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      final userModel = await FirestoreService().getUser(uid);

      final totalIncome = transactions
          .where((t) => t.type == "Income")
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpense = transactions
          .where((t) => t.type == "Expense")
          .fold(0.0, (sum, t) => sum + t.amount);
      final budgetLimit = await BudgetService().getBudget().first;

      final healthScore = AIHealthService().calculateScore(
        income: totalIncome,
        expense: totalExpense,
        completedGoals: 0,
        totalGoals: 0,
        exceededBudgets: totalExpense > budgetLimit ? 1 : 0,
      );

      await exportService.previewPDF(
        transactions: transactions,
        themePrimaryColor: themeProvider.primaryColor,
        userName: userModel.name,
        financialHealthScore: healthScore,
      );
    } catch (e) {
      debugPrint(e.toString());

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to export PDF.")));
      }
    }
  }

  Future<void> _sharePDF(BuildContext context) async {
    final exportService = ExportService();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    try {
      final transactions = await TransactionService().getTransactions().first;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      final userModel = await FirestoreService().getUser(uid);

      final totalIncome = transactions
          .where((t) => t.type == "Income")
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpense = transactions
          .where((t) => t.type == "Expense")
          .fold(0.0, (sum, t) => sum + t.amount);
      final budgetLimit = await BudgetService().getBudget().first;

      final healthScore = AIHealthService().calculateScore(
        income: totalIncome,
        expense: totalExpense,
        completedGoals: 0,
        totalGoals: 0,
        exceededBudgets: totalExpense > budgetLimit ? 1 : 0,
      );

      await exportService.sharePDF(
        transactions: transactions,
        themePrimaryColor: themeProvider.primaryColor,
        userName: userModel.name,
        financialHealthScore: healthScore,
      );
    } catch (e) {
      debugPrint(e.toString());

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to export PDF.")));
      }
    }
  }

  Widget _optionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required ThemeProvider theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: theme.textPrimary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textSecondary,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: theme.textSecondary.withOpacity(0.4),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: themeProvider.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  "Export PDF",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                    fontFamily: 'Outfit',
                  ),
                ),

                const SizedBox(height: 24),

                _optionCard(
                  title: "Preview PDF",
                  subtitle: "View statement layout before saving",
                  icon: Icons.visibility_rounded,
                  color: themeProvider.primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    _previewPDF(context);
                  },
                  theme: themeProvider,
                ),

                _optionCard(
                  title: "Share / Save PDF",
                  subtitle: "Export via WhatsApp, Google Drive, Files...",
                  icon: Icons.share_rounded,
                  color: const Color(0xFF8B5CF6), // Purple accent
                  onTap: () {
                    Navigator.pop(context);
                    _sharePDF(context);
                  },
                  theme: themeProvider,
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: themeProvider.textPrimary,
            fontFamily: 'Outfit',
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 2.3,
          children: [
            _actionCard(
              context,
              title: "Add Expense",
              icon: Icons.arrow_downward_rounded,
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddTransactionScreen(initialType: "Expense"),
                  ),
                );
              },
            ),
            _actionCard(
              context,
              title: "Add Income",
              icon: Icons.arrow_upward_rounded,
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddTransactionScreen(initialType: "Income"),
                  ),
                );
              },
            ),
            _actionCard(
              context,
              title: "Scan Receipt",
              icon: Icons.qr_code_scanner_rounded,
              color: const Color(0xFFF59E0B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReceiptScannerScreen(),
                  ),
                );
              },
            ),
            _actionCard(
              context,
              title: "Export PDF",
              icon: Icons.picture_as_pdf_rounded,
              color: const Color(0xFF8B5CF6),
              onTap: () => _showExportOptions(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: themeProvider.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: themeProvider.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, color: color, size: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
