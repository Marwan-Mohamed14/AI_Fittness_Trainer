import 'package:ai_personal_trainer/controllers/Profilecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'GenderScreen.dart';
import '../../utils/responsive.dart';

class AgeScreen extends StatefulWidget {
  @override
  _AgeScreenState createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final ProfileController profileController = Get.put(ProfileController());
  double _age = 20; // default age

  @override
  void initState() {
    super.initState();

    // Load existing age if available
    if (profileController.onboardingData.value.age != null) {
      _age = profileController.onboardingData.value.age!.toDouble();
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation =
        Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
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
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),

            // AI GLOWING LOGO
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(
                                _fadeAnimation.value * 0.5),
                            blurRadius: 50,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),

                    // Main circle
                    Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E2230),
                        border: Border.all(
                          color: Colors.deepPurple.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),

                    // Pulsing age icon
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: const Icon(
                        Icons.cake,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),

                    // Floating AI dot
                    Positioned(
                      top: 32,
                      right: 35,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor:
                            Colors.deepPurple.withOpacity(_fadeAnimation.value),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // TITLE
            const Text(
              "Select your age",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              _age.toInt().toString(),
              style: const TextStyle(
                fontSize: 40,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // AGE SLIDER
            Slider(
              value: _age,
              min: 10,
              max: 80,
              divisions: 70,
              activeColor: Colors.deepPurple,
              inactiveColor: Colors.grey.shade700,
              label: _age.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _age = value;
                });
              },
            ),

            const Spacer(),

            // NEXT BUTTON with loading state
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: profileController.isLoading.value
                    ? null
                    : () async {
                        // Save age to Supabase and navigate
                       await profileController.saveAge(_age.toInt());
//Get.to(() => const GenderScreen());

                      },
                child: profileController.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Next",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            )),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}