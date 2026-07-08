import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/transactions/add_transaction_screen.dart';
import '../../screens/receipt/receipt_scanner_screen.dart';
import '../../screens/goals/goals_screen.dart';

class AddMenuSheet extends StatelessWidget {
  const AddMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Slide indicator
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: themeProvider.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Header Title
            Text(
              "Add New",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: themeProvider.textPrimary,
                fontFamily: 'Outfit',
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),

            // Action Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionItem(
                  context,
                  color: const Color(0xFFEF4444),
                  icon: Icons.arrow_downward_rounded, // Expense is cash-out, down arrow
                  title: "Add Expense",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen(initialType: "Expense"),
                      ),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  color: const Color(0xFF10B981),
                  icon: Icons.arrow_upward_rounded, // Income is cash-in, up arrow
                  title: "Add Income",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen(initialType: "Income"),
                      ),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  color: const Color(0xFF3B82F6),
                  icon: Icons.camera_alt_rounded,
                  title: "Scan Receipt",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReceiptScannerScreen(),
                      ),
                    );
                  },
                ),
                _buildActionItem(
                  context,
                  color: const Color(0xFFF59E0B),
                  icon: Icons.ads_click_rounded, // Goal symbol target / flag
                  title: "Savings Goal",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GoalsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: themeProvider.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }
}