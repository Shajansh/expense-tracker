import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../utils/ip_currency_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  final List<String> currencies = const ["LKR", "INR", "USD", "EUR", "GBP"];

  Future<void> _autoDetectCurrency() async {
    final detected = await IpCurrencyHelper.detectCurrency();
    if (mounted) {
      await context.read<UserProvider>().updateCurrency(detected);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Currency auto-detected: $detected"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _normalizeCurrency(String? value) {
    if (value == null) return "USD";

    if (value.contains("LKR")) return "LKR";
    if (value.contains("INR")) return "INR";
    if (value.contains("USD")) return "USD";
    if (value.contains("EUR")) return "EUR";
    if (value.contains("GBP")) return "GBP";

    return "USD";
  }

  Future<void> changeCurrency(String value) async {
    await context.read<UserProvider>().updateCurrency(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), elevation: 0),
      body: Consumer2<UserProvider, ThemeProvider>(
        builder: (context, userProvider, themeProvider, __) {
          if (userProvider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentCurrency = _normalizeCurrency(
            userProvider.user!.currency,
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    "App Settings",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSettingItem(
                  icon: Icons.notifications,
                  title: "Notifications",
                  subtitle: "Enable transaction reminders",
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() => notificationsEnabled = value);
                  },
                  isDarkMode: isDarkMode,
                ),
                _buildCurrencySelector(isDarkMode, currentCurrency),
                _buildButtonItem(
                  icon: Icons.refresh,
                  title: "Auto-Detect Currency",
                  subtitle: "Detect your location and set currency",
                  onTap: _autoDetectCurrency,
                  isDarkMode: isDarkMode,
                ),
                const Divider(height: 32, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Display",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingItem(
                  icon: Icons.brightness_4,
                  title: "Dark Mode",
                  subtitle: "Switch between light and dark themes",
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    context.read<ThemeProvider>().setDarkMode(value);
                  },
                  isDarkMode: isDarkMode,
                ),
                const Divider(height: 32, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "About",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildButtonItem(
                  icon: Icons.info,
                  title: "About Expense Pro",
                  subtitle: "Version 1.0.0 - Production Ready",
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Expense Pro",
                      applicationVersion: "1.0.0",
                      applicationLegalese:
                          "Copyright © 2024. All rights reserved.",
                    );
                  },
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.borderColor : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppColors.textHint
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(bool isDarkMode, String currentCurrency) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.borderColor : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.currency_exchange, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Currency",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DropdownButton<String>(
            value: currencies.contains(currentCurrency)
                ? currentCurrency
                : "USD",
            underline: const SizedBox(),
            items: currencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) {
              if (value != null) changeCurrency(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButtonItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: isDarkMode ? AppColors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: AppColors.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? AppColors.textHint
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
