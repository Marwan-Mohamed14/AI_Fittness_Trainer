import 'package:ai_personal_trainer/screens/Community/community_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/dailycheckupcontroller.dart';
import '../utils/responsive.dart';
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
    Get.put(DailyCheckupController());
    final user = Supabase.instance.client.auth.currentUser;
    final firstName = (user?.userMetadata?['username'] as String? ?? 
                      user?.email?.split('@').first ?? 
                      'User').split(' ').first;

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
                  'Welcome Back, $firstName!',
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
        
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final padding = Responsive.padding(context);
            final spacing = Responsive.spacing(context, mobile: 20, tablet: 24, desktop: 28);
            
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.8),
                child: Column(
                  children: [
                    _ConsistencyTracker(),
                    SizedBox(height: spacing),
                    _DailyCheckUpCard(),
                    SizedBox(height: spacing),
                    _NearestGymCard(),
                    SizedBox(height: spacing),
                    _BottomActions(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConsistencyTracker extends StatelessWidget {
  const _ConsistencyTracker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<DailyCheckupController>();
    final spacing = Responsive.spacing(context, mobile: 16, tablet: 20, desktop: 24);
    final titleSize = Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24);

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
              Flexible(
                child: Text(
                  "Consistency Tracker",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(context, mobile: 12, tablet: 14, desktop: 16),
                    vertical: Responsive.spacing(context, mobile: 6, tablet: 7, desktop: 8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: Responsive.iconSize(context, mobile: 18, tablet: 20, desktop: 22),
                      ),
                      SizedBox(width: Responsive.spacing(context, mobile: 4, tablet: 5, desktop: 6)),
                      Flexible(
                        child: Text(
                          "${controller.streak.value} Day Streak",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(context, mobile: 12, tablet: 13, desktop: 14),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: spacing),
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
              SizedBox(width: Responsive.spacing(context, mobile: 12, tablet: 14, desktop: 16)),
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
    final padding = Responsive.padding(context);
    final borderRadius = Responsive.borderRadius(context, mobile: 20, tablet: 22, desktop: 24);
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : const Color(0xFFFAFBFC), 
        borderRadius: BorderRadius.circular(borderRadius),
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
                radius: Responsive.iconSize(context, mobile: 14, tablet: 16, desktop: 18) / 2,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: color,
                  size: Responsive.iconSize(context, mobile: 16, tablet: 18, desktop: 20),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, mobile: 8, tablet: 10, desktop: 12)),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(context, mobile: 14, tablet: 15, desktop: 16),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20, tablet: 24, desktop: 28)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Monthly Goal",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: Responsive.fontSize(context, mobile: 10, tablet: 11, desktop: 12),
                ),
              ),
              Text(
                progressText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: Responsive.fontSize(context, mobile: 10, tablet: 11, desktop: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 8, tablet: 10, desktop: 12)),
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

class _DailyCheckUpCard extends StatelessWidget {
  const _DailyCheckUpCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<DailyCheckupController>();
    final padding = Responsive.padding(context);
    final borderRadius = Responsive.borderRadius(context, mobile: 24, tablet: 26, desktop: 28);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(borderRadius),
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
          SizedBox(height: Responsive.spacing(context, mobile: 6, tablet: 8, desktop: 10)),
          Text(
            controller.formattedDate,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: Responsive.fontSize(context, mobile: 12, tablet: 13, desktop: 14),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 6, tablet: 8, desktop: 10)),
          Text(
            "Confirm your diet & workout for today.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: Responsive.fontSize(context, mobile: 12, tablet: 13, desktop: 14),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 20, tablet: 24, desktop: 28)),
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
              SizedBox(width: Responsive.spacing(context, mobile: 12, tablet: 14, desktop: 16)),
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
          SizedBox(height: Responsive.spacing(context, mobile: 20, tablet: 24, desktop: 28)),
          Obx(() {
            final alreadyLogged = controller.todayLogged.value;
            final canLogNow = controller.canLog && !alreadyLogged;
            final buttonHeight = Responsive.spacing(context, mobile: 55, tablet: 60, desktop: 65);
            
            return SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canLogNow ? theme.colorScheme.primary : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.borderRadius(context, mobile: 15, tablet: 16, desktop: 18),
                    ),
                  ),
                ),
                onPressed: canLogNow
                    ? () async {
                        await controller.saveToday();
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.fontSize(context, mobile: 16, tablet: 17, desktop: 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!alreadyLogged) ...[
                      SizedBox(width: Responsive.spacing(context, mobile: 10, tablet: 12, desktop: 14)),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: Responsive.iconSize(context, mobile: 20, tablet: 22, desktop: 24),
                      ),
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
                  : const Color(0xFFFAFBFC)), 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.15), 
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
        height: Responsive.spacing(context, mobile: 160, tablet: 180, desktop: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, mobile: 18, tablet: 20, desktop: 22),
          ),
          image: const DecorationImage(image: AssetImage('assets/GYMBG.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(Responsive.padding(context)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              Responsive.borderRadius(context, mobile: 18, tablet: 20, desktop: 22),
            ),
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

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.next_plan,
            title: 'Regenerate',
            subtitle: 'Update your plan',
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
        height: Responsive.spacing(context, mobile: 120, tablet: 140, desktop: 160),
        padding: EdgeInsets.all(Responsive.padding(context)),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.surface
              : const Color(0xFFFAFBFC),
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, mobile: 18, tablet: 20, desktop: 22),
          ),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: Responsive.iconSize(context, mobile: 24, tablet: 26, desktop: 28),
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 12, tablet: 14, desktop: 16)),
            Flexible(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.fontSize(context, mobile: 14, tablet: 15, desktop: 16),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 4, tablet: 5, desktop: 6)),
            Flexible(
              child: Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: Responsive.fontSize(context, mobile: 10, tablet: 11, desktop: 12),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


