import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/goal_model.dart';
import '../../services/goal_service.dart';
import '../../services/wallet_service.dart';
import '../../services/transaction_service.dart';
import '../../models/wallet_model.dart';
import '../../models/transaction_model.dart';
import 'package:uuid/uuid.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalService _goalService = GoalService();
  final WalletService _walletService = WalletService();
  final TransactionService _transactionService = TransactionService();

  void _showAddGoalBottomSheet() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? selectedDate;
    String selectedCategory = 'General';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Savings Goal",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Goal Title
                    TextField(
                      controller: titleController,
                      style: TextStyle(color: themeProvider.textPrimary),
                      decoration: InputDecoration(
                        hintText: "E.g., Tesla Model 3, New Macbook Pro",
                        hintStyle: TextStyle(
                          color: themeProvider.textSecondary.withOpacity(0.6),
                        ),
                        labelText: "Goal Name",
                        labelStyle: TextStyle(
                          color: themeProvider.textSecondary,
                        ),
                        filled: true,
                        fillColor: themeProvider.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Target Amount
                    TextField(
                      controller: amountController,
                      style: TextStyle(color: themeProvider.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "E.g., 50000",
                        hintStyle: TextStyle(
                          color: themeProvider.textSecondary.withOpacity(0.6),
                        ),
                        labelText: "Target Amount (₹)",
                        labelStyle: TextStyle(
                          color: themeProvider.textSecondary,
                        ),
                        prefixText: "₹ ",
                        prefixStyle: TextStyle(
                          color: themeProvider.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: themeProvider.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker Trigger
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 10),
                          ),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: themeProvider.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate == null
                                  ? "Target Date"
                                  : DateFormat(
                                      'dd MMM yyyy',
                                    ).format(selectedDate!),
                              style: TextStyle(
                                color: selectedDate == null
                                    ? themeProvider.textSecondary
                                    : themeProvider.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_rounded,
                              color: themeProvider.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Selection
                    Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          [
                            'General',
                            'Travel',
                            'Tech',
                            'Vehicle',
                            'Home',
                            'Education',
                          ].map((cat) {
                            final isSelected = selectedCategory == cat;
                            return ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: themeProvider.primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : themeProvider.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() {
                                    selectedCategory = cat;
                                  });
                                }
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: themeProvider.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final amount =
                              double.tryParse(amountController.text.trim()) ??
                              0.0;

                          if (title.isEmpty ||
                              amount <= 0.0 ||
                              selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill in all details"),
                              ),
                            );
                            return;
                          }

                          final goal = GoalModel(
                            id: '',
                            title: title,
                            targetAmount: amount,
                            currentAmount: 0.0,
                            targetDate: selectedDate!,
                            category: selectedCategory,
                          );

                          await _goalService.addGoal(goal);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Savings Goal created successfully!",
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          "Create Goal",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddFundsDialog(GoalModel goal) async {
    final wallets = await _walletService.getWalletList();

    if (!mounted) return;

    if (wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please create a wallet first.")),
      );
      return;
    }

    WalletModel selectedWallet = wallets.first;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Add Funds to ${goal.title}"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<WalletModel>(
                    value: selectedWallet,
                    decoration: const InputDecoration(
                      labelText: "Select Wallet",
                    ),
                    items: wallets.map((wallet) {
                      return DropdownMenuItem(
                        value: wallet,
                        child: Text(
                          "${wallet.name} (₹${wallet.balance.toStringAsFixed(0)})",
                        ),
                      );
                    }).toList(),
                    onChanged: (wallet) {
                      if (wallet != null) {
                        setDialogState(() {
                          selectedWallet = wallet;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                FilledButton(
                  onPressed: () async {
                    final amount =
                        double.tryParse(amountController.text.trim()) ?? 0;

                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter a valid amount.")),
                      );
                      return;
                    }

                    if (amount > selectedWallet.balance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Insufficient wallet balance."),
                        ),
                      );
                      return;
                    }

                    final transaction = TransactionModel(
                      id: const Uuid().v4(),
                      title: "Transfer to ${goal.title}",
                      amount: amount,
                      type: "Expense",
                      categoryId: "savings",
                      walletId: selectedWallet.id,
                      date: DateTime.now(),
                      note: "Savings Goal Transfer",
                      isRecurring: false,
                      recurrence: "",
                      nextOccurrence: null,
                      createdAt: Timestamp.now(),
                    );

                    // Deduct money from wallet (handled automatically)
                    await _transactionService.addTransaction(transaction);

                    // Add money to goal
                    await _goalService.addMoneyToGoal(goal.id, amount);

                    if (mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "₹${amount.toStringAsFixed(0)} transferred to ${goal.title}",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Transfer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWithdrawFundsDialog(GoalModel goal) async {
    final wallets = await _walletService.getWalletList();

    if (!mounted) return;

    if (wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please create a wallet first.")),
      );
      return;
    }

    WalletModel selectedWallet = wallets.first;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Withdraw from ${goal.title}"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<WalletModel>(
                    value: selectedWallet,
                    decoration: const InputDecoration(
                      labelText: "Select Wallet",
                    ),
                    items: wallets.map((wallet) {
                      return DropdownMenuItem(
                        value: wallet,
                        child: Text(
                          "${wallet.name} (₹${wallet.balance.toStringAsFixed(0)})",
                        ),
                      );
                    }).toList(),
                    onChanged: (wallet) {
                      if (wallet != null) {
                        setDialogState(() {
                          selectedWallet = wallet;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                FilledButton(
                  onPressed: () async {
                    final amount =
                        double.tryParse(amountController.text.trim()) ?? 0;

                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter a valid amount.")),
                      );
                      return;
                    }

                    if (amount > goal.currentAmount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Not enough money saved in this goal."),
                        ),
                      );
                      return;
                    }

                    final transaction = TransactionModel(
                      id: const Uuid().v4(),
                      title: "Withdraw from ${goal.title}",
                      amount: amount,
                      type: "Income",
                      categoryId: "savings",
                      walletId: selectedWallet.id,
                      date: DateTime.now(),
                      note: "Savings Goal Withdrawal",
                      isRecurring: false,
                      recurrence: "",
                      nextOccurrence: null,
                      createdAt: Timestamp.now(),
                    );

                    // Deduct money from wallet (handled automatically)
                    await _transactionService.addTransaction(transaction);

                    // Withdraw money from goal
                    await _goalService.withdrawMoneyFromGoal(goal.id, amount);

                    if (mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "₹${amount.toStringAsFixed(0)} withdrawn from ${goal.title}",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Transfer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Travel':
        return Icons.flight_takeoff_rounded;
      case 'Tech':
        return Icons.laptop_mac_rounded;
      case 'Vehicle':
        return Icons.directions_car_filled_rounded;
      case 'Home':
        return Icons.home_work_rounded;
      case 'Education':
        return Icons.school_rounded;
      default:
        return Icons.savings_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Savings Goals",
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: themeProvider.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<GoalModel>>(
        stream: _goalService.getGoals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final goals = snapshot.data ?? [];

          if (goals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: themeProvider.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.track_changes_rounded,
                        size: 50,
                        color: themeProvider.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "No Savings Goals Yet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Define your goals (e.g., travel plans, electronics) and save money towards them.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: themeProvider.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _showAddGoalBottomSheet,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        "Create First Goal",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final progress = (goal.currentAmount / goal.targetAmount).clamp(
                0.0,
                1.0,
              );
              final pct = (progress * 100).toInt();
              final completed = goal.currentAmount >= goal.targetAmount;

              return Dismissible(
                key: Key(goal.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: themeProvider.surfaceColor,
                      title: Text(
                        "Delete Goal",
                        style: TextStyle(color: themeProvider.textPrimary),
                      ),
                      content: Text(
                        "Are you sure you want to delete this savings goal?",
                        style: TextStyle(color: themeProvider.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: themeProvider.textSecondary,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  await _goalService.deleteGoal(goal.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Goal '${goal.title}' deleted")),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: themeProvider.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: themeProvider.primaryColor
                                .withOpacity(0.12),
                            foregroundColor: themeProvider.primaryColor,
                            child: Icon(_getCategoryIcon(goal.category)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Target: ${DateFormat('dd MMM yyyy').format(goal.targetDate)}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeProvider.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            completed ? "Completed 🎉" : "$pct%",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: themeProvider.backgroundColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completed
                                ? Colors.green
                                : themeProvider.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Amounts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹${goal.currentAmount.toStringAsFixed(0)} saved",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textPrimary,
                            ),
                          ),
                          Text(
                            "Target: ₹${goal.targetAmount.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 13,
                              color: themeProvider.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // 👇 Show only when goal is completed
                      if (completed)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Goal Achieved!",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Fund action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: completed
                                      ? Colors.grey
                                      : themeProvider.primaryColor.withOpacity(
                                          0.5,
                                        ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: completed
                                  ? null
                                  : () => _showAddFundsDialog(goal),
                              icon: Icon(
                                completed
                                    ? Icons.check_circle
                                    : Icons.add_circle_outline_rounded,
                                size: 18,
                                color: completed
                                    ? Colors.grey
                                    : themeProvider.primaryColor,
                              ),
                              label: Text(
                                completed ? "Completed" : "Add Funds",
                                style: TextStyle(
                                  color: completed
                                      ? Colors.grey
                                      : themeProvider.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: themeProvider.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _showWithdrawFundsDialog(goal),
                              icon: const Icon(
                                Icons.south_west_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Withdraw",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeProvider.primaryColor,
        onPressed: _showAddGoalBottomSheet,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
