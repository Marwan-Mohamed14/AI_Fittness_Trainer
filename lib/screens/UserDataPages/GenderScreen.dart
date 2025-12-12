import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Profilecontroller.dart';
import 'HeightScreen.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  _GenderScreenState createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final ProfileController _profileController = Get.put(ProfileController());

  String? selectedGender;

  @override
  void initState() {
    super.initState();

    // Load saved gender
    selectedGender = _profileController.onboardingData.value.gender;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget genderOption({
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = selectedGender == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2230),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurpleAccent
                : Colors.deepPurple.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 60,
              color: isSelected ? Colors.deepPurpleAccent : Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.deepPurpleAccent : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),

            child: Column(
              children: [
                const SizedBox(height: 40),

                // ==========================================
                // 🔥 Animated Gender Icon
                // ==========================================
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
                                color: Colors.deepPurple.withOpacity(
                                  _fadeAnimation.value * 0.6,
                                ),
                                blurRadius: 60,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                        ),

                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E2230),
                            border: Border.all(
                              color: Colors.deepPurple.withOpacity(0.4),
                              width: 3,
                            ),
                          ),
                        ),

                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: const Icon(
                            Icons.person_outline,
                            size: 55,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 60),

                const Text(
                  "Select your gender",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // ==========================================
                // 🔥 Gender Options
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: genderOption(
                          label: "Male", icon: Icons.male_rounded),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: genderOption(
                          label: "Female", icon: Icons.female_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    onPressed: () {
      if (selectedGender == null) {
        Get.snackbar(
          "Error",
          "Please select a gender",
          backgroundColor: Colors.red.withOpacity(0.6),
          colorText: Colors.white,
        );
        return;
      }

      _profileController.saveGender(selectedGender!);

      // 👉 Go to height screen
      //Get.to(() => const HeightScreen());
    },
    child: const Text(
      "Next",
      style: TextStyle(fontSize: 18, color: Colors.white),
    ),
  ),
),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
