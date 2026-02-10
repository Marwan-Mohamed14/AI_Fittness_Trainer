import 'package:ai_personal_trainer/controllers/Profilecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/responsive.dart';

class WorkoutQuestionsScreen extends StatefulWidget {
  const WorkoutQuestionsScreen({super.key});

  @override
  _WorkoutQuestionsScreenState createState() => _WorkoutQuestionsScreenState();
}

class _WorkoutQuestionsScreenState extends State<WorkoutQuestionsScreen>
    with SingleTickerProviderStateMixin {
  String? selectedGoal;
  String? selectedLevel;
  int? selectedDays;
  String? selectedLocation;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final ProfileController profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Refactored Animated Icon to ensure consistency
  Widget _buildAnimatedIcon(bool isLandscape) {
    double sizeMultiplier = isLandscape ? 0.7 : 1.0;
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 130 * sizeMultiplier,
              height: 130 * sizeMultiplier,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(_fadeAnimation.value * 0.6),
                    blurRadius: 50 * sizeMultiplier,
                    spreadRadius: 3 * sizeMultiplier,
                  ),
                ],
              ),
            ),
            Container(
              width: 105 * sizeMultiplier,
              height: 105 * sizeMultiplier,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E2230),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
            Transform.scale(
              scale: _scaleAnimation.value * sizeMultiplier,
              child: Icon(
                Icons.sports_gymnastics,
                size: 48,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectableCard(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          vertical: Responsive.spacing(context, mobile: 16, tablet: 18, desktop: 20),
          horizontal: Responsive.spacing(context, mobile: 18, tablet: 20, desktop: 22),
        ),
        margin: EdgeInsets.only(
          bottom: Responsive.spacing(context, mobile: 12, tablet: 14, desktop: 16),
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1F2E) : const Color(0xFF141722),
          borderRadius: BorderRadius.circular(
            Responsive.borderRadius(context, mobile: 14, tablet: 16, desktop: 18),
          ),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.deepPurple : Colors.white,
                fontSize: Responsive.fontSize(context, mobile: 16, tablet: 17, desktop: 18),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.deepPurple, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // foregroundColor forces the back button and all items to white
        foregroundColor: Colors.white, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;
            final padding = Responsive.padding(context);

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: padding * 0.5,
              ),
              child: Column(
                children: [
                  // Portrait Icon
                  if (!isLandscape) ...[
                    _buildAnimatedIcon(false),
                    SizedBox(height: Responsive.spacing(context, mobile: 30, tablet: 20)),
                  ],

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: double.infinity, // Forces column to take full width for centering
                        child: Column(
                          crossAxisAlignment: isLandscape 
                              ? CrossAxisAlignment.center 
                              : CrossAxisAlignment.start,
                          children: [
                            // Landscape Icon centered
                            if (isLandscape) ...[
                              _buildAnimatedIcon(true),
                              const SizedBox(height: 20),
                            ],

                            Text(
                              "What's your workout goal?",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.fontSize(context, mobile: 18, desktop: 20),
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildSelectableCard("Lose Weight", selectedGoal == "Lose Weight", () => setState(() => selectedGoal = "Lose Weight")),
                            _buildSelectableCard("Build Muscle", selectedGoal == "Build Muscle", () => setState(() => selectedGoal = "Build Muscle")),
                            _buildSelectableCard("Gain Strength", selectedGoal == "Gain Strength", () => setState(() => selectedGoal = "Gain Strength")),
                            _buildSelectableCard("Maintain Fitness", selectedGoal == "Maintain Fitness", () => setState(() => selectedGoal = "Maintain Fitness")),

                            const SizedBox(height: 25),
                            Text(
                              "Your experience level:",
                              style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, mobile: 18)),
                            ),
                            const SizedBox(height: 15),
                            _buildSelectableCard("Beginner", selectedLevel == "Beginner", () => setState(() => selectedLevel = "Beginner")),
                            _buildSelectableCard("Intermediate", selectedLevel == "Intermediate", () => setState(() => selectedLevel = "Intermediate")),
                            _buildSelectableCard("Advanced", selectedLevel == "Advanced", () => setState(() => selectedLevel = "Advanced")),

                            const SizedBox(height: 25),
                            Text(
                              "Training days per week:",
                              style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, mobile: 18)),
                            ),
                            const SizedBox(height: 15),
                            Center( // Centers the Wrap in landscape
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(6, (i) {
                                  int day = i + 1;
                                  bool isDaySelected = selectedDays == day;
                                  return GestureDetector(
                                    onTap: () => setState(() => selectedDays = day),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: isDaySelected ? const Color(0xFF1A1F2E) : const Color(0xFF141722),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: isDaySelected ? Colors.deepPurple : Colors.white24),
                                      ),
                                      child: Text("$day Days", style: TextStyle(color: isDaySelected ? Colors.deepPurple : Colors.white)),
                                    ),
                                  );
                                }),
                              ),
                            ),

                            const SizedBox(height: 25),
                            Text(
                              "Where do you want to train?",
                              style: TextStyle(color: Colors.white, fontSize: Responsive.fontSize(context, mobile: 18)),
                            ),
                            const SizedBox(height: 15),
                            _buildSelectableCard("Gym", selectedLocation == "Gym", () => setState(() => selectedLocation = "Gym")),
                            _buildSelectableCard("Home", selectedLocation == "Home", () => setState(() => selectedLocation = "Home")),
                            const SizedBox(height: 100), // Space for bottom button
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Fixed Bottom Button
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (selectedGoal == null || selectedLevel == null || selectedDays == null || selectedLocation == null) {
                            Get.snackbar("Error", "Please fill all fields", backgroundColor: Colors.redAccent, colorText: Colors.white);
                            return;
                          }
                          profileController.saveWorkoutData(
                            goal: selectedGoal!,
                            level: selectedLevel!,
                            days: selectedDays!,
                            location: selectedLocation!,
                          );
                        },
                        child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}