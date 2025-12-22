import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dailycheckupcontroller.dart';
import 'edit_user_info_page.dart';
import 'UpdatePlans.dart';
import 'NearbyGymsPage.dart';
import 'DailyCheckUpMealsScreen.dart';
import 'DailyCheckUpWorkoutScreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Get.put(DailyCheckupController()); // Ensure controller is initialized

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
                  child: Icon(Icons.account_box_rounded,
                      color: theme.colorScheme.onSurface),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  "Let's crush today's goals.",
                  style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onBackground.withOpacity(0.6)),
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
              child: Icon(Icons.notifications,
                  color: theme.colorScheme.onSurface),
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
    final controller = Get.find<DailyCheckupController>();

    return Obx(() {
      final workoutProgress =
          (controller.workoutCount.value / 30).clamp(0.0, 1.0);
      final dietProgress =
          (controller.dietCount.value / 30).clamp(0.0, 1.0);

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Consistency Tracker",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.orange, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${controller.streak.value} Day Streak",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
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
                  progress: workoutProgress,
                  progressText:
                      "${controller.workoutCount.value}/30",
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GoalProgressCard(
                  label: "Diet Plan",
                  icon: Icons.apple,
                  progress: dietProgress,
                  progressText:
                      "${controller.dietCount.value}/30",
                  color: Colors.tealAccent.shade700,
                ),
              ),
            ],
          )
        ],
      );
    });
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
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : const Color(0xFFFAFBFC), // Better contrast in light mode
        borderRadius: BorderRadius.circular(20),
        border: theme.brightness == Brightness.light
            ? Border.all(
                color: Colors.black.withOpacity(0.15),
                width: 1.5,
              )
            : null,
        boxShadow: theme.brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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
              Text(label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Monthly Goal",
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey, fontSize: 10)),
              Text(progressText,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey, fontSize: 10)),
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
    final controller = Get.find<DailyCheckupController>();

    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(24),
        border: !isDark
            ? Border.all(
                color: Colors.black.withOpacity(0.15),
                width: 1.5,
              )
            : null,
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_turned_in,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                "Daily Check-up",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            controller.formattedDate,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            "Confirm your diet & workout for today.",
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Obx(() => _SelectionTile(
                  label: "Diet",
                  completed: controller.todayDietDone.value || controller.dietDone,
                  onTap: () {
                    Get.to(() => const DailyCheckupMealsScreen());
                  },
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _SelectionTile(
                  label: "Workout",
                  completed: controller.todayWorkoutDone.value || controller.workoutDone,
                  onTap: () {
                    Get.to(() => const DailyCheckupWorkoutScreen());
                  },
                )),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final alreadyLogged = controller.todayLogged.value;
            final canLogNow = controller.canLog && !alreadyLogged;
            
            return SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canLogNow ? theme.colorScheme.primary : Colors.grey,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: canLogNow
                    ? () async {
                        await controller.logDayIfCompleted();
                        Get.snackbar(
                          "Great Job!",
                          "Daily progress logged successfully.",
                        );
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      alreadyLogged ? "Already Logged Today" : "Log Daily Progress",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    if (!alreadyLogged) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final String label;
  final bool completed;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.label,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: completed
              ? Colors.green.withOpacity(0.2)
              : (theme.brightness == Brightness.dark
                  ? theme.colorScheme.background.withOpacity(0.5)
                  : const Color(0xFFFAFBFC)), // Better contrast in light mode
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.15), // More visible border in light mode
            width: theme.brightness == Brightness.dark ? 1 : 1.5,
          ),
          boxShadow: theme.brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              completed
                  ? Icons.check_circle
                  : Icons.radio_button_off,
              size: 18,
              color: completed
                  ? Colors.green
                  : Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
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
          image: const DecorationImage(image: AssetImage('assets/GYMBG.png'),
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
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
              CircleAvatar(
                backgroundColor: theme.colorScheme.surface,
                child: Icon(Icons.arrow_forward,
                    color: theme.colorScheme.onSurface),
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
                MaterialPageRoute(
                    builder: (_) => const CommunityScreen()),
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.surface
              : const Color(0xFFFAFBFC),
          borderRadius: BorderRadius.circular(18),
          border: theme.brightness == Brightness.light
              ? Border.all(
                  color: Colors.black.withOpacity(0.15),
                  width: 1.5,
                )
              : null,
          boxShadow: theme.brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface
                      .withOpacity(0.6),
                  fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================
// Community Screen
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
