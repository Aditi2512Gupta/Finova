import 'package:flutter/material.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final double income;
  final double expense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool hideBalance = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff4C1D95), Color(0xff6D28D9), Color(0xff8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(.35),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Total Balance",
                style: TextStyle(color: Colors.white70, fontSize: 17),
              ),

              const Spacer(),

              IconButton(
                splashRadius: 20,
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    hideBalance = !hideBalance;
                  });
                },
                icon: Icon(
                  hideBalance ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Text(
              hideBalance
                  ? "₹ •••••••"
                  : "₹ ${widget.balance.toStringAsFixed(2)}",
              key: ValueKey(hideBalance),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 42,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 36),

          Row(
            children: [
              Expanded(
                child: _infoTile(
                  "Income",
                  widget.income,
                  Icons.south_rounded,
                  Colors.greenAccent,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _infoTile(
                  "Expense",
                  widget.expense,
                  Icons.north_rounded,
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  "₹${amount.toStringAsFixed(0)}",
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
