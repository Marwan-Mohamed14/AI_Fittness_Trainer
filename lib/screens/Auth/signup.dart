import 'package:ai_personal_trainer/controllers/Authcontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_personal_trainer/services/Authservice.dart';
import 'package:ai_personal_trainer/utils/responsive.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  // --- 1. LOCAL STATE ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isPasswordHidden = true;
  final bool _isConfirmPasswordHidden = true;

  // --- 2. ANIMATION STATE (New Logo Logic) ---
  late AnimationController _animController;
  late Animation<double> _rotationAnimation;

final Authcontroller authController = Get.put(Authcontroller());


  @override
  void initState() {
    super.initState();
    
    // Initialize Animation for Rotating Ring (Building Profile)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(); // Continuous rotation

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _animController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- 3. UI BUILD ---
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
      backgroundColor: const Color(0xFF0F111A), // Dark Gym Theme
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // ========================================================
              // NEW DYNAMIC LOGO: "Profile Initialization"
              // ========================================================
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. Static Glowing Core
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E2230),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      // 2. Rotating "Scanner" Ring
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.deepPurple.withOpacity(0.4),
                              width: 2,
                              style: BorderStyle.solid, 
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 3. Static Icon (User being added)
                      const Icon(
                        Icons.person_add_alt_1,
                        size: 45,
                        color: Colors.white,
                      ),
                    ],
                  );
                },
              ),
              // ========================================================

              const SizedBox(height: 40),

              // Headlines
              const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join the AI revolution. Start training smarter.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              // Full Name Input
              _buildTextField(
                controller: authController.usernameController,
                hintText: "Full Name",
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 20),

              // Email Input
              _buildTextField(
                controller: authController.emailController,
                hintText: "Email Address",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              // Password Input
              _buildTextField(
                controller: authController.passwordController,
                hintText: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
                isHidden: _isPasswordHidden,
                onVisibilityToggle: () {
                  setState(() {
                    _isPasswordHidden = !_isPasswordHidden;
                  });
                },
              ),

              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async{
                   await authController.signUp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: Colors.deepPurple.withOpacity(0.4),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  GestureDetector(
                    onTap: () {
                       Get.back(); // Go back to login
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // UI Helper for TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isHidden = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isHidden : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}