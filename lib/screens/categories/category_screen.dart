import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/theme_provider.dart';
import '../../models/category_model.dart';
import '../../services/category_service.dart';
import '../../services/budget_service.dart';
import '../../models/budget_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService _categoryService = CategoryService();
  final BudgetService _budgetService = BudgetService();
  String _selectedFilter = "Expense"; // "Expense" or "Income"

  void _showAddCategorySheet() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final nameController = TextEditingController();
    String type = "Expense";
    int selectedColorValue = 0xFF6C4CF1;
    IconData selectedIcon = Icons.folder_rounded;

    final colorOptions = [
      0xFF6C4CF1, // Purple
      0xFFEF4444, // Red
      0xFF10B981, // Green
      0xFF3B82F6, // Blue
      0xFFF59E0B, // Orange
      0xFFEC4899, // Pink
      0xFF06B6D4, // Cyan
      0xFF8B5CF6, // Violet
    ];

    final iconOptions = [
      Icons.restaurant_rounded,
      Icons.local_taxi_rounded,
      Icons.shopping_bag_rounded,
      Icons.receipt_rounded,
      Icons.payments_rounded,
      Icons.smart_toy_rounded,
      Icons.flight_takeoff_rounded,
      Icons.school_rounded,
      Icons.health_and_safety_rounded,
      Icons.sports_esports_rounded,
    ];

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
                MediaQuery.of(context).viewInsets.bottom +
                    MediaQuery.of(context).padding.bottom +
                    24,
              ),
              decoration: BoxDecoration(
                color: themeProvider.surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add Custom Category",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      TextField(
                        controller: nameController,
                        style: TextStyle(color: themeProvider.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Category Name",
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
                      const SizedBox(height: 20),

                      // Type (Income/Expense)
                      Row(
                        children: [
                          Text(
                            "Type:  ",
                            style: TextStyle(
                              color: themeProvider.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ChoiceChip(
                            label: const Text("Expense"),
                            selected: type == "Expense",
                            selectedColor: themeProvider.primaryColor,
                            labelStyle: TextStyle(
                              color: type == "Expense"
                                  ? Colors.white
                                  : themeProvider.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => type = "Expense");
                            },
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: const Text("Income"),
                            selected: type == "Income",
                            selectedColor: themeProvider.primaryColor,
                            labelStyle: TextStyle(
                              color: type == "Income"
                                  ? Colors.white
                                  : themeProvider.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => type = "Income");
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Color selection
                      Text(
                        "Theme Color",
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: colorOptions.map((colVal) {
                          final isSelected = selectedColorValue == colVal;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => selectedColorValue = colVal);
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(colVal),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? themeProvider.textPrimary
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Icon selection
                      Text(
                        "Category Icon",
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: iconOptions.map((iconData) {
                          final isSelected = selectedIcon == iconData;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() => selectedIcon = iconData);
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(
                                        selectedColorValue,
                                      ).withOpacity(0.15)
                                    : themeProvider.backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(selectedColorValue)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                iconData,
                                color: isSelected
                                    ? Color(selectedColorValue)
                                    : themeProvider.textSecondary,
                                size: 20,
                              ),
                            ),
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
                            final name = nameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter a category name"),
                                ),
                              );
                              return;
                            }

                            final newCat = CategoryModel(
                              id: const Uuid().v4(),
                              name: name,
                              type: type,
                              color: selectedColorValue,
                              icon: selectedIcon.codePoint,
                              createdAt: Timestamp.now(),
                            );

                            await _categoryService.addCategory(newCat);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Custom Category added!"),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Add Category",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
    );
  }

  void _showBudgetDialog(CategoryModel category) {
    final controller = TextEditingController();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: themeProvider.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            "Budget for ${category.name}",
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Set a monthly limit for this category to track and control expenses.",
                style: TextStyle(
                  color: themeProvider.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: themeProvider.textPrimary),
                decoration: InputDecoration(
                  prefixText: "Rs. ",
                  prefixStyle: TextStyle(
                    color: themeProvider.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: "0.00",
                  hintStyle: TextStyle(color: themeProvider.textSecondary.withOpacity(0.5)),
                  filled: true,
                  fillColor: themeProvider.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: themeProvider.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final amount = double.tryParse(controller.text.trim());

                if (amount == null || amount <= 0) {
                  return;
                }

                await _budgetService.saveCategoryBudget(
                  categoryId: category.id,
                  amount: amount,
                );

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Categories",
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
      body: StreamBuilder<List<CategoryModel>>(
        stream: _categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final allCategories = snapshot.data ?? [];

          // Make sure default categories are seeded if Firestore is clean
          if (allCategories.isEmpty) {
            _categoryService.seedDefaultCategories();
          }

          final filtered = allCategories
              .where((c) => c.type == _selectedFilter)
              .toList();

          return Column(
            children: [
              // Segmented selection row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: themeProvider.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: themeProvider.borderColor),
                  ),
                  child: Row(
                    children: [
                      // Expense Toggle
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = "Expense";
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedFilter == "Expense"
                                  ? themeProvider.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                "Expenses",
                                style: TextStyle(
                                  color: _selectedFilter == "Expense"
                                      ? Colors.white
                                      : themeProvider.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Income Toggle
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = "Income";
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedFilter == "Income"
                                  ? themeProvider.primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                "Incomes",
                                style: TextStyle(
                                  color: _selectedFilter == "Income"
                                      ? Colors.white
                                      : themeProvider.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Grid
              Expanded(
                child: StreamBuilder<Map<String, BudgetModel>>(
                  stream: _budgetService.getCategoryBudgets(),
                  builder: (context, budgetSnapshot) {
                    final budgets = budgetSnapshot.data ?? {};

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          "No categories found for $_selectedFilter",
                          style: TextStyle(color: themeProvider.textSecondary),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.15,
                          ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final cat = filtered[index];
                        final budget = budgets[cat.id];
                        final catColor = Color(cat.color);

                        return Dismissible(
                          key: Key(cat.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) async {
                            // Don't allow deleting default core categories
                            final isDefault = [
                              "food",
                              "travel",
                              "shopping",
                              "bills",
                              "salary",
                              "freelancing",
                              "gift",
                              "investment",
                              "savings",
                            ].contains(cat.id);
                            if (isDefault) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Cannot delete core system categories!",
                                  ),
                                ),
                              );
                              return false;
                            }
                            return true;
                          },
                          onDismissed: (_) async {
                            await _categoryService.deleteCategory(cat.id);
                          },
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _showBudgetDialog(cat);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: themeProvider.surfaceColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: catColor.withOpacity(0.22),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.01),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: catColor.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          IconData(
                                            cat.icon,
                                            fontFamily: 'MaterialIcons',
                                          ),
                                          color: catColor,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            cat.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: themeProvider.textPrimary,
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            budget == null
                                                ? "No Budget"
                                                : "Rs. ${budget.amount.toStringAsFixed(0)}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: budget == null
                                                  ? themeProvider.textSecondary
                                                  : catColor,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themeProvider.primaryColor,
        onPressed: _showAddCategorySheet,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
