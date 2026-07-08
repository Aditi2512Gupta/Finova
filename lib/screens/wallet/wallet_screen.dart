import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_service.dart';
import 'add_wallet_screen.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({super.key});

  final WalletService walletService = WalletService();

  LinearGradient _getWalletGradient(String name, int colorValue) {
    final lower = name.toLowerCase();

    // If the color is not the default blue, prioritize the user's custom color choice
    if (colorValue != 0xFF2196F3) {
      final baseColor = Color(colorValue);
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(0.85),
          baseColor,
          baseColor.withOpacity(0.7),
        ],
      );
    }

    // Default branding colors based on bank name keywords (fallback when using default blue)
    if (lower.contains("hdfc")) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF3F1D96),
          Color(0xFF6C4CF1),
          Color(0xFF8B5CF6),
        ],
      );
    } else if (lower.contains("icici")) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E3A8A),
          Color(0xFF3B82F6),
          Color(0xFF60A5FA),
        ],
      );
    } else if (lower.contains("axis")) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF4A001B),
          Color(0xFF860038),
          Color(0xFFA20044),
        ],
      );
    } else if (lower.contains("canara")) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF007CC3),
          Color(0xFF00A896),
          Color(0xFF02C39A),
        ],
      );
    } else if (lower.contains("sbi") || lower.contains("state bank")) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0A4F9E),
          Color(0xFF007CC3),
          Color(0xFF48A6E3),
        ],
      );
    } else if (lower.contains("cash")) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF047857),
          Color(0xFF10B981),
          Color(0xFF34D399),
        ],
      );
    } else {
      final baseColor = Color(colorValue);
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(0.85),
          baseColor,
          baseColor.withOpacity(0.7),
        ],
      );
    }
  }

  IconData _getWalletIcon(String name, int iconCode) {
    final lower = name.toLowerCase();
    if (lower.contains("hdfc") || lower.contains("icici") || lower.contains("bank")) {
      return Icons.account_balance_rounded;
    } else if (lower.contains("cash")) {
      return Icons.payments_rounded;
    }
    return Icons.account_balance_wallet_rounded;
  }

  String _getMockCardNumber(String id) {
    // Generate a consistent mock card number (last 4 digits) using id's hashCode
    final numStr = id.hashCode.abs().toString();
    final digits = numStr.length >= 4 ? numStr.substring(numStr.length - 4) : "8824";
    return "**** $digits";
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Wallets",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: themeProvider.textPrimary,
                      fontFamily: 'Outfit',
                      letterSpacing: -0.6,
                    ),
                  ),
                  
                  // Capsule "+ Add" Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddWalletScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeProvider.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.primaryColor.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Wallets list
              Expanded(
                child: StreamBuilder<List<WalletModel>>(
                  stream: walletService.getWallets(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }

                    final wallets = snapshot.data ?? [];

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: wallets.length + 1, // Add 1 for the bottom "+ Add New Wallet" card
                      itemBuilder: (context, index) {
                        // Dotted add wallet button card at the end of the list
                        if (index == wallets.length) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddWalletScreen()),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 8, bottom: 24),
                              height: 90,
                              decoration: BoxDecoration(
                                color: themeProvider.surfaceColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: themeProvider.borderColor,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.01),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: CustomPaint(
                                painter: _DashedRectPainter(color: themeProvider.textSecondary.withOpacity(0.4)),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: themeProvider.textSecondary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.add_rounded,
                                            color: themeProvider.textSecondary,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "Add New Wallet",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: themeProvider.textSecondary,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final wallet = wallets[index];
                        final walletGradient = _getWalletGradient(wallet.name, wallet.color);
                        final walletIcon = _getWalletIcon(wallet.name, wallet.icon);
                        final cardNo = _getMockCardNumber(wallet.id);

                        return Dismissible(
                          key: Key(wallet.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            final hasTransactions = await walletService.hasTransactions(wallet.id);
                            if (hasTransactions) {
                              if (context.mounted) {
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: themeProvider.surfaceColor,
                                    title: Text("Cannot Delete Wallet", style: TextStyle(color: themeProvider.textPrimary)),
                                    content: Text(
                                      "This wallet contains transactions.\n\nDelete those transactions first.",
                                      style: TextStyle(color: themeProvider.textSecondary),
                                    ),
                                    actions: [
                                      FilledButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return false;
                            }

                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: themeProvider.surfaceColor,
                                title: Text("Delete Wallet", style: TextStyle(color: themeProvider.textPrimary)),
                                content: Text("Are you sure you want to delete this wallet?", style: TextStyle(color: themeProvider.textSecondary)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text("Cancel", style: TextStyle(color: themeProvider.textSecondary)),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            ) ?? false;
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                          ),
                          onDismissed: (_) async {
                            await walletService.deleteWallet(wallet);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${wallet.name} deleted")),
                              );
                            }
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddWalletScreen(wallet: wallet),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              height: 128,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: walletGradient,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: walletGradient.colors.first.withOpacity(0.3),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                  width: 1.5,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Shading design bubble
                                  Positioned(
                                    right: -20,
                                    bottom: -20,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.04),
                                      ),
                                    ),
                                  ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // White icon container
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.16),
                                                borderRadius: BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.2),
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  walletIcon,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    wallet.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Outfit',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    wallet.type,
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.65),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Amount on the right top
                                            Text(
                                              NumberFormat.currency(
                                                locale: 'en_IN',
                                                symbol: "₹",
                                                decimalDigits: 0,
                                              ).format(wallet.balance),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Outfit',
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const Spacer(),
                                        
                                        // Mock card number
                                        Text(
                                          cardNo,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.5,
                                            fontFamily: 'Courier',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dash rect painter for "+ Add New Wallet" border styling
class _DashedRectPainter extends CustomPainter {
  final Color color;

  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    );
    
    // Draw dashed rrect
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
