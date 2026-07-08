import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/analytics_period.dart';
import '../models/analytics_summary.dart';
import '../models/chart_data.dart';

import '../models/transaction_model.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get transactionCollection =>
      _firestore.collection("users").doc(uid).collection("transactions");

  Stream<List<TransactionModel>> getTransactions() {
    return transactionCollection
        .orderBy("date", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.data()))
              .toList(),
        );
  }

  List<TransactionModel> filterTransactions({
    required List<TransactionModel> transactions,
    required AnalyticsPeriod period,
    required DateTime selectedMonth,
    required String filterType,
  }) {
    final now = DateTime.now();

    List<TransactionModel> filtered = transactions;

    switch (period) {
      case AnalyticsPeriod.thisMonth:
        filtered = filtered
            .where((t) => t.date.month == now.month && t.date.year == now.year)
            .toList();
        break;

      case AnalyticsPeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1);

        filtered = filtered
            .where(
              (t) =>
                  t.date.month == lastMonth.month &&
                  t.date.year == lastMonth.year,
            )
            .toList();
        break;

      case AnalyticsPeriod.last3Months:
        final start = DateTime(now.year, now.month - 2);

        filtered = filtered
            .where(
              (t) => t.date.isAfter(start.subtract(const Duration(days: 1))),
            )
            .toList();
        break;

      case AnalyticsPeriod.last6Months:
        final start = DateTime(now.year, now.month - 5);

        filtered = filtered
            .where(
              (t) => t.date.isAfter(start.subtract(const Duration(days: 1))),
            )
            .toList();
        break;

      case AnalyticsPeriod.thisYear:
        filtered = filtered.where((t) => t.date.year == now.year).toList();
        break;

      case AnalyticsPeriod.customMonth:
        filtered = filtered
            .where(
              (t) =>
                  t.date.month == selectedMonth.month &&
                  t.date.year == selectedMonth.year,
            )
            .toList();
        break;
    }

    if (filterType != "All") {
      filtered = filtered.where((t) => t.type == filterType).toList();
    }

    return filtered;
  }

  List<TransactionModel> filterPreviousTransactions({
    required List<TransactionModel> transactions,
    required AnalyticsPeriod period,
    required DateTime selectedMonth,
    required String filterType,
  }) {
    DateTime start;
    DateTime end;

    switch (period) {
      case AnalyticsPeriod.thisMonth:
        start = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
        end = DateTime(DateTime.now().year, DateTime.now().month, 0);
        break;

      case AnalyticsPeriod.lastMonth:
        start = DateTime(DateTime.now().year, DateTime.now().month - 2, 1);
        end = DateTime(DateTime.now().year, DateTime.now().month - 1, 0);
        break;

      case AnalyticsPeriod.last3Months:
        start = DateTime(DateTime.now().year, DateTime.now().month - 5, 1);
        end = DateTime(DateTime.now().year, DateTime.now().month - 2, 0);
        break;

      case AnalyticsPeriod.last6Months:
        start = DateTime(DateTime.now().year, DateTime.now().month - 11, 1);
        end = DateTime(DateTime.now().year, DateTime.now().month - 5, 0);
        break;

      case AnalyticsPeriod.thisYear:
        start = DateTime(DateTime.now().year - 1, 1, 1);
        end = DateTime(DateTime.now().year - 1, 12, 31);
        break;

      case AnalyticsPeriod.customMonth:
        start = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);

        end = DateTime(selectedMonth.year, selectedMonth.month, 0);
        break;
    }

    List<TransactionModel> filtered = transactions.where((t) {
      return !t.date.isBefore(start) && !t.date.isAfter(end);
    }).toList();

    if (filterType != "All") {
      filtered = filtered.where((t) => t.type == filterType).toList();
    }

    return filtered;
  }

  List<ChartData> _monthlyData(
    List<TransactionModel> transactions,
    int months,
  ) {
    final now = DateTime.now();

    final labels = <String>[];
    final income = <double>[];
    final expense = <double>[];

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);

      labels.add(
        [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec",
        ][month.month - 1],
      );

      income.add(0);
      expense.add(0);
    }

    for (final t in transactions) {
      for (int i = 0; i < labels.length; i++) {
        final month = DateTime(now.year, now.month - (months - 1 - i));

        if (t.date.month == month.month && t.date.year == month.year) {
          if (t.type == "Income") {
            income[i] += t.amount;
          } else {
            expense[i] += t.amount;
          }
        }
      }
    }

    return List.generate(labels.length, (i) {
      return ChartData(
        label: labels[i],
        income: income[i],
        expense: expense[i],
      );
    });
  }

  List<ChartData> _yearlyData(List<TransactionModel> transactions) {
    final labels = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    final income = List.filled(12, 0.0);
    final expense = List.filled(12, 0.0);

    for (final t in transactions) {
      final month = t.date.month - 1;

      if (t.type == "Income") {
        income[month] += t.amount;
      } else {
        expense[month] += t.amount;
      }
    }

    return List.generate(12, (i) {
      return ChartData(
        label: labels[i],
        income: income[i],
        expense: expense[i],
      );
    });
  }

  List<ChartData> _weeklyData(List<TransactionModel> transactions) {
    final labels = ["W1", "W2", "W3", "W4", "W5"];

    final income = List.filled(5, 0.0);
    final expense = List.filled(5, 0.0);

    for (final t in transactions) {
      int week = ((t.date.day - 1) ~/ 7);

      if (week > 4) week = 4;

      if (t.type == "Income") {
        income[week] += t.amount;
      } else {
        expense[week] += t.amount;
      }
    }

    return List.generate(5, (i) {
      return ChartData(
        label: labels[i],
        income: income[i],
        expense: expense[i],
      );
    });
  }

  List<ChartData> buildChartData({
    required List<TransactionModel> transactions,
    required AnalyticsPeriod period,
    required DateTime selectedMonth,
  }) {
    switch (period) {
      case AnalyticsPeriod.thisMonth:
      case AnalyticsPeriod.lastMonth:
      case AnalyticsPeriod.customMonth:
        return _weeklyData(transactions);

      case AnalyticsPeriod.last3Months:
        return _monthlyData(transactions, 3);

      case AnalyticsPeriod.last6Months:
        return _monthlyData(transactions, 6);

      case AnalyticsPeriod.thisYear:
        return _yearlyData(transactions);
    }
  }

  AnalyticsSummary buildSummary({
    required List<TransactionModel> current,
    required List<TransactionModel> previous,
  }) {
    double currentIncome = 0;
    double currentExpense = 0;

    double previousIncome = 0;
    double previousExpense = 0;

    for (final t in current) {
      if (t.type == "Income") {
        currentIncome += t.amount;
      } else {
        currentExpense += t.amount;
      }
    }

    for (final t in previous) {
      if (t.type == "Income") {
        previousIncome += t.amount;
      } else {
        previousExpense += t.amount;
      }
    }

    final currentSavings = currentIncome - currentExpense;
    final previousSavings = previousIncome - previousExpense;

    double percent(double current, double previous) {
      if (previous == 0) return 0;
      return ((current - previous) / previous) * 100;
    }

    return AnalyticsSummary(
      income: currentIncome,
      expense: currentExpense,
      savings: currentSavings,
      incomeChange: percent(currentIncome, previousIncome),
      expenseChange: percent(currentExpense, previousExpense),
      savingsChange: percent(currentSavings, previousSavings),
    );
  }
}
