import 'package:flutter/material.dart';
import '../../models/onboarding_data.dart';

class DietQuestionsScreen extends StatefulWidget {
  final OnboardingData data;

  DietQuestionsScreen({required this.data});

  @override
  _DietQuestionsScreenState createState() => _DietQuestionsScreenState();
}

class _DietQuestionsScreenState extends State<DietQuestionsScreen>
    with SingleTickerProviderStateMixin {

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Diet fields
  String? dietPreference;
  int meals = 3;
  String? budget = "Medium";
  double currentWeight = 80;
  double targetWeight = 75;

  // Extra optional
  String? activityLevel;
  final TextEditingController _allergyController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(height: 30),

            // ============================
            //  🔥 Futuristic Animated Logo
            // ============================
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(_fadeAnimation.value * 0.6),
                            blurRadius: 60,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E2230),
                        border: Border.all(
                          color: Colors.deepPurple.withOpacity(0.4),
                          width: 3,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 55,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      top: 25,
                      right: 25,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.deepPurple.withOpacity(_fadeAnimation.value),
                      ),
                    )
                  ],
                );
              },
            ),

            SizedBox(height: 40),

            Text(
              "Diet Questions",
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // ============================
            // Diet preference
            // ============================
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Diet Preference:", style: TextStyle(color: Colors.white70)),
            ),
            DropdownButton<String>(
              dropdownColor: Color(0xFF1E2230),
              value: dietPreference,
              hint: Text("Select diet type", style: TextStyle(color: Colors.white54)),
              items: [
                "Normal",
                "Low Carb",
                "High Protein",
                "Vegetarian",
                "Keto"
              ].map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: TextStyle(color: Colors.white)),
              )).toList(),
              onChanged: (v) => setState(() => dietPreference = v),
            ),

            SizedBox(height: 20),

            // ============================
            // Meals per day
            // ============================
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Meals per day:", style: TextStyle(color: Colors.white70)),
            ),
            DropdownButton<int>(
              dropdownColor: Color(0xFF1E2230),
              value: meals,
              items: [2, 3, 4, 5]
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Text("$e meals", style: TextStyle(color: Colors.white)),
              ))
                  .toList(),
              onChanged: (v) => setState(() => meals = v!),
            ),

            SizedBox(height: 20),

            // ============================
            // Current Weight Slider
            // ============================
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Current Weight: ${currentWeight.toInt()} kg",
                  style: TextStyle(color: Colors.white70)),
            ),
            Slider(
              min: 30,
              max: 200,
              value: currentWeight,
              activeColor: Colors.deepPurple,
              onChanged: (v) => setState(() => currentWeight = v),
            ),

            // ============================
            // Target Weight Slider
            // ============================
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Target Weight: ${targetWeight.toInt()} kg",
                  style: TextStyle(color: Colors.white70)),
            ),
            Slider(
              min: 30,
              max: 200,
              value: targetWeight,
              activeColor: Colors.deepPurple,
              onChanged: (v) => setState(() => targetWeight = v),
            ),

            SizedBox(height: 20),

            // ============================
            // Budget
            // ============================
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Budget:", style: TextStyle(color: Colors.white70)),
            ),
            DropdownButton<String>(
              dropdownColor: Color(0xFF1E2230),
              value: budget,
              items: ["Low", "Medium", "High"]
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: TextStyle(color: Colors.white)),
              ))
                  .toList(),
              onChanged: (v) => setState(() => budget = v),
            ),

            SizedBox(height: 20),

            // ============================
            // Allergies / Dislikes
            // ============================
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Foods you don't eat (allergies/dislikes):",
                  style: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: _allergyController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Example: milk, peanuts, fish...",
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Color(0xFF1E2230),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            Spacer(),

            // ============================
            // Button
            // ============================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (dietPreference == null) return;

                  widget.data.dietPreference = dietPreference;
                  widget.data.mealsPerDay = meals;
                  widget.data.weight = currentWeight.toInt();
                  widget.data.targetWeight = targetWeight.toInt();
                  widget.data.budget = budget;
                  widget.data.allergies =
                      _allergyController.text.split(",").map((e) => e.trim()).toList();

                  print("Final onboarding data:");
                  print(widget.data);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Generating diet & workout...")),
                  );
                },
                child: Text("Generate Diet", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
