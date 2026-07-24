import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/ai/ai_coach_screen.dart';

class AIInsightCard extends StatelessWidget {
  final String insight;
  final VoidCallback onRefresh;

  const AIInsightCard({
    super.key,
    required this.insight,
    required this.onRefresh,
  });

  List<String> _parseInsights(String text) {
    return text
        .split('\n')
        .map(
          (e) => e
              .replaceAll("-", "")
              .replaceAll("•", "")
              .replaceAll("*", "")
              .replaceAll("_", "")
              .replaceAll("`", "")
              .trim(),
        )
        .where((e) => e.isNotEmpty)
        .take(3)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final insights = _parseInsights(insight);
    final icons = [
      Icons.warning_amber_rounded,
      Icons.pie_chart_rounded,
      Icons.lightbulb_rounded,
    ];

    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
    ];
    final cleanedInsight = insight
        .replaceAll("*", "")
        .replaceAll("_", "")
        .replaceAll("`", "")
        .trim();

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // AI Glow Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.primaryColor,
                        const Color(0xFF8B5CF6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.primaryColor.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Nova Today",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),

                // Refresh Button
              ],
            ),

            const SizedBox(height: 12),

            // Dynamic insights list
            if (insights.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  cleanedInsight,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: themeProvider.textSecondary,
                    height: 1.5,
                    fontFamily: 'Outfit',
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: insights.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final text = insights[index];

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: colors[index].withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icons[index],
                          color: colors[index],
                          size: 14,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 13,
                            color: themeProvider.textSecondary,
                            height: 1.45,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text("Refresh"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AICoachScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                    ),
                    label: const Text("Ask Nova"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
