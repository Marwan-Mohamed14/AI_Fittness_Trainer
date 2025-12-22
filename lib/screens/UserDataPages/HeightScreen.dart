import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Profilecontroller.dart';
import '../../utils/responsive.dart';

class HeightScreen extends StatefulWidget {
  const HeightScreen({super.key});

  @override
  _HeightScreenState createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final ProfileController _profileController = Get.put(ProfileController());
  double height = 170;

  @override
  void initState() {
    super.initState();

    // Load existing height if available
    if (_profileController.onboardingData.value.height != null) {
      height = _profileController.onboardingData.value.height!.toDouble();
    }

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
                // 🔥 Futuristic Animated Height Logo
                // ==========================================
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow Aura
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
                              ),
                            ],
                          ),
                        ),

                        // Circle Ring
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

                        // Pulsing Height Icon
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: const Icon(Icons.height,
                              size: 55, color: Colors.white),
                        ),

                        // Floating Particle
                        Positioned(
                          top: 25,
                          right: 25,
                          child: CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.deepPurple.withOpacity(
                              _fadeAnimation.value,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 60),

                const Text(
                  "Select your height",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                // ==========================================
                // 🔥 Height Slider
                // ==========================================
                Text(
                  "${height.toInt()} cm",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),

                Slider(
                  value: height,
                  min: 80,
                  max: 230,
                  divisions: 130,
                  activeColor: Colors.deepPurple,
                  inactiveColor: Colors.white24,
                  label: "${height.toInt()} cm",
                  onChanged: (value) {
                    setState(() {
                      height = value;
                    });
                  },
                ),

                const SizedBox(height: 40),

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
                      // Save height using ProfileController
                      _profileController.saveHeight(height.toInt());
                    },
                    child: const Text(
                      "Next",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
