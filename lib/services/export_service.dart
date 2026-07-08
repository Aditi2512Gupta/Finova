import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/transaction_model.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'category_service.dart';
import 'wallet_service.dart';

class ExportService {
  final CategoryService _categoryService = CategoryService();
  final WalletService _walletService = WalletService();

  Future<void> exportPDF({required List<TransactionModel> transactions}) async {
    final categoryMap = await _categoryService.getCategoryMap();
    final walletMap = await _walletService.getWalletMap();
    final pdf = pw.Document();

    double totalIncome = 0;
    double totalExpense = 0;

    for (final t in transactions) {
      if (t.type == "Income") {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "FINOVA",
              style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Center(
            child: pw.Text(
              "Transaction Report",
              style: const pw.TextStyle(fontSize: 18),
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Center(
            child: pw.Text(
              "Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),

          pw.Divider(),

          pw.SizedBox(height: 15),

          pw.Table.fromTextArray(
            headers: const [
              "Date",
              "Title",
              "Category",
              "Wallet",
              "Type",
              "Amount",
            ],
            data: transactions.map((t) {
              return [
                "${t.date.day}/${t.date.month}/${t.date.year}",
                t.title,
                categoryMap[t.categoryId]?.name ?? "Unknown",
                walletMap[t.walletId]?.name ?? "Unknown",
                t.type,
                "₹${t.amount.toStringAsFixed(0)}",
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 30),

          pw.Text("Total Transactions : ${transactions.length}"),

          pw.SizedBox(height: 15),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Summary",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Text("Total Income : ₹${totalIncome.toStringAsFixed(0)}"),

                pw.Text("Total Expense : ₹${totalExpense.toStringAsFixed(0)}"),

                pw.Text(
                  "Net Savings : ₹${(totalIncome - totalExpense).toStringAsFixed(0)}",
                ),
              ],
            ),
          ),
        ],

        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Page ${context.pageNumber} of ${context.pagesCount}",
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

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
}
