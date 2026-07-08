import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'settings_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final SettingsService _settingsService = SettingsService();

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await notifications.initialize(settings);

    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<bool> _privacyEnabled() async {
    return await _settingsService.getNotificationPrivacy();
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'finova_channel',
      'Finova Notifications',
      channelDescription: 'Notifications from Finova',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // =============================
  // Recurring Transaction
  // =============================
  Future<void> showRecurringTransaction({
    required String title,
    required double amount,
  }) async {
    final privacy = await _privacyEnabled();

    await showNotification(
      title: "Recurring Transaction",
      body: privacy
          ? "A scheduled payment has been processed."
          : "₹${amount.toStringAsFixed(0)} paid for $title.",
    );
  }

  // =============================
  // Goal Completed
  // =============================
  Future<void> showGoalCompleted({required String goalName}) async {
    final privacy = await _privacyEnabled();

    await showNotification(
      title: "Goal Completed 🎉",
      body: privacy
          ? "One of your savings goals has been completed."
          : "Congratulations! You've completed '$goalName'.",
    );
  }

  // =============================
  // Low Wallet Balance
  // =============================
  Future<void> showLowWalletBalance({
    required String walletName,
    required double balance,
  }) async {
    final privacy = await _privacyEnabled();

    await showNotification(
      title: "Low Wallet Balance",
      body: privacy
          ? "One of your wallets has a low balance."
          : "$walletName balance is only ₹${balance.toStringAsFixed(0)}.",
    );
  }

  // =============================
  // Budget Alerts
  // =============================

  Future<void> showBudget80Percent({required String category}) async {
    final privacy = await _privacyEnabled();

    await showNotification(
      title: "⚠️ Budget Alert",
      body: privacy
          ? "One of your budgets requires attention."
          : "You've used 80% of your $category budget.",
    );
  }

  Future<void> showBudgetReached({required String category}) async {
    final privacy = await _privacyEnabled();

    await showNotification(
      title: "🚨 Budget Reached",
      body: privacy
          ? "One of your budgets requires attention."
          : "You've reached your $category budget.",
    );
  }

  Future<void> showBudgetExceeded({
    required String category,
    required double exceededAmount,
  }) async {
    final privacy = await _privacyEnabled();

    await showNotification(
      title: "❌ Budget Exceeded",
      body: privacy
          ? "One of your budgets requires attention."
          : "$category budget exceeded by ₹${exceededAmount.toStringAsFixed(0)}.",
    );
  }

  Future<void> showUpcomingRecurringReminder({
    required String title,
    required double amount,
  }) async {
    final privacy = await _privacyEnabled();

    await showNotification(
      title: "Upcoming Payment",
      body: privacy
          ? "A scheduled payment is due tomorrow."
          : "$title payment of ₹${amount.toStringAsFixed(0)} is due tomorrow.",
    );
  }
}
