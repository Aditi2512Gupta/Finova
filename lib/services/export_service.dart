import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart' as flutter_material;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/transaction_model.dart';
import 'category_service.dart';
import 'wallet_service.dart';

class ExportService {
  final CategoryService _categoryService = CategoryService();
  final WalletService _walletService = WalletService();

  Future<File> exportCSV({required List<TransactionModel> transactions}) async {
    final categoryMap = await _categoryService.getCategoryMap();
    final walletMap = await _walletService.getWalletMap();

    List<List<dynamic>> rows = [];

    rows.add([
      "Date",
      "Title",
      "Category",
      "Wallet",
      "Type",
      "Amount",
      "Recurring",
      "Note",
    ]);

    for (final t in transactions) {
      rows.add([
        "${t.date.day}/${t.date.month}/${t.date.year}",
        t.title,
        categoryMap[t.categoryId]?.name ?? "Unknown",
        walletMap[t.walletId]?.name ?? "Unknown",
        t.type,
        t.amount,
        t.isRecurring ? "Yes" : "No",
        t.note,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();

    final file = File("${directory.path}/Finova_Report.csv");

    await file.writeAsString(csv);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: "Finova Transaction Report");

    return file;
  }

  PdfColor _lightenColor(PdfColor color, double factor) {
    return PdfColor(
      color.red + (1.0 - color.red) * factor,
      color.green + (1.0 - color.green) * factor,
      color.blue + (1.0 - color.blue) * factor,
    );
  }

  Future<File> buildPDF({
    required List<TransactionModel> transactions,
    flutter_material.Color? themePrimaryColor,
    String? userName,
    int? financialHealthScore,
  }) async {
    final categoryMap = await _categoryService.getCategoryMap();
    final walletMap = await _walletService.getWalletMap();
    final pdf = pw.Document();

    final accentColor =
        themePrimaryColor ?? const flutter_material.Color(0xFF8B5CF6);
    final primaryPdfColor = PdfColor.fromInt(accentColor.value);
    final textPrimaryColor = PdfColor.fromHex('#1F2937'); // Gray 800
    final textSecondaryColor = PdfColor.fromHex('#6B7280'); // Gray 500
    final cardBgColor = PdfColor.fromHex('#F9FAFB'); // Gray 50
    final clientName = userName ?? "Finova Client";
    final healthScore = financialHealthScore ?? 95;

    double totalIncome = 0;
    double totalExpense = 0;

    for (final t in transactions) {
      if (t.type == "Income") {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }
    double netSavings = totalIncome - totalExpense;

    // Table rows building
    final List<pw.TableRow> tableRows = [];

    // Header Table Row
    tableRows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: primaryPdfColor,
          borderRadius: const pw.BorderRadius.vertical(
            top: pw.Radius.circular(6),
          ),
        ),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              "Date",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              "Description",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              "Category",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              "Wallet",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              "Type",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              "Amount",
              style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );

    // Data Table Rows
    for (int i = 0; i < transactions.length; i++) {
      final t = transactions[i];
      final catName = categoryMap[t.categoryId]?.name ?? "General";
      final walletName = walletMap[t.walletId]?.name ?? "General";
      final dateStr =
          "${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year}";
      final isEven = i % 2 == 0;
      final isIncome = t.type == "Income";

      tableRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isEven ? PdfColors.white : PdfColor.fromHex('#F3F4F6'),
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              child: pw.Text(dateStr, style: const pw.TextStyle(fontSize: 8.5)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              child: pw.Text(t.title, style: const pw.TextStyle(fontSize: 8.5)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              child: pw.Text(catName, style: const pw.TextStyle(fontSize: 8.5)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              child: pw.Text(
                walletName,
                style: const pw.TextStyle(fontSize: 8.5),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              child: pw.Text(
                t.type,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: isIncome
                      ? PdfColor.fromHex('#10B981')
                      : PdfColor.fromHex('#EF4444'),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              child: pw.Text(
                "Rs. ${t.amount.toStringAsFixed(2)}",
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: isIncome
                      ? PdfColor.fromHex('#10B981')
                      : PdfColor.fromHex('#EF4444'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "FINOVA",
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryPdfColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "Smarter Wealth Management Insights",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        clientName,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        "Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1.5, color: primaryPdfColor),
              pw.SizedBox(height: 16),
            ],
          );
        },
        build: (context) {
          return [
            // Dashboard Metrics block
            pw.Row(
              children: [
                // Net Savings Box
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: cardBgColor,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(10),
                      ),
                      border: pw.Border.all(color: PdfColors.grey200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "NET SAVINGS",
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: textSecondaryColor,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Rs. ${netSavings.toStringAsFixed(2)}",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: netSavings >= 0
                                ? PdfColor.fromHex('#10B981')
                                : PdfColor.fromHex('#EF4444'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),

                // Income Box
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: cardBgColor,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(10),
                      ),
                      border: pw.Border.all(color: PdfColors.grey200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "TOTAL INCOME",
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: textSecondaryColor,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Rs. ${totalIncome.toStringAsFixed(2)}",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#10B981'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),

                // Expense Box
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: cardBgColor,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(10),
                      ),
                      border: pw.Border.all(color: PdfColors.grey200),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "TOTAL EXPENSE",
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: textSecondaryColor,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "Rs. ${totalExpense.toStringAsFixed(2)}",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#EF4444'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),

                // Health Box
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: _lightenColor(primaryPdfColor, 0.92),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(10),
                      ),
                      border: pw.Border.all(
                        color: _lightenColor(primaryPdfColor, 0.8),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "FINANCIAL HEALTH",
                          style: pw.TextStyle(
                            fontSize: 8,
                            color: primaryPdfColor,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          "$healthScore/100",
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryPdfColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 24),

            // Ledger Title
            pw.Text(
              "TRANSACTION HISTORY LEDGER",
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            pw.SizedBox(height: 10),

            // Ledger Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
              children: tableRows,
            ),
          ];
        },
        footer: (context) {
          return pw.Column(
            children: [
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Confidential Financial Document • Prepared with Finova",
                    style: const pw.TextStyle(
                      fontSize: 7.5,
                      color: PdfColors.grey400,
                    ),
                  ),
                  pw.Text(
                    "Page ${context.pageNumber} of ${context.pagesCount}",
                    style: const pw.TextStyle(
                      fontSize: 7.5,
                      color: PdfColors.grey400,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();

    final file = File(
      "${directory.path}/Finova_Report_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  Future<void> previewPDF({
    required List<TransactionModel> transactions,
    flutter_material.Color? themePrimaryColor,
    String? userName,
    int? financialHealthScore,
  }) async {
    final file = await buildPDF(
      transactions: transactions,
      themePrimaryColor: themePrimaryColor,
      userName: userName,
      financialHealthScore: financialHealthScore,
    );

    await Printing.layoutPdf(onLayout: (_) async => file.readAsBytes());
  }

  Future<void> sharePDF({
    required List<TransactionModel> transactions,
    flutter_material.Color? themePrimaryColor,
    String? userName,
    int? financialHealthScore,
  }) async {
    final file = await buildPDF(
      transactions: transactions,
      themePrimaryColor: themePrimaryColor,
      userName: userName,
      financialHealthScore: financialHealthScore,
    );

    await Share.shareXFiles([
      XFile(file.path),
    ], text: "Finova Financial Report");
  }
}
