import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'analytics_screen.dart';
import 'user_profile.dart';
import 'settings_screen.dart';
import '../theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  // ✅ Lazy loading screens (FIXED)
  Widget getScreen() {
    switch (currentIndex) {
      case 0:
        return const Dashboard();
      case 1:
        return const AnalyticsScreen();
      case 2:
        return const UserProfileScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const Dashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ Only builds current screen
      body: getScreen(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        selectedItemColor: isDarkMode ? AppColors.accent : AppColors.primary,
        unselectedItemColor: isDarkMode
            ? AppColors.textHint
            : AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Analytics",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
