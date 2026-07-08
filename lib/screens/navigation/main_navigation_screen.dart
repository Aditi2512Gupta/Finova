import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../analytics/analytics_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../wallet/wallet_screen.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/navigation/finova_navigation.dart';
import '../../widgets/navigation/add_menu_sheet.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    final List<Widget> pages = [
      const HomeScreen(),
      WalletScreen(),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          pages[navProvider.currentIndex],

          Align(
            alignment: Alignment.bottomCenter,
            child: FinovaNavigation(
              currentIndex: navProvider.currentIndex,
              onChanged: (index) {
                navProvider.setTab(index);
              },
              onAdd: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddMenuSheet(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
