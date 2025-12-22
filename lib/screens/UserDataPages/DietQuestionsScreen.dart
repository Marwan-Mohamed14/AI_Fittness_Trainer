import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Profilecontroller.dart';
import '../../utils/responsive.dart';

class DietQuestionsScreen extends StatefulWidget {
  const DietQuestionsScreen({super.key});

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

  final TextEditingController _allergyController = TextEditingController();
  final ProfileController _profileController = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();

    // Load existing values if available
    final data = _profileController.onboardingData.value;
    dietPreference = data.dietPreference;
    meals = data.mealsPerDay ?? 3;
    budget = data.budget ?? "Medium";
    currentWeight = data.weight?.toDouble() ?? 80;
    targetWeight = data.targetWeight?.toDouble() ?? 75;
    
   

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ===== Responsive variables =====
    final double screenPadding = Responsive.padding(context); // general padding
    final double sectionFontSize = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); // body text
    final double titleFontSize = Responsive.fontSize(context, mobile: 24, tablet: 26, desktop: 28); // headings
    final double buttonFontSize = Responsive.fontSize(context, mobile: 14, tablet: 16, desktop: 18); // button text
    final double iconSize = Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24); // icons
    final double exerciseIconSize = Responsive.fontSize(context, mobile: 20, tablet: 22, desktop: 24); // exercise card icon
    final double boxPadding = Responsive.padding(context) / 2; // inside cards
    final double cardRadius = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); // card border radius
    final double cardSpacing = Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16); // spacing between cards
    final double smallSpacing = Responsive.fontSize(context, mobile: 6, tablet: 8, desktop: 10); // small spacing
    final double largeSpacing = Responsive.fontSize(context, mobile: 20, tablet: 24, desktop: 28); // large spacing
    final double iconCircleSize = Responsive.fontSize(context, mobile: 40, tablet: 44, desktop: 48); // circle around icons
    final double tutorialFontSize = Responsive.fontSize(context, mobile: 10, tablet: 12, desktop: 14); // small text under icons
    
    return Scaffold(
      backgroundColor: Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
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
                // Allergies
                // ============================
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Additional notes (For perfect diet plan):",
                      style: TextStyle(color: Colors.white70)),
                ),
                TextField(
                  controller: _allergyController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Example: milk, peanuts, fish...",
                    hintStyle: TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1E2230),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 30),

               
Obx(() => SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      padding: EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: _profileController.isLoading.value
        ? null // Disable button while loading
        : () {
            if (dietPreference == null) {
              Get.snackbar(
                "Error",
                "Please select a diet preference",
                backgroundColor: Colors.red.withOpacity(0.7),
                colorText: Colors.white,
              );
              return;
            }

            // Parse allergies/dislikes from text field
            List<String> allergiesList = [];
            if (_allergyController.text.isNotEmpty) {
              allergiesList = _allergyController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            }

            // This will save data AND generate AI plans
            _profileController.saveDietData(
              dietPreference: dietPreference!,
              mealsPerDay: meals,
              budget: budget!,
              currentWeight: currentWeight.toInt(),
              targetWeight: targetWeight.toInt(),
              allergies: allergiesList,
            );
          },
    child: _profileController.isLoading.value
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Generating...",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          )
        : Text(
            "Generate Diet",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
  ),
)),

                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
