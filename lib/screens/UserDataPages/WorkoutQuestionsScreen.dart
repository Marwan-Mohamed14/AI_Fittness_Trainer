import 'package:flutter/material.dart';
import '../../models/onboarding_data.dart';
import 'DietQuestionsScreen.dart';

class WorkoutQuestionsScreen extends StatefulWidget {
  final OnboardingData data;

  WorkoutQuestionsScreen({required this.data});

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

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
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
        duration: Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1A1F2E) : Color(0xFF141722),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),

            // ANIMATED LOGO
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
                            color: Colors.deepPurple
                                .withOpacity(_fadeAnimation.value * 0.6),
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

            SizedBox(height: 35),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // GOAL
                    Text("What's your workout goal?",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 10),

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

                    SizedBox(height: 25),

                    // LEVEL
                    Text("Your workout experience level:",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 10),

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

                    SizedBox(height: 25),

                    // DAYS PER WEEK
                    Text("How many days do you want to train?",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(6, (i) {
                        int day = i + 1;
                        return GestureDetector(
                          onTap: () => setState(() => selectedDays = day),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: selectedDays == day
                                  ? Color(0xFF1A1F2E)
                                  : Color(0xFF141722),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: selectedDays == day
                                      ? Colors.deepPurple
                                      : Colors.white24,
                                  width: 1.5),
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

                    SizedBox(height: 25),

                    // LOCATION
                    Text("Where do you want to train?",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 10),

                    _buildSelectableCard(
                        "Gym",
                        selectedLocation == "Gym",
                        () => setState(() => selectedLocation = "Gym")),

                    _buildSelectableCard(
                        "Home",
                        selectedLocation == "Home",
                        () => setState(() => selectedLocation = "Home")),
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: Size(double.infinity, 55)),
              onPressed: () {
                if (selectedGoal == null ||
                    selectedLevel == null ||
                    selectedDays == null ||
                    selectedLocation == null) {
                  return;
                }

                widget.data.workoutGoal = selectedGoal;
                widget.data.workoutLevel = selectedLevel;
                widget.data.trainingDays = selectedDays;
                widget.data.trainingLocation = selectedLocation;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DietQuestionsScreen(data: widget.data),
                  ),
                );
              },
              child:
                  Text("Next", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
