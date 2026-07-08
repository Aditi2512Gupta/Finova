import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_service.dart';

class AddWalletScreen extends StatefulWidget {
  final WalletModel? wallet;

  const AddWalletScreen({
    super.key,
    this.wallet,
  });

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  final WalletService _walletService = WalletService();
  final Uuid uuid = const Uuid();

  String walletType = "Cash";

  final List<String> walletTypes = [
    "Cash",
    "Bank",
    "UPI",
    "Credit Card",
  ];

  int selectedColorValue = 0xFF2196F3;

  final List<Color> premiumColors = const [
    Color(0xFF2196F3), // Classic Blue
    Color(0xFF6C4CF1), // Purple (Default)
    Color(0xFF00ACC1), // Cyan/Teal
    Color(0xFF10B981), // Emerald Green
    Color(0xFFFF9800), // Orange/Amber
    Color(0xFFE91E63), // Pink/Crimson
    Color(0xFF860038), // Axis Maroon
    Color(0xFF4B5563), // Charcoal Grey
  ];

  @override
  void initState() {
    super.initState();

    if (widget.wallet != null) {
      nameController.text = widget.wallet!.name;
      balanceController.text = widget.wallet!.balance.toString();
      walletType = widget.wallet!.type;
      selectedColorValue = widget.wallet!.color;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  Future<void> saveWallet() async {
    if (nameController.text.trim().isEmpty ||
        balanceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    try {
      final wallet = WalletModel(
        id: widget.wallet?.id ?? uuid.v4(),
        name: nameController.text.trim(),
        type: walletType,
        balance: double.parse(balanceController.text.trim()),
        color: selectedColorValue,
        icon: widget.wallet?.icon ?? Icons.account_balance_wallet.codePoint,
        createdAt: widget.wallet?.createdAt ?? Timestamp.now(),
      );

      if (widget.wallet == null) {
        await _walletService.addWallet(wallet);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Wallet Added Successfully"),
            ),
          );
        }
      } else {
        await _walletService.updateWallet(wallet);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Wallet Updated Successfully"),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: themeProvider.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.wallet == null ? "Add Wallet" : "Edit Wallet",
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Title and Description
              Text(
                widget.wallet == null ? "Create a New Wallet" : "Edit Wallet details",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                  fontFamily: 'Outfit',
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Manage your money by organizing it into different wallets.",
                style: TextStyle(
                  color: themeProvider.textSecondary,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              // Form Box Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeProvider.surfaceColor,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: themeProvider.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet Name Field
                    Text(
                      "Wallet Name",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: themeProvider.textPrimary),
                      decoration: InputDecoration(
                        hintText: "e.g. SBI Savings Bank",
                        hintStyle: TextStyle(color: themeProvider.textSecondary.withOpacity(0.35)),
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: themeProvider.textSecondary, size: 20),
                        filled: true,
                        fillColor: themeProvider.backgroundColor.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeProvider.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeProvider.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeProvider.primaryColor, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Wallet Type Dropdown Field
                    Text(
                      "Wallet Type",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: walletType,
                      dropdownColor: themeProvider.surfaceColor,
                      style: TextStyle(color: themeProvider.textPrimary, fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined, color: themeProvider.textSecondary, size: 20),
                        filled: true,
                        fillColor: themeProvider.backgroundColor.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeProvider.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeProvider.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeProvider.primaryColor, width: 1.5),
                        ),
                      ),
                      items: walletTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          walletType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Initial Balance Field
                    Text(
                      "Initial Balance",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: themeProvider.textPrimary),
                      decoration: InputDecoration(
                        hintText: "0.00",
                        hintStyle: TextStyle(color: themeProvider.textSecondary.withOpacity(0.35)),
                        prefixIcon: Icon(Icons.currency_rupee_rounded, color: themeProvider.textSecondary, size: 20),
                        filled: true,
                        fillColor: themeProvider.backgroundColor.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeProvider.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeProvider.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: themeProvider.primaryColor, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Card Color Picker
                    Text(
                      "Card Color",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: premiumColors.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final color = premiumColors[index];
                          final isSelected = selectedColorValue == color.value;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColorValue = color.value;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: themeProvider.textPrimary,
                                        width: 2.5,
                                      )
                                    : Border.all(
                                        color: Colors.white.withOpacity(0.15),
                                        width: 1,
                                      ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: color.computeLuminance() < 0.5
                                          ? Colors.white
                                          : Colors.black,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Save Wallet Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: themeProvider.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: saveWallet,
                  child: Text(
                    widget.wallet == null ? "Save Wallet" : "Update Wallet",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}