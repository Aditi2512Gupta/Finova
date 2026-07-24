import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/transaction_service.dart';
import '../../services/wallet_service.dart';
import '../../services/category_service.dart';
import '../../models/transaction_model.dart';
import '../../models/wallet_model.dart';
import '../../models/category_model.dart';
import '../../services/receipt_ai_service.dart';
import '../../services/gemini_service.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  File? _image;
  bool _isScanning = false;
  final ImagePicker _picker = ImagePicker();
  final TransactionService _transactionService = TransactionService();
  final WalletService _walletService = WalletService();
  final CategoryService _categoryService = CategoryService();
  final ReceiptAIService _receiptAI = ReceiptAIService();

  final GeminiService _gemini = GeminiService();

  String _ocrText = "";

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _receiptAI.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage(ImageSource source) async {
  //   try {
  //     final pickedFile = await _picker.pickImage(source: source);
  //     if (pickedFile != null) {
  //       setState(() {
  //         _image = File(pickedFile.path);
  //         _isScanning = true;
  //       });
  //       _runReceiptOCR();
  //     }
  //   } catch (e) {
  //     debugPrint("Error picking image: $e");
  //   }
  // }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile == null) {
        return;
      }

      setState(() {
        _image = File(pickedFile.path);
        _isScanning = true;
      });

      _runReceiptOCR();
    } catch (e, stackTrace) {
      debugPrint("IMAGE PICKER ERROR: $e");
      debugPrint(stackTrace.toString());

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Camera Error: $e")));
      }
    }
  }

  Future<void> _runReceiptOCR() async {
    try {
      final text = await _receiptAI.extractText(_image!);
      _ocrText = text;

      if (text.trim().isEmpty) {
        throw Exception(
          "Couldn't detect any text.\nPlease capture a clearer receipt.",
        );
      }

      final result = await _gemini.analyzeReceipt(text);

      int confidence = 0;

      if ((result["merchant"] ?? "").toString().isNotEmpty) confidence += 25;

      if ((result["amount"] ?? 0) != 0) confidence += 25;

      if ((result["category"] ?? "").toString().isNotEmpty) confidence += 25;

      if ((result["items"] ?? []).isNotEmpty) confidence += 25;

      setState(() {
        _isScanning = false;
      });

      _showOCRResultDialog(
        (result["amount"] as num).toDouble(),
        result["merchant"] ?? "Unknown Merchant",
        DateTime.parse(result["date"]),
        result["category"] ?? "Other",
        List<String>.from(result["items"] ?? []),
        result["paymentMethod"] ?? "Unknown",
        confidence,
      );
    } catch (e) {
      setState(() {
        _isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Receipt scanning failed.\n${e.toString()}"),
        ),
      );
    }
  }

  void _showOCRResultDialog(
    double amount,
    String merchant,
    DateTime date,
    String predictedCategory,
    List<String> items,
    String paymentMethod,
    int confidence,
  ) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Fetch wallets and categories for association
    List<WalletModel> wallets = [];
    List<CategoryModel> categories = [];
    try {
      wallets = await _walletService.getWallets().first;
      categories = await _categoryService.getCategories().first;
    } catch (e) {
      debugPrint("Error loading options: $e");
    }

    String? selectedWalletId = wallets.isNotEmpty ? wallets.first.id : null;
    String? selectedCategoryId;

    if (categories.isNotEmpty) {
      final match = categories.where(
        (c) => c.name.toLowerCase() == predictedCategory.toLowerCase(),
      );

      if (match.isNotEmpty) {
        selectedCategoryId = match.first.id;
      } else {
        selectedCategoryId = categories.first.id;
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: themeProvider.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Colors.green,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Receipt Scanned!",
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: confidence >= 75
                          ? Colors.green.withOpacity(0.15)
                          : Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          confidence >= 75
                              ? Icons.verified
                              : Icons.warning_amber_rounded,
                          color: confidence >= 75
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            confidence >= 75
                                ? "High confidence extraction ($confidence%)"
                                : "Please verify the extracted information ($confidence%)",
                            style: TextStyle(
                              color: themeProvider.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "We auto-detected the following transaction details from your receipt:",
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildOCRField("Merchant", merchant, themeProvider),
                    _buildOCRField(
                      "Amount",
                      "₹${amount.toStringAsFixed(0)}",
                      themeProvider,
                    ),
                    _buildOCRField(
                      "Date",
                      "${date.day}/${date.month}/${date.year}",
                      themeProvider,
                    ),

                    const SizedBox(height: 14),

                    Divider(color: themeProvider.borderColor),

                    const SizedBox(height: 14),

                    Text(
                      "Receipt Summary",
                      style: TextStyle(
                        color: themeProvider.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Outfit',
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildOCRField("Payment", paymentMethod, themeProvider),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Items",
                            style: TextStyle(
                              color: themeProvider.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            items.isEmpty
                                ? "No items detected"
                                : items.map((e) => "• $e").join("\n"),
                            style: TextStyle(color: themeProvider.textPrimary),
                          ),
                        ],
                      ),
                    ),

                    ExpansionTile(
                      title: const Text("View Extracted OCR Text"),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(_ocrText),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: themeProvider.borderColor),
                    const SizedBox(height: 12),

                    // Wallet selection
                    Text(
                      "Select Wallet",
                      style: TextStyle(
                        color: themeProvider.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: themeProvider.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedWalletId,
                          isExpanded: true,
                          dropdownColor: themeProvider.surfaceColor,
                          items: wallets.map((w) {
                            return DropdownMenuItem(
                              value: w.id,
                              child: Text(
                                w.name,
                                style: TextStyle(
                                  color: themeProvider.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              selectedWalletId = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category selection
                    Text(
                      "Select Category",
                      style: TextStyle(
                        color: themeProvider.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: themeProvider.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategoryId,
                          isExpanded: true,
                          dropdownColor: themeProvider.surfaceColor,
                          items: categories.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                c.name,
                                style: TextStyle(
                                  color: themeProvider.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              selectedCategoryId = val;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _image = null;
                    });
                  },
                  child: Text(
                    "Discard",
                    style: TextStyle(color: themeProvider.textSecondary),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedWalletId == null ||
                        selectedCategoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select wallet and category"),
                        ),
                      );
                      return;
                    }

                    // Save transaction to Firebase
                    final transaction = TransactionModel(
                      id: FirebaseFirestore.instance
                          .collection('users')
                          .doc()
                          .id,
                      title: merchant,
                      amount: amount,
                      type: 'Expense',
                      date: date,
                      walletId: selectedWalletId!,
                      categoryId: selectedCategoryId!,
                      note: 'Auto-detected via Finova Receipt Scan',
                      isRecurring: false,
                      recurrence: '',
                      nextOccurrence: null,
                      createdAt: Timestamp.now(),
                    );

                    await _transactionService.addTransaction(transaction);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Scanned expense added successfully!"),
                        ),
                      );
                      Navigator.pop(context); // Go back to Home
                    }
                  },
                  child: const Text("Save Expense"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOCRField(String label, String value, ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black, // Dark camera screen feeling
      body: Stack(
        children: [
          // Viewfinder background
          Positioned.fill(
            child: _image == null
                ? Container(
                    color: const Color(0xFF111115),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 80,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Position receipt inside the scanner",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 15,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Image.file(_image!, fit: BoxFit.cover),
          ),

          // Viewfinder focus border overlay
          if (!_isScanning && _image == null)
            Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),

          // Scanner laser line effect
          if (_isScanning)
            AnimatedBuilder(
              animation: _scannerController,
              builder: (context, child) {
                final height = MediaQuery.of(context).size.height;
                final topOffset =
                    _scannerController.value * (height * 0.7) + (height * 0.15);
                return Positioned(
                  top: topOffset,
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.primaryColor,
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Dark overlay while scanning
          if (_isScanning)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          themeProvider.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Analyzing Receipt OCR...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Extracting merchant, date & amounts",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Header
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  "Receipt Scanner",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(width: 48), // Spacer to balance back button
              ],
            ),
          ),

          // Bottom Control Buttons
          if (!_isScanning)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Pick from gallery button
                    IconButton(
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      icon: const Icon(Icons.photo_library_rounded),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.camera),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Guide/Help icon
                    IconButton(
                      iconSize: 28,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      icon: const Icon(Icons.info_outline_rounded),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: themeProvider.surfaceColor,
                            title: Text(
                              "Scanner Tips",
                              style: TextStyle(
                                color: themeProvider.textPrimary,
                              ),
                            ),
                            content: Text(
                              "Hold the receipt flat and capture it in bright lighting. The OCR scanner automatically reads the total amount, date, and items.",
                              style: TextStyle(
                                color: themeProvider.textSecondary,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Got it"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
