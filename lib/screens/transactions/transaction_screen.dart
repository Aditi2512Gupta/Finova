import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/category_model.dart';
import '../../models/wallet_model.dart';
import '../../services/category_service.dart';
import '../../services/wallet_service.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import 'add_transaction_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String selectedFilter = "All";
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  final TransactionService transactionService = TransactionService();
  final CategoryService categoryService = CategoryService();
  final WalletService walletService = WalletService();

  Map<String, CategoryModel> categoryMap = {};
  Map<String, WalletModel> walletMap = {};

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    categoryMap = await categoryService.getCategoryMap();
    walletMap = await walletService.getWalletMap();

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transactions"), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<TransactionModel>>(
              stream: transactionService.getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No transactions yet.",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                List<TransactionModel> transactions = snapshot.data!;

                if (selectedFilter != "All") {
                  transactions = transactions
                      .where((e) => e.type == selectedFilter)
                      .toList();
                }

                if (searchQuery.isNotEmpty) {
                  transactions = transactions.where((transaction) {
                    final category =
                        categoryMap[transaction.categoryId]?.name
                            .toLowerCase() ??
                        "";

                    final wallet =
                        walletMap[transaction.walletId]?.name.toLowerCase() ??
                        "";

                    return transaction.title.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        ) ||
                        category.contains(searchQuery.toLowerCase()) ||
                        wallet.contains(searchQuery.toLowerCase());
                  }).toList();
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: "All", label: Text("All")),
                          ButtonSegment(value: "Income", label: Text("Income")),
                          ButtonSegment(
                            value: "Expense",
                            label: Text("Expense"),
                          ),
                        ],
                        selected: {selectedFilter},
                        onSelectionChanged: (value) {
                          setState(() {
                            selectedFilter = value.first;
                          });
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Search transactions...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];

                          final bool isIncome = transaction.type == "Income";

                          return Dismissible(
                            key: Key(transaction.id),
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Delete Transaction"),
                                      content: const Text(
                                        "Are you sure you want to delete this transaction?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) async {
                              await transactionService.deleteTransaction(
                                transaction,
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 3),
                                    content: Text(
                                      "${transaction.title} deleted",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.only(bottom: 14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddTransactionScreen(
                                        transaction: transaction,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: isIncome
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        child: Icon(
                                          isIncome
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: isIncome
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),

                                      const SizedBox(width: 14),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: Color(
                                                    categoryMap[transaction
                                                                .categoryId]
                                                            ?.color ??
                                                        Colors.grey.value,
                                                  ),
                                                  child: Icon(
                                                    IconData(
                                                      categoryMap[transaction
                                                                  .categoryId]
                                                              ?.icon ??
                                                          Icons
                                                              .category
                                                              .codePoint,
                                                      fontFamily:
                                                          'MaterialIcons',
                                                    ),
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),

                                                const SizedBox(width: 8),

                                                Expanded(
                                                  child: Text(
                                                    transaction.title,
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 4),

                                            Text(
                                              "${categoryMap[transaction.categoryId]?.name ?? "Unknown"} • "
                                              "${walletMap[transaction.walletId]?.name ?? "Unknown"}",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              DateFormat(
                                                "dd MMM yyyy",
                                              ).format(transaction.date),
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      Text(
                                        "${isIncome ? "+" : "-"}₹${transaction.amount.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          color: isIncome
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
      ),
    );
  }
}
