import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/budget_service.dart';
import '../../services/firestore_service.dart';
import '../../services/ai_health_service.dart';
import '../../models/user_model.dart';
import '../categories/category_screen.dart';
import '../ai/ai_coach_screen.dart';
import '../auth/login_screen.dart';
import '../../services/settings_service.dart';
import '../../services/export_service.dart';
import '../../services/transaction_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final SettingsService _settingsService = SettingsService();
  final ExportService _exportService = ExportService();
  final TransactionService _transactionService = TransactionService();

  bool _notificationPrivacy = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _notificationPrivacy = await _settingsService.getNotificationPrivacy();

    if (mounted) {
      setState(() {});
    }
  }

  void _showAccentColorBottomSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                Text(
                  "Choose Accent Color",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Select a theme color for cards, indicators & navigation highlight.",
                  style: TextStyle(
                    color: themeProvider.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),

                // Color circles row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(themeProvider.accentColors.length, (
                    index,
                  ) {
                    final color = themeProvider.accentColors[index];
                    final isSelected = themeProvider.accentIndex == index;

                    return GestureDetector(
                      onTap: () {
                        themeProvider.setAccentColor(index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? themeProvider.textPrimary
                                : Colors.transparent,
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final budgetService = BudgetService();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: themeProvider.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "Set Monthly Budget",
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              hintText: "Enter budget limit",
              prefixText: "₹ ",
              prefixStyle: TextStyle(color: themeProvider.textPrimary),
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: themeProvider.textSecondary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
              ),
              onPressed: () async {
                final amount = double.tryParse(controller.text.trim()) ?? 0;
                if (amount > 0) {
                  await budgetService.saveBudget(amount);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Monthly budget updated successfully!"),
                      ),
                    );
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final controller = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: themeProvider.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "Edit Profile Name",
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: themeProvider.textPrimary),
            decoration: InputDecoration(
              labelText: "Display Name",
              labelStyle: TextStyle(color: themeProvider.textSecondary),
              filled: true,
              fillColor: themeProvider.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: themeProvider.textSecondary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: themeProvider.primaryColor,
              ),
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  final updatedUser = UserModel(
                    uid: user.uid,
                    name: newName,
                    email: user.email,
                    totalBalance: user.totalBalance,
                    financialHealthScore: user.financialHealthScore,
                    createdAt: user.createdAt,
                  );
                  await _firestoreService.saveUser(updatedUser);
                  try {
                    await FirebaseAuth.instance.currentUser?.updateDisplayName(
                      newName,
                    );
                  } catch (e) {
                    debugPrint("Auth display name error: $e");
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {}); // Trigger refresh
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Name updated successfully!"),
                      ),
                    );
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showExportDataDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: themeProvider.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            "Export Transactions",
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Outfit',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Export your complete transaction history in your preferred format.",
                style: TextStyle(
                  color: themeProvider.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // PDF Card
                  _buildExportFormatButton(
                    context,
                    format: "PDF Document",
                    icon: Icons.picture_as_pdf_rounded,
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.pop(dialogCtx);
                      _exportPDF();
                    },
                  ),
                  // CSV Card
                  _buildExportFormatButton(
                    context,
                    format: "Excel / CSV",
                    icon: Icons.table_chart_rounded,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(dialogCtx);
                      _exportCSV();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportFormatButton(
    BuildContext context, {
    required String format,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: themeProvider.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: themeProvider.borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 10),
            Text(
              format,
              style: TextStyle(
                color: themeProvider.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPDF() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: themeProvider.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Preparing PDF..."),
          ],
        ),
      ),
    );

    try {
      final transactions = await _transactionService.getTransactions().first;
      final uid = FirebaseAuth.instance.currentUser?.uid ?? "";
      final userModel = await _firestoreService.getUser(uid);

      final totalIncome = transactions
          .where((t) => t.type == "Income")
          .fold(0.0, (sum, t) => sum + t.amount);
      final totalExpense = transactions
          .where((t) => t.type == "Expense")
          .fold(0.0, (sum, t) => sum + t.amount);
      final budgetLimit = await BudgetService().getBudget().first;

      final healthScore = AIHealthService().calculateScore(
        income: totalIncome,
        expense: totalExpense,
        completedGoals: 0,
        totalGoals: 0,
        exceededBudgets: totalExpense > budgetLimit ? 1 : 0,
      );

      if (mounted) Navigator.pop(context);

      await _exportService.sharePDF(
        transactions: transactions,
        themePrimaryColor: themeProvider.primaryColor,
        userName: userModel.name,
        financialHealthScore: healthScore,
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _exportCSV() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: themeProvider.surfaceColor,
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Preparing CSV..."),
          ],
        ),
      ),
    );

    try {
      final transactions = await _transactionService.getTransactions().first;

      if (mounted) Navigator.pop(context);

      await _exportService.exportCSV(transactions: transactions);
    } catch (e) {
      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<UserModel>(
          future: _firestoreService.getUser(userUid),
          builder: (context, snapshot) {
            final userModel =
                snapshot.data ??
                UserModel(
                  uid: userUid,
                  name:
                      FirebaseAuth.instance.currentUser?.displayName ??
                      "Finova User",
                  email:
                      FirebaseAuth.instance.currentUser?.email ??
                      "user@finova.com",
                  totalBalance: 0,
                  financialHealthScore: 100,
                  createdAt: DateTime.now(),
                );

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
              children: [
                // Header Profile Banner Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        themeProvider.primaryColor.withOpacity(0.08),
                        themeProvider.primaryColor.withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: themeProvider.borderColor),
                  ),
                  child: Row(
                    children: [
                      // Avatar (Dynamic letter initials with brand gradient)
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              themeProvider.primaryColor,
                              themeProvider.primaryColor.withOpacity(0.65),
                            ],
                          ),
                          border: Border.all(
                            color: themeProvider.primaryColor.withOpacity(0.4),
                            width: 2.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            userModel.name.isNotEmpty
                                ? userModel.name[0].toUpperCase()
                                : "U",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Username & Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userModel.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textPrimary,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              userModel.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: themeProvider.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit Pen icon (functional!)
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: themeProvider.surfaceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: themeProvider.borderColor),
                          ),
                        ),
                        icon: Icon(
                          Icons.edit_rounded,
                          color: themeProvider.textPrimary,
                          size: 16,
                        ),
                        onPressed: () {
                          _showEditProfileDialog(context, userModel);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Menu Items List Group
                _buildMenuGroup(
                  themeProvider,
                  title: "General Settings",
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Monthly Budget",
                      trailing: Text(
                        "Set Limit",
                        style: TextStyle(
                          color: themeProvider.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _showBudgetDialog(context),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.category_outlined,
                      title: "Categories Management",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.file_download_outlined,
                      title: "Export Transaction Data",
                      trailing: Text(
                        "PDF / CSV",
                        style: TextStyle(
                          color: themeProvider.textSecondary.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => _showExportDataDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                _buildMenuGroup(
                  themeProvider,
                  title: "Aesthetics",
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.palette_outlined,
                      title: "Accent Theme Color",
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: themeProvider.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: themeProvider.textSecondary.withOpacity(0.5),
                            size: 14,
                          ),
                        ],
                      ),
                      onTap: () => _showAccentColorBottomSheet(context),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.dark_mode_outlined,
                      title: "Dark Mode Status",
                      trailing: Switch(
                        activeColor: themeProvider.primaryColor,
                        value: themeProvider.isDarkMode,
                        onChanged: (val) {
                          themeProvider.toggleTheme();
                        },
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                _buildMenuGroup(
                  themeProvider,
                  title: "Notifications",
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.lock_outline,
                      title: "Privacy Mode",
                      trailing: Switch(
                        value: _notificationPrivacy,
                        activeColor: themeProvider.primaryColor,
                        onChanged: (value) async {
                          setState(() {
                            _notificationPrivacy = value;
                          });

                          await _settingsService.setNotificationPrivacy(value);
                        },
                      ),
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                // Logout Group
                _buildMenuGroup(
                  themeProvider,
                  title: "Account",
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.logout_rounded,
                      iconColor: Colors.redAccent,
                      title: "Logout Account",
                      titleColor: Colors.redAccent,
                      showArrow: false,
                      onTap: () async {
                        final logout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: themeProvider.surfaceColor,
                            title: Text(
                              "Logout",
                              style: TextStyle(
                                color: themeProvider.textPrimary,
                              ),
                            ),
                            content: Text(
                              "Are you sure you want to logout?",
                              style: TextStyle(
                                color: themeProvider.textSecondary,
                              ),
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
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                        );

                        if (logout == true) {
                          await AuthService().logout();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuGroup(
    ThemeProvider theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.textSecondary.withOpacity(0.7),
              letterSpacing: 0.8,
              fontFamily: 'Outfit',
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(children.length, (index) {
              final widget = children[index];
              return Column(
                children: [
                  widget,
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 52,
                      color: theme.borderColor,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String title,
    Color? titleColor,
    Widget? trailing,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final iColor = iconColor ?? themeProvider.textPrimary;
    final tColor = titleColor ?? themeProvider.textPrimary;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Icon(icon, color: iColor, size: 18)),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: tColor,
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          fontFamily: 'Outfit',
        ),
      ),
      trailing:
          trailing ??
          (showArrow
              ? Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: themeProvider.textSecondary.withOpacity(0.4),
                  size: 14,
                )
              : null),
    );
  }
}
