import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import '../../models/wallet_model.dart';
import '../../services/wallet_service.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  final WalletService _walletService = WalletService();

  Map<String, CategoryModel> _categoryMap = {};
  Map<String, WalletModel> _walletMap = {};
  bool _loading = true;

  String _searchQuery = "";
  String _selectedType = "All"; // All, Income, Expense
  String? _selectedCategoryId;
  String? _selectedWalletId;

  @override
  void initState() {
    super.initState();
    _loadFiltersData();
  }

  Future<void> _loadFiltersData() async {
    final catMap = await _categoryService.getCategoryMap();
    final walMap = await _walletService.getWalletMap();
    if (mounted) {
      setState(() {
        _categoryMap = catMap;
        _walletMap = walMap;
        _loading = false;
      });
    }
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return "Today";
    } else if (checkDate == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat("dd MMM yyyy").format(date);
    }
  }

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.payment_rounded;
    final lower = categoryName.toLowerCase();
    if (lower.contains("food") || lower.contains("swiggy") || lower.contains("restaurant") || lower.contains("dine")) {
      return Icons.restaurant_rounded;
    } else if (lower.contains("salary") || lower.contains("income") || lower.contains("pay")) {
      return Icons.payments_rounded;
    } else if (lower.contains("shopping") || lower.contains("clothes") || lower.contains("store")) {
      return Icons.shopping_bag_rounded;
    } else if (lower.contains("bill") || lower.contains("recharge") || lower.contains("electricity")) {
      return Icons.receipt_rounded;
    } else if (lower.contains("travel") || lower.contains("cab") || lower.contains("taxi") || lower.contains("uber")) {
      return Icons.local_taxi_rounded;
    } else if (lower.contains("education") || lower.contains("school")) {
      return Icons.school_rounded;
    } else if (lower.contains("health") || lower.contains("medic")) {
      return Icons.health_and_safety_rounded;
    }
    return Icons.widgets_rounded;
  }

  Color _getCategoryColor(String? categoryName) {
    if (categoryName == null) return Colors.blueGrey;
    final lower = categoryName.toLowerCase();
    if (lower.contains("food") || lower.contains("swiggy")) {
      return const Color(0xFFFF5E57); // Coral Red
    } else if (lower.contains("salary") || lower.contains("income")) {
      return const Color(0xFF26DE81); // Mint Green
    } else if (lower.contains("shopping")) {
      return const Color(0xFFA55EEA); // Orchid Purple
    } else if (lower.contains("bill")) {
      return const Color(0xFFFF9F43); // Amber Orange
    } else if (lower.contains("travel")) {
      return const Color(0xFF00A8FF); // Electric Cyan
    } else if (lower.contains("education") || lower.contains("school")) {
      return const Color(0xFF4B7BEC); // Royal Blue
    } else if (lower.contains("health") || lower.contains("medic")) {
      return const Color(0xFFE84393); // Warm Pink
    }
    return const Color(0xFF5F27CD); // Deep Purple
  }

  void _showTransactionDetails(BuildContext context, TransactionModel t) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final category = _categoryMap[t.categoryId];
    final wallet = _walletMap[t.walletId];
    final isIncome = t.type == "Income";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: themeProvider.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title and amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        t.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                    Text(
                      "${isIncome ? "+" : "-"}${NumberFormat.currency(locale: 'en_IN', symbol: "₹", decimalDigits: 0).format(t.amount)}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Transaction parameters
                _buildDetailRow(Icons.calendar_today_rounded, "Date", DateFormat("dd MMM yyyy, hh:mm a").format(t.date), themeProvider),
                const SizedBox(height: 14),
                _buildDetailRow(Icons.category_rounded, "Category", category?.name ?? "General", themeProvider),
                const SizedBox(height: 14),
                _buildDetailRow(Icons.account_balance_wallet_rounded, "Wallet", wallet?.name ?? "Default Wallet", themeProvider),
                const SizedBox(height: 14),
                if (t.note.isNotEmpty) ...[
                  _buildDetailRow(Icons.notes_rounded, "Note", t.note, themeProvider),
                  const SizedBox(height: 14),
                ],
                if (t.isRecurring) ...[
                  _buildDetailRow(Icons.replay_rounded, "Recurrence", "${t.recurrence} payment", themeProvider),
                  const SizedBox(height: 14),
                ],

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 20),

                // Edit and Delete buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: themeProvider.borderColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(transaction: t),
                            ),
                          ).then((_) => _loadFiltersData());
                        },
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: Text("Edit", style: TextStyle(color: themeProvider.textPrimary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: themeProvider.surfaceColor,
                              title: const Text("Delete Transaction", style: TextStyle(fontWeight: FontWeight.bold)),
                              content: const Text("Are you sure you want to delete this transaction permanently?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text("Cancel", style: TextStyle(color: themeProvider.textSecondary)),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await _transactionService.deleteTransaction(t);
                            if (context.mounted) {
                              Navigator.pop(context); // Close details sheet
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Transaction deleted successfully")),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_rounded, size: 18),
                        label: const Text("Delete"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String val, ThemeProvider theme) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.textSecondary.withOpacity(0.7)),
        const SizedBox(width: 12),
        Text(
          "$title:",
          style: TextStyle(color: theme.textSecondary, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            val,
            textAlign: TextAlign.end,
            style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14.5),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Transactions Log",
          style: TextStyle(color: themeProvider.textPrimary, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: themeProvider.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    style: TextStyle(color: themeProvider.textPrimary),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search title or notes...",
                      hintStyle: TextStyle(color: themeProvider.textSecondary.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.search_rounded, color: themeProvider.textSecondary),
                      filled: true,
                      fillColor: themeProvider.surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: themeProvider.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: themeProvider.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: themeProvider.primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                // Type filter chips (All, Income, Expense)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ["All", "Income", "Expense"].map((t) {
                      final isSelected = _selectedType == t;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(t),
                            selected: isSelected,
                            selectedColor: themeProvider.primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : themeProvider.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedType = t;
                                });
                              }
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Filter dropdown selections
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      // Category Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: themeProvider.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: themeProvider.borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: Text("Category", style: TextStyle(color: themeProvider.textSecondary, fontSize: 13)),
                              value: _selectedCategoryId,
                              dropdownColor: themeProvider.surfaceColor,
                              icon: Icon(Icons.arrow_drop_down, color: themeProvider.textPrimary),
                              onChanged: (val) {
                                setState(() {
                                  _selectedCategoryId = val;
                                });
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("All Categories", style: TextStyle(color: themeProvider.textPrimary)),
                                ),
                                ..._categoryMap.values.map((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat.id,
                                    child: Text(cat.name, style: TextStyle(color: themeProvider.textPrimary)),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Wallet Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: themeProvider.surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: themeProvider.borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: Text("Wallet", style: TextStyle(color: themeProvider.textSecondary, fontSize: 13)),
                              value: _selectedWalletId,
                              dropdownColor: themeProvider.surfaceColor,
                              icon: Icon(Icons.arrow_drop_down, color: themeProvider.textPrimary),
                              onChanged: (val) {
                                setState(() {
                                  _selectedWalletId = val;
                                });
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("All Wallets", style: TextStyle(color: themeProvider.textPrimary)),
                                ),
                                ..._walletMap.values.map((wal) {
                                  return DropdownMenuItem<String>(
                                    value: wal.id,
                                    child: Text(wal.name, style: TextStyle(color: themeProvider.textPrimary)),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Transactions query list
                Expanded(
                  child: StreamBuilder<List<TransactionModel>>(
                    stream: _transactionService.getTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final all = snapshot.data ?? [];

                      // Apply search, type, category, and wallet filters
                      final filtered = all.where((t) {
                        final matchesSearch = t.title.toLowerCase().contains(_searchQuery) ||
                            t.note.toLowerCase().contains(_searchQuery);
                        final matchesType = _selectedType == "All" || t.type == _selectedType;
                        final matchesCat = _selectedCategoryId == null || t.categoryId == _selectedCategoryId;
                        final matchesWal = _selectedWalletId == null || t.walletId == _selectedWalletId;

                        return matchesSearch && matchesType && matchesCat && matchesWal;
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text(
                            "No transactions found matching filters",
                            style: TextStyle(color: themeProvider.textSecondary, fontFamily: 'Outfit'),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final t = filtered[index];
                          final isIncome = t.type == "Income";
                          final category = _categoryMap[t.categoryId];
                          final categoryName = category?.name ?? "General";
                          final wallet = _walletMap[t.walletId];
                          final walletName = wallet?.name ?? "Default Wallet";
                          
                          final catColor = category != null ? Color(category.color) : _getCategoryColor(categoryName);
                          final catIcon = category != null ? IconData(category.icon, fontFamily: 'MaterialIcons') : _getCategoryIcon(categoryName);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: themeProvider.surfaceColor,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: themeProvider.borderColor),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              onTap: () => _showTransactionDetails(context, t),
                              leading: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.22),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Icon(catIcon, color: catColor, size: 22),
                                ),
                              ),
                              title: Text(
                                t.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.textPrimary,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: themeProvider.backgroundColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        categoryName,
                                        style: TextStyle(fontSize: 10, color: themeProvider.textSecondary, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.account_balance_wallet_outlined, size: 11, color: themeProvider.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      walletName,
                                      style: TextStyle(fontSize: 11, color: themeProvider.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${isIncome ? "+" : "-"}${NumberFormat.currency(locale: 'en_IN', symbol: "₹", decimalDigits: 0).format(t.amount)}",
                                    style: TextStyle(
                                      color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.5,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatRelativeDate(t.date),
                                    style: TextStyle(fontSize: 11, color: themeProvider.textSecondary),
                                  ),
                                ],
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
    );
  }
}
