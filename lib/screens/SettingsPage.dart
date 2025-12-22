import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/controllers/themecontroller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool _mealReminders = true;
  bool _workoutPrompts = true;
  bool _hydrationTracking = false;

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
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
       
    
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= GENERAL =================
              const _SectionHeader(title: 'GENERAL'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    subtitle: 'English (US)',
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      size: 16,
                    ),
                    onTap: () {},
                  ),
                  const _Divider(),
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
                    onChanged: (val) => setState(() => _mealReminders = val),
                  ),
                  const _Divider(),
                  _SwitchSettingsTile(
                    icon: Icons.fitness_center,
                    title: 'Workout Reminders',
                    value: _workoutPrompts,
                    onChanged: (val) => setState(() => _workoutPrompts = val),
                  ),
                  const _Divider(),
                  _SwitchSettingsTile(
                    icon: Icons.water_drop_outlined,
                    title: 'Hydration Reminders',
                    value: _hydrationTracking,
                    onChanged: (val) => setState(() => _hydrationTracking = val),
                  ),
                  const _Divider(),
                  
                ],
              ),
              const SizedBox(height: 24),

              // ================= SYSTEM =================
              const _SectionHeader(title: 'SYSTEM'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.dns_outlined,
                    title: 'AI Engine Status',
                    subtitle: 'v2.4.0 (Latest)',
                    trailing: const _AIEngineStatusBadge(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ================= LOG OUT =================
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2C1E25)
                        : Colors.red[50],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Color(0xFFD63D47)),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Color(0xFFD63D47),
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// Widgets
// ==========================================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2230) : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
        border: !isDark
            ? Border.all(
                color: Colors.black.withOpacity(0.15), // More visible border
                width: 1.5, // Thicker border
              )
            : null,
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData? icon;
  final Widget? leadingIconWidget;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    this.icon,
    this.leadingIconWidget,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            leadingIconWidget ??
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF252A3A)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[700],
                    size: 20,
                  ),
                ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
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
    return _SettingsTile(
      icon: icon,
      title: title,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _AIEngineStatusBadge extends StatelessWidget {
  const _AIEngineStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, color: Colors.green, size: 8),
          SizedBox(width: 6),
          Text(
            'Connected',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.08),
      indent: 60, // Indent to align with the text
    );
  }
}