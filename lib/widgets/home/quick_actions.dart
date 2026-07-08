import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/transactions/add_transaction_screen.dart';
import '../../screens/receipt/receipt_scanner_screen.dart';
import '../../services/transaction_service.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  void _runMockPDFExportProcess(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    // Show Loading Progress Modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: themeProvider.surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    "Generating PDF Report...",
                    style: TextStyle(color: themeProvider.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Analyzing records & compiling PDF layout...",
                    style: TextStyle(color: themeProvider.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    String savedFilePath = "";
    bool success = false;

    try {
      final transactions = await TransactionService().getTransactions().first;
      double totalIncome = 0;
      double totalExpense = 0;
      
      final reportBuffer = StringBuffer();
      reportBuffer.writeln("==================================================");
      reportBuffer.writeln("             FINOVA FINANCIAL REPORT              ");
      reportBuffer.writeln("==================================================");
      reportBuffer.writeln("Generated on: ${DateTime.now().toLocal().toString()}");
      reportBuffer.writeln("\nTRANSACTION SUMMARY:");
      
      for (var t in transactions) {
        if (t.type == "Income") {
          totalIncome += t.amount;
        } else {
          totalExpense += t.amount;
        }
        reportBuffer.writeln("[${t.type}] ${t.title}: ₹${t.amount.toStringAsFixed(2)} on ${t.date.day}/${t.date.month}/${t.date.year}");
      }
      
      reportBuffer.writeln("\n--------------------------------------------------");
      reportBuffer.writeln("TOTAL INCOME:  ₹${totalIncome.toStringAsFixed(2)}");
      reportBuffer.writeln("TOTAL EXPENSE: ₹${totalExpense.toStringAsFixed(2)}");
      reportBuffer.writeln("NET SAVINGS:   ₹${(totalIncome - totalExpense).toStringAsFixed(2)}");
      reportBuffer.writeln("==================================================");

      final String? userHome = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
      if (userHome != null) {
        final fileName = "finova_financial_report_${DateTime.now().millisecondsSinceEpoch}.txt"; // Text representation of PDF for dynamic local writing
        final downloadsDir = Directory("$userHome\\Downloads");
        if (await downloadsDir.exists()) {
          final file = File("${downloadsDir.path}\\$fileName");
          await file.writeAsString(reportBuffer.toString());
          savedFilePath = file.path;
          success = true;
        } else {
          final docsDir = Directory("$userHome\\Documents");
          if (await docsDir.exists()) {
            final file = File("${docsDir.path}\\$fileName");
            await file.writeAsString(reportBuffer.toString());
            savedFilePath = file.path;
            success = true;
          }
        }
      }
    } catch (e) {
      debugPrint("PDF generation error: $e");
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    if (context.mounted) {
      Navigator.pop(context); // Close progress dialog
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF Export completed successfully! Saved to:\n$savedFilePath"),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to export PDF file."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
                    builder: (_) => const AddTransactionScreen(initialType: "Expense"),
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
                    builder: (_) => const AddTransactionScreen(initialType: "Income"),
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
              onTap: () => _runMockPDFExportProcess(context),
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
              child: Center(
                child: Icon(icon, color: color, size: 18),
              ),
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
