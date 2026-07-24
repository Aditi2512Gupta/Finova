import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class FinancialHealthCard extends StatelessWidget {
  final int score;
  final String label;
  final String suggestion;

  const FinancialHealthCard({
    super.key,
    required this.score,
    required this.label,
    required this.suggestion,
  });

  Color _getColor() {
    if (score >= 90) return const Color(0xFF10B981); // Emerald Green
    if (score >= 75) return const Color(0xFF84CC16); // Lime Green
    if (score >= 60) return const Color(0xFFF59E0B); // Amber Orange
    return const Color(0xFFEF4444); // Red
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final color = _getColor();

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showHealthDetails(context),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Progress indicator ring
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 7,
                          color: color,
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "$score",
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  color: themeProvider.textPrimary,
                                  fontFamily: 'Outfit',
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "health",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: themeProvider.textSecondary.withOpacity(0.7),
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Health text description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Financial Health",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textPrimary,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Health capsule badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          suggestion,
                          style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.textSecondary,
                            height: 1.4,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHealthDetails(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final color = _getColor();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
                // Drag handle
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
                const SizedBox(height: 24),

                Text(
                  "Financial Health Breakdown",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 20),

                // Score stats row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeProvider.borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.favorite_rounded, color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Overall Rating",
                              style: TextStyle(
                                fontSize: 12,
                                color: themeProvider.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "$label ($score/100)",
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  "Factors affecting your score:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 12),

                // Factor list
                _buildFactorRow(Icons.compare_arrows_rounded, "Income vs Expenses ratio", themeProvider),
                const SizedBox(height: 12),
                _buildFactorRow(Icons.donut_large_rounded, "Budget Usage & Limits compliance", themeProvider),
                const SizedBox(height: 12),
                _buildFactorRow(Icons.track_changes_rounded, "Savings Goals Progress speed", themeProvider),
                const SizedBox(height: 12),
                _buildFactorRow(Icons.replay_rounded, "On-time Recurring Payments history", themeProvider),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Recommendation
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_rounded, color: themeProvider.primaryColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textPrimary,
                          height: 1.45,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFactorRow(IconData icon, String title, ThemeProvider theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.primaryColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            color: theme.textSecondary,
            fontWeight: FontWeight.w500,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }
}
