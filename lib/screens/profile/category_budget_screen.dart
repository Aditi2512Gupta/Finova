import 'package:flutter/material.dart';

import '../../models/budget_model.dart';
import '../../models/category_model.dart';
import '../../services/budget_service.dart';
import '../../services/category_service.dart';

class CategoryBudgetScreen extends StatefulWidget {
  const CategoryBudgetScreen({super.key});

  @override
  State<CategoryBudgetScreen> createState() => _CategoryBudgetScreenState();
}

class _CategoryBudgetScreenState extends State<CategoryBudgetScreen> {
  final CategoryService categoryService = CategoryService();
  final BudgetService budgetService = BudgetService();

  List<CategoryModel> categories = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    categories = await categoryService.getCategoryList();

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void _showBudgetDialog({
    required String categoryId,
    required String categoryName,
    double? currentBudget,
  }) {
    final controller = TextEditingController(
      text: currentBudget?.toStringAsFixed(0) ?? "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Set Budget for $categoryName",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Budget Amount",
                  prefixText: "₹ ",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(controller.text.trim());

                    if (amount == null || amount <= 0) {
                      return;
                    }

                    await budgetService.saveCategoryBudget(
                      categoryId: categoryId,
                      amount: amount,
                    );

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Budget"),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Category Budgets",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<Map<String, BudgetModel>>(
              stream: budgetService.getCategoryBudgets(),
              builder: (context, snapshot) {
                final budgets = snapshot.data ?? {};

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    final budget = budgets[category.id];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(category.name[0])),

                        title: Text(category.name),

                        subtitle: Text(
                          budget == null
                              ? "No Budget Set"
                              : "Budget ₹${budget.amount.toStringAsFixed(0)}",
                        ),

                        trailing: FilledButton(
                          onPressed: () {
                            _showBudgetDialog(
                              categoryId: category.id,
                              categoryName: category.name,
                              currentBudget: budget?.amount,
                            );
                          },
                          child: Text(budget == null ? "Set Budget" : "Edit"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
