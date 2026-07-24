import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get categoryCollection =>
      _firestore.collection('users').doc(uid).collection('categories');

  // ============================
  // Add Category
  // ============================
  Future<void> addCategory(CategoryModel category) async {
    await categoryCollection.doc(category.id).set(category.toMap());
  }

  // ============================
  // Migrate Old Category Icons
  // ============================
  CategoryModel _migrateCategory(CategoryModel category) {
    const defaultCategoryIds = {
      "food",
      "travel",
      "shopping",
      "bills",
      "salary",
      "freelancing",
      "gift",
      "investment",
      "savings",
    };

    if (!defaultCategoryIds.contains(category.id)) {
      return category;
    }
    
    final lower = category.name.toLowerCase();
    int? targetColor;
    int? targetIcon;

    if (lower.contains("food") ||
        lower.contains("dine") ||
        lower.contains("restaurant") ||
        lower.contains("eat")) {
      targetColor = 0xFFFF5E57; // Coral Red
      targetIcon = Icons.restaurant.codePoint;
    } else if (lower.contains("travel") ||
        lower.contains("taxi") ||
        lower.contains("fuel") ||
        lower.contains("car") ||
        lower.contains("bus")) {
      targetColor = 0xFF00A8FF; // Electric Cyan
    } else if (lower.contains("shopping") ||
        lower.contains("cloth") ||
        lower.contains("store") ||
        lower.contains("grocer")) {
      targetColor = 0xFFA55EEA; // Orchid Purple
    } else if (lower.contains("bill") ||
        lower.contains("recharge") ||
        lower.contains("electric") ||
        lower.contains("water") ||
        lower.contains("gas")) {
      targetColor = 0xFFFF9F43; // Amber Orange
    } else if (lower.contains("education") ||
        lower.contains("school") ||
        lower.contains("book") ||
        lower.contains("fee") ||
        lower.contains("college")) {
      targetColor = 0xFF4B7BEC; // Royal Blue
    } else if (lower.contains("health") ||
        lower.contains("medic") ||
        lower.contains("doctor") ||
        lower.contains("hospital") ||
        lower.contains("fit")) {
      targetColor = 0xFFE84393; // Warm Pink
    } else if (lower.contains("salary") ||
        lower.contains("income") ||
        lower.contains("paycheck")) {
      targetColor = 0xFF26DE81; // Mint Green
    } else if (lower.contains("freelance") ||
        lower.contains("gig") ||
        lower.contains("work")) {
      targetColor = 0xFF0FB9B1; // Teal Green
    } else if (lower.contains("gift") || lower.contains("present")) {
      targetColor = 0xFFFFD200; // Sun Yellow
    } else if (lower.contains("invest") ||
        lower.contains("stock") ||
        lower.contains("mut") ||
        lower.contains("fund")) {
      targetColor = 0xFF5F27CD; // Deep Purple
    }

    if (targetColor != null || targetIcon != null) {
      final updatedColor = targetColor ?? category.color;
      final updatedIcon = targetIcon ?? category.icon;

      if (category.color != updatedColor || category.icon != updatedIcon) {
        final migrated = CategoryModel(
          id: category.id,
          name: category.name,
          type: category.type,
          color: updatedColor,
          icon: updatedIcon,
          createdAt: category.createdAt,
        );

        // Update Firestore in the background to persist this correction
        categoryCollection
            .doc(category.id)
            .update({'color': updatedColor, 'icon': updatedIcon})
            .catchError((e) {
              debugPrint(
                "Failed to auto-migrate category ${category.name} in Firestore: $e",
              );
            });

        return migrated;
      }
    }

    return category;
  }

  // ============================
  // Read Categories
  // ============================
  Stream<List<CategoryModel>> getCategories() {
    return categoryCollection.orderBy("name").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => _migrateCategory(CategoryModel.fromMap(doc.data())))
          .toList();
    });
  }

  // ============================
  // Get Category List
  // ============================
  Future<List<CategoryModel>> getCategoryList() async {
    final snapshot = await categoryCollection.orderBy("name").get();

    return snapshot.docs
        .map((doc) => _migrateCategory(CategoryModel.fromMap(doc.data())))
        .toList();
  }

  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final snapshot = await categoryCollection.get();

    return snapshot.docs
        .where((doc) => doc["type"] == type)
        .map((doc) => _migrateCategory(CategoryModel.fromMap(doc.data())))
        .toList();
  }

  Future<Map<String, CategoryModel>> getCategoryMap() async {
    final snapshot = await categoryCollection.get();

    final Map<String, CategoryModel> map = {};

    for (final doc in snapshot.docs) {
      final category = _migrateCategory(CategoryModel.fromMap(doc.data()));
      map[category.id] = category;
    }

    return map;
  }

  // ============================
  // Update Category
  // ============================
  Future<void> updateCategory(CategoryModel category) async {
    await categoryCollection.doc(category.id).update(category.toMap());
  }

  // ============================
  // Delete Category
  // ============================
  Future<void> deleteCategory(String categoryId) async {
    await categoryCollection.doc(categoryId).delete();
  }

  // ============================
  // Default Categories
  // ============================
  Future<void> seedDefaultCategories() async {
    final snapshot = await categoryCollection.get();

    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final categories = [
      CategoryModel(
        id: "food",
        name: "Food",
        type: "Expense",
        color: 0xFFFF5E57, // Coral Red
        icon: Icons.restaurant.codePoint,
        createdAt: Timestamp.now(),
      ),
      CategoryModel(
        id: "travel",
        name: "Travel",
        type: "Expense",
        color: 0xFF00A8FF, // Electric Cyan
        icon: 0xe071,
        createdAt: Timestamp.now(),
      ),
      CategoryModel(
        id: "shopping",
        name: "Shopping",
        type: "Expense",
        color: 0xFFA55EEA, // Orchid Purple
        icon: 0xe59c,
        createdAt: Timestamp.now(),
      ),
      CategoryModel(
        id: "bills",
        name: "Bills",
        type: "Expense",
        color: 0xFFFF9F43, // Amber Orange
        icon: 0xe0b0,
        createdAt: Timestamp.now(),
      ),
      CategoryModel(
        id: "salary",
        name: "Salary",
        type: "Income",
        color: 0xFF26DE81, // Mint Green
        icon: 0xe227,
        createdAt: Timestamp.now(),
      ),
      CategoryModel(
        id: "freelancing",
        name: "Freelancing",
        type: "Income",
        color: 0xFF0FB9B1, // Teal Green
        icon: 0xe80c,
        createdAt: Timestamp.now(),
      ),
      CategoryModel(
        id: "gift",
        name: "Gift",
        type: "Income",
        color: 0xFFFFD200, // Sun Yellow
        icon: 0xe87d,
        createdAt: Timestamp.now(),
      ),
      CategoryModel(
        id: "investment",
        name: "Investment",
        type: "Income",
        color: 0xFF5F27CD, // Deep Purple
        icon: 0xe263,
        createdAt: Timestamp.now(),
      ),
      CategoryModel(
        id: "savings",
        name: "Savings",
        type: "Expense",
        color: 0xFF00C853,
        icon: Icons.savings.codePoint,
        createdAt: Timestamp.now(),
      ),
    ];

    for (final category in categories) {
      await categoryCollection.doc(category.id).set(category.toMap());
    }
  }
}
