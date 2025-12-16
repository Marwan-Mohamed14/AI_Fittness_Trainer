import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _mealReminders = true;
  bool _workoutPrompts = true;
  bool _hydrationTracking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.settings, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Settings', style: TextStyle(
                          color: Colors.white,
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
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                    onTap: () {},
                  ),
                  const _Divider(),
                  _SwitchSettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: _darkMode,
                    onChanged: (val) => setState(() => _darkMode = val),
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
                    backgroundColor: const Color(0xFF2C1E25),
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
          color: Colors.grey[400],
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(16),
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
                    color: const Color(0xFF252A3A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.grey[400], size: 20),
                ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.grey[400],
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
        activeColor: Colors.blue,
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
      color: Colors.white.withOpacity(0.05),
      indent: 60, // Indent to align with the text
    );
  }
}