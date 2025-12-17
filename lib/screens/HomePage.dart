import 'package:ai_personal_trainer/screens/NearbyGymsPage.dart';
import 'package:flutter/material.dart';
import '../widgets/BottomNavigation.dart';
import 'UpdatePlans.dart';
import 'edit_user_info_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // cache theme

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditUserInfoPage(),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.surface,
                  child: Icon(Icons.account_box_rounded, color: theme.colorScheme.onSurface),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Alex!',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  "Let's crush today's goals.",
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.6)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.surface,
              child: Icon(Icons.notifications, color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: const [
                _CalendarCard(),
                SizedBox(height: 20),
                _WeeklyCheckInCard(),
                SizedBox(height: 20),
                _NearestGymCard(),
                SizedBox(height: 20),
                _BottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================
// Calendar Card
// =============================
class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            'October 2023',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((e) => Text(e, style: TextStyle(color: Colors.grey)))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DayItem(day: '29', status: DayStatus.done),
              _DayItem(day: '30', status: DayStatus.done),
              _DayItem(day: '1', status: DayStatus.done),
              _DayItem(day: '2', status: DayStatus.missed),
              _DayItem(day: '3', status: DayStatus.done),
              _DayItem(day: '4', status: DayStatus.done),
              _DayItem(day: '5', status: DayStatus.active),
            ],
          ),
        ],
      ),
    );
  }
}

enum DayStatus { done, missed, active }

class _DayItem extends StatelessWidget {
  final String day;
  final DayStatus status;

  const _DayItem({required this.day, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor = theme.colorScheme.onSurface;

    switch (status) {
      case DayStatus.active:
        bgColor = theme.colorScheme.primary;
        break;
      case DayStatus.done:
      case DayStatus.missed:
      default:
        bgColor = theme.colorScheme.surfaceVariant;
        break;
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: bgColor,
          child: Text(
            day,
            style: theme.textTheme.bodySmall?.copyWith(color: textColor),
          ),
        ),
        const SizedBox(height: 6),
        if (status == DayStatus.done)
          Icon(Icons.check, color: Colors.green, size: 14)
        else if (status == DayStatus.missed)
          Icon(Icons.close, color: Colors.red, size: 14),
      ],
    );
  }
}

// =============================
// Weekly Check-in
// =============================
class _WeeklyCheckInCard extends StatelessWidget {
  const _WeeklyCheckInCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(Icons.auto_graph, size: 12, color: theme.colorScheme.onPrimary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Weekly Check-in',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Log your weight & height to refine your AI plan.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.6)),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: Text('Log Stats', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onPrimary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================
// Nearest Gym
// =============================
class _NearestGymCard extends StatelessWidget {
  const _NearestGymCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NearbyGymsScreen(),
          ),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: theme.colorScheme.onBackground.withOpacity(0.55),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Find Nearest Gym',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
                ),
              ),
              CircleAvatar(
                backgroundColor: theme.colorScheme.surface,
                child: Icon(Icons.arrow_forward, color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================
// Bottom Actions
// =============================
class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.next_plan,
            title: 'Regenerate Plan',
            subtitle: 'Adjust your plan on demand or Monthly as Required',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UpdatePlans(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ActionCard(
            icon: Icons.groups,
            title: 'Community',
            subtitle: "See what's new in the AI Fitness Trainer community",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CommunityScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 14),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onBackground.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================
// Destination Screens
// =============================
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Community', style: theme.textTheme.titleMedium)),
      body: Center(
        child: Text('Community Page', style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
