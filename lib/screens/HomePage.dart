import 'package:flutter/material.dart';
// Note: Ensure these paths match your actual project structure
import 'edit_user_info_page.dart';
import 'UpdatePlans.dart';
import 'NearbyGymsPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    MaterialPageRoute(builder: (_) => const EditUserInfoPage()),
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
                _ConsistencyTracker(), 
                SizedBox(height: 20),
                _DailyCheckUpCard(),
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
// Consistency Tracker 
// =============================
class _ConsistencyTracker extends StatelessWidget {
  const _ConsistencyTracker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Consistency Tracker",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                  SizedBox(width: 4),
                  Text("12 Day Streak", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _GoalProgressCard(
                label: "Workout",
                icon: Icons.fitness_center,
                progress: 0.8, 
                progressText: "24/30",
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GoalProgressCard(
                label: "Diet Plan",
                icon: Icons.apple,
                progress: 0.95, 
                progressText: "28/30",
                color: Colors.tealAccent.shade700,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final double progress;
  final String progressText;
  final Color color;

  const _GoalProgressCard({
    required this.label,
    required this.icon,
    required this.progress,
    required this.progressText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Monthly Goal", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 10)),
              Text(progressText, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.background,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================
// Daily Check-up
// =============================
class _DailyCheckUpCard extends StatelessWidget {
  const _DailyCheckUpCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_turned_in, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                "Daily Check-up",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Confirm your diet & workout for today.",
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _SelectionTile(label: "Diet")),
              const SizedBox(width: 12),
              Expanded(child: _SelectionTile(label: "Workout")),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                // You can add logic here to save progress
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Log Daily Progress", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final String label;
  const _SelectionTile({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(Icons.radio_button_off, size: 18, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
          MaterialPageRoute(builder: (_) => const NearbyGymsScreen()),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1534438327276-14e5300c3a48'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Find Nearest Gym',
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
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
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.next_plan,
            title: 'Regenerate Plan',
            subtitle: 'Adjust your plan on demand',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpdatePlans()),
              );
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ActionCard(
            icon: Icons.groups,
            title: 'Community',
            subtitle: "See what's new",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunityScreen()),
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

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
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
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              subtitle, 
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 10), 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis
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
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: const Center(child: Text('Community Page')),
    );
  }
}