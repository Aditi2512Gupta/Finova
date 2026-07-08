import 'package:flutter/material.dart';

class FloatingAddButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingAddButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xff7C3AED),
              Color(0xff5B4DFF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff7C3AED).withOpacity(.45),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 34,
          color: Colors.white,
        ),
      ),
    );
  }
}