import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class HeroBalanceCard extends StatefulWidget {
  final double balance;
  final double income;
  final double expense;

  const HeroBalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  State<HeroBalanceCard> createState() => _HeroBalanceCardState();
}

class _HeroBalanceCardState extends State<HeroBalanceCard> {
  bool hideBalance = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      height: 236,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.primaryColor,
            themeProvider.primaryColor.withOpacity(0.85),
            const Color(0xFF4A34AC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: themeProvider.primaryColor.withOpacity(0.35),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 1,
          )
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // Custom Spline Graph painted in the background
            Positioned.fill(
              child: CustomPaint(
                painter: _SplinePainter(),
              ),
            ),

            // Top-right background decorative bubble
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // Main Content Layout
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with eye toggle
                  Row(
                    children: [
                      const Text(
                        "Total Balance",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Outfit',
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            hideBalance = !hideBalance;
                          });
                        },
                        child: Icon(
                          hideBalance
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Big Balance Number
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      hideBalance
                          ? "₹ •••••••"
                          : NumberFormat.currency(
                              locale: 'en_IN',
                              symbol: "₹",
                              decimalDigits: 2,
                            ).format(widget.balance),
                      key: ValueKey(hideBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Outfit',
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Income & Expense details
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassStat(
                          icon: Icons.arrow_downward_rounded,
                          iconColor: const Color(0xFF22C55E), // Green
                          label: "Income",
                          amount: widget.income,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGlassStat(
                          icon: Icons.arrow_upward_rounded,
                          iconColor: const Color(0xFFEF4444), // Red
                          label: "Expense",
                          amount: widget.expense,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassStat({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double amount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'en_IN',
                    symbol: "₹",
                    decimalDigits: 0,
                  ).format(amount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Background CustomPainter to draw a stylish wave spline representing charts
class _SplinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.white.withOpacity(0.2)
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Wave starting point (bottom left of card)
    path.moveTo(0, size.height * 0.72);
    
    // Spline curve coordinates
    path.cubicTo(
      size.width * 0.28,
      size.height * 0.48,
      size.width * 0.52,
      size.height * 0.88,
      size.width * 0.78,
      size.height * 0.52,
    );
    path.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.38,
      size.width,
      size.height * 0.44,
    );

    // Create shading fill path
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Shading shader
    final fillRect = Rect.fromLTWH(0, 0, size.width, size.height);
    fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.12),
        Colors.white.withOpacity(0.0),
      ],
    ).createShader(fillRect);

    // Draw paths
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}