import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;

  const LogoWidget({
    super.key,
    this.size = 80,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F0C22),
                Color(0xFF1E1B4B),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C4CF1).withOpacity(0.35),
                blurRadius: size * 0.35,
                spreadRadius: 2,
                offset: Offset(0, size * 0.1),
              )
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
          ),
          child: Center(
            child: CustomPaint(
              size: Size(size * 0.45, size * 0.5),
              painter: _LogoFPainter(),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          const Text(
            "Finova",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              fontFamily: 'Outfit',
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Smart Finance, Better Future",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Outfit',
            ),
          ),
        ]
      ],
    );
  }
}

class _LogoFPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw stylized F using paths
    final w = size.width;
    final h = size.height;

    // Gradient 1: Pink/Purple for vertical bar and top bar
    final rect1 = Rect.fromLTWH(0, 0, w, h);
    const gradient1 = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFF007A), // Hot Pink
        Color(0xFF8B5CF6), // Purple
      ],
    );
    paint.shader = gradient1.createShader(rect1);

    // Path of vertical stem + top bar
    final path1 = Path()
      ..moveTo(0, h * 0.12)
      // Top bar rounded edge
      ..quadraticBezierTo(0, 0, w * 0.22, 0)
      ..lineTo(w * 0.85, 0)
      ..quadraticBezierTo(w, 0, w, h * 0.15)
      ..quadraticBezierTo(w, h * 0.28, w * 0.8, h * 0.28)
      ..lineTo(w * 0.35, h * 0.28)
      ..lineTo(w * 0.35, h * 0.45)
      ..lineTo(w * 0.72, h * 0.45)
      ..quadraticBezierTo(w * 0.88, h * 0.45, w * 0.88, h * 0.58)
      ..quadraticBezierTo(w * 0.88, h * 0.7, w * 0.72, h * 0.7)
      ..lineTo(w * 0.35, h * 0.7)
      ..lineTo(w * 0.35, h * 0.88)
      ..quadraticBezierTo(w * 0.35, h, w * 0.18, h)
      ..quadraticBezierTo(0, h, 0, h * 0.88)
      ..close();

    canvas.drawPath(path1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
