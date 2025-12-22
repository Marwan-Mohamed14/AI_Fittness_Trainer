import 'package:ai_personal_trainer/controllers/Profilecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../models/onboarding_data.dart';
import 'DietQuestionsScreen.dart';
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

  Widget _buildSelectableCard(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1F2E) : const Color(0xFF141722),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.deepPurple : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenPadding = Responsive.padding(context); 
    final double sectionFontSize = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16);
    final double titleFontSize = Responsive.fontSize(context, mobile: 24, tablet: 26, desktop: 28); 
    final double buttonFontSize = Responsive.fontSize(context, mobile: 14, tablet: 16, desktop: 18); 
    final double iconSize = Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24); 
    final double exerciseIconSize = Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24); 
    final double boxPadding = Responsive.padding(context) / 2; 
    final double cardRadius = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); 
    final double cardSpacing = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); 
    final double smallSpacing = Responsive.fontSize(context, mobile: 6, tablet: 8, desktop: 10); 
    final double largeSpacing = Responsive.fontSize(context, mobile: 20, tablet: 24, desktop: 28); 
    final double iconCircleSize = Responsive.fontSize(context, mobile: 40, tablet: 44, desktop: 48); 
    final double tutorialFontSize = Responsive.fontSize(context, mobile: 10, tablet: 12, desktop: 14); 
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
            
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(_fadeAnimation.value * 0.6),
                              blurRadius: 50,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 105,
                        height: 105,
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
                        scale: _scaleAnimation.value,
                        child: const Icon(
                          Icons.sports_gymnastics,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

   
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GOAL
                      const Text("What's your workout goal?",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 10),

                      _buildSelectableCard(
                          "Lose Weight",
                          selectedGoal == "Lose Weight",
                          () => setState(() => selectedGoal = "Lose Weight")),

                      _buildSelectableCard(
                          "Build Muscle",
                          selectedGoal == "Build Muscle",
                          () => setState(() => selectedGoal = "Build Muscle")),

                      _buildSelectableCard(
                          "Gain Strength",
                          selectedGoal == "Gain Strength",
                          () => setState(() => selectedGoal = "Gain Strength")),

                      _buildSelectableCard(
                          "Maintain Fitness",
                          selectedGoal == "Maintain Fitness",
                          () => setState(() => selectedGoal = "Maintain Fitness")),

                      const SizedBox(height: 25),

              
                      const Text("Your workout experience level:",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 10),

                      _buildSelectableCard(
                          "Beginner",
                          selectedLevel == "Beginner",
                          () => setState(() => selectedLevel = "Beginner")),

                      _buildSelectableCard(
                          "Intermediate",
                          selectedLevel == "Intermediate",
                          () => setState(() => selectedLevel = "Intermediate")),

                      _buildSelectableCard(
                          "Advanced",
                          selectedLevel == "Advanced",
                          () => setState(() => selectedLevel = "Advanced")),

                      const SizedBox(height: 25),

                      // DAYS PER WEEK
                      const Text("How many days do you want to train?",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(6, (i) {
                          int day = i + 1;
                          return GestureDetector(
                            onTap: () => setState(() => selectedDays = day),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: selectedDays == day
                                    ? const Color(0xFF1A1F2E)
                                    : const Color(0xFF141722),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedDays == day
                                      ? Colors.deepPurple
                                      : Colors.white24,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                "$day Days",
                                style: TextStyle(
                                    color: selectedDays == day
                                        ? Colors.deepPurple
                                        : Colors.white),
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 25),

                     
                      const Text("Where do you want to train?",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 10),

                      _buildSelectableCard(
                          "Gym",
                          selectedLocation == "Gym",
                          () => setState(() => selectedLocation = "Gym")),

                      _buildSelectableCard(
                          "Home",
                          selectedLocation == "Home",
                          () => setState(() => selectedLocation = "Home")),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
  if (selectedGoal == null ||
      selectedLevel == null ||
      selectedDays == null ||
      selectedLocation == null) {
    Get.snackbar(
      "Error",
      "Please fill all fields",
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
    );
    return;
  }
  
  profileController.saveWorkoutData(
    goal: selectedGoal!,
    level: selectedLevel!,
    days: selectedDays!,
    location: selectedLocation!,
  );
},
                  child: const Text("Next",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
