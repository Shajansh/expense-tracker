import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_colors.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController countryCtrl;
  late TextEditingController currencyCtrl;
  late TextEditingController oldPasswordCtrl;
  late TextEditingController newPasswordCtrl;
  late TextEditingController confirmPasswordCtrl;

  bool _isEditing = false;
  bool _showPasswordChange = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    nameCtrl = TextEditingController(text: user?.name ?? "");
    emailCtrl = TextEditingController(text: user?.email ?? "");
    countryCtrl = TextEditingController(text: user?.country ?? "");
    currencyCtrl = TextEditingController(text: user?.currency ?? "USD");
    oldPasswordCtrl = TextEditingController();
    newPasswordCtrl = TextEditingController();
    confirmPasswordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    countryCtrl.dispose();
    currencyCtrl.dispose();
    oldPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    final updated = user.copyWith(
      name: nameCtrl.text,
      email: emailCtrl.text,
      country: countryCtrl.text,
      currency: currencyCtrl.text,
    );

    await context.read<UserProvider>().updateUser(updated);

    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPasswordCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password must be at least 6 characters"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = context.read<UserProvider>().user;
    if (user == null) return;

    // In a real app, you would call the auth service to change password
    // For now, just show a success message
    if (mounted) {
      setState(() {
        _showPasswordChange = false;
        oldPasswordCtrl.clear();
        newPasswordCtrl.clear();
        confirmPasswordCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password changed successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text("Cancel"),
                ),
                TextButton(onPressed: _saveProfile, child: const Text("Save")),
              ],
            ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userProvider.user!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Profile Form
                Text(
                  "Personal Information",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: "Name",
                  controller: nameCtrl,
                  enabled: _isEditing,
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: "Email",
                  controller: emailCtrl,
                  enabled: _isEditing,
                  icon: Icons.email,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: "Country",
                  controller: countryCtrl,
                  enabled: _isEditing,
                  icon: Icons.public,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: "Currency",
                  controller: currencyCtrl,
                  enabled: _isEditing,
                  icon: Icons.currency_exchange,
                ),
                const SizedBox(height: 24),
                // Security Section
                if (_isEditing) ...[
                  Text(
                    "Security",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (!_showPasswordChange)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _showPasswordChange = true),
                        icon: const Icon(Icons.lock),
                        label: const Text("Change Password"),
                      ),
                    )
                  else ...[
                    _buildTextField(
                      label: "Old Password",
                      controller: oldPasswordCtrl,
                      enabled: true,
                      obscureText: true,
                      icon: Icons.lock,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: "New Password",
                      controller: newPasswordCtrl,
                      enabled: true,
                      obscureText: true,
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: "Confirm Password",
                      controller: confirmPasswordCtrl,
                      enabled: true,
                      obscureText: true,
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _showPasswordChange = false),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _changePassword,
                            child: const Text("Update Password"),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
                // Account Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.cardBg : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Account Information",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow("User ID", user.id),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        "Member Since",
                        "${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController countryCtrl;
  late TextEditingController currencyCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    nameCtrl = TextEditingController(text: user?.name ?? '');
    emailCtrl = TextEditingController(text: user?.email ?? '');
    countryCtrl = TextEditingController(text: user?.country ?? '');
    currencyCtrl = TextEditingController(text: user?.currency ?? 'USD');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    countryCtrl.dispose();
    currencyCtrl.dispose();
    super.dispose();
  }

  void save() async {
    final userProvider = context.read<UserProvider>();
    await userProvider.updateProfile(
      name: nameCtrl.text,
      email: emailCtrl.text,
      country: countryCtrl.text,
      currency: currencyCtrl.text,
    );

    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            userProvider.user!.name.isNotEmpty
                                ? userProvider.user!.name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userProvider.user!.name.isNotEmpty
                            ? userProvider.user!.name
                            : "Your Name",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userProvider.user!.email.isNotEmpty
                            ? userProvider.user!.email
                            : "email@example.com",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Personal Information",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Full Name",
                        controller: nameCtrl,
                        icon: Icons.person,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Email",
                        controller: emailCtrl,
                        icon: Icons.email,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Country",
                        controller: countryCtrl,
                        icon: Icons.public,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Currency",
                        controller: currencyCtrl,
                        icon: Icons.currency_exchange,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.borderColor : AppColors.lightBorder,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
