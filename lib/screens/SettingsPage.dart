import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/controllers/themecontroller.dart';
import 'package:ai_personal_trainer/controllers/notificationcontroller.dart';
import 'package:ai_personal_trainer/services/Authservice.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

final NotificationController notificationController =
    Get.find<NotificationController>();


  bool _isLoggingOut = false;
  bool _mealReminders = true;
  bool _workoutPrompts = true;

  // ================= LOGOUT =================
  Future<void> _handleLogout() async {
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    setState(() => _isLoggingOut = true);

    try {
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      setState(() => _isLoggingOut = false);
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Settings',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= GENERAL =================
            const _SectionHeader(title: 'GENERAL'),
            _SettingsCard(
              children: [
                GetBuilder<ThemeController>(
                  builder: (themeController) {
                    return _SwitchSettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      value: themeController.isDarkMode,
                      onChanged: themeController.toggleTheme,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= SMART NOTIFICATIONS =================
            const _SectionHeader(title: 'SMART NOTIFICATIONS'),
            _SettingsCard(
              children: [
                _SwitchSettingsTile(
                  icon: Icons.restaurant,
                  title: 'Meal Reminders',
                  value: _mealReminders,
                  onChanged: (v) => setState(() => _mealReminders = v),
                ),
                const _Divider(),
                _SwitchSettingsTile(
                  icon: Icons.fitness_center,
                  title: 'Workout Reminders',
                  value: _workoutPrompts,
                  onChanged: (v) => setState(() => _workoutPrompts = v),
                ),
                const _Divider(),

Obx(
  () => _SwitchSettingsTile(
    icon: Icons.water_drop_outlined,
    title: 'Hydration Reminders',
    value: notificationController.hydrationEnabled.value,
    onChanged: notificationController.toggleHydration,
  ),
),

              ],
            ),

            const SizedBox(height: 32),

            // ================= LOG OUT =================
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _isLoggingOut ? null : _handleLogout,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: _isLoggingOut
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  _isLoggingOut ? 'Logging out...' : 'Log Out',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'FitMind AI © 2024',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= UI COMPONENTS =================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2230) : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchSettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.08),
    );
  }
}
