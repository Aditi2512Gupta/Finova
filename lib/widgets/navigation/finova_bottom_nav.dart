import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FinovaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FinovaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, "Home"),
      (Icons.account_balance_wallet_rounded, "Wallets"),
      (Icons.receipt_long_rounded, "Transactions"),
      (Icons.bar_chart_rounded, "Analytics"),
      (Icons.person_rounded, "Profile"),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 74,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.all(8),
                    padding: EdgeInsets.symmetric(
                      horizontal: selected ? 14 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withOpacity(.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[index].$1,
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade500,
                        ),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          child: selected
                              ? Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Text(
                                      items[index].$2,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}