import 'package:flutter/material.dart';
import '../../models/onboarding_data.dart';
import 'WorkoutQuestionsScreen.dart';

class HeightScreen extends StatefulWidget {
  final OnboardingData data;

  HeightScreen({required this.data});

  @override
  _HeightScreenState createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  double height = 170;

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
    return Scaffold(
      backgroundColor: Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(80),
        child: Column(
          children: [
            SizedBox(height: 70),

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
                        color: Color(0xFF1E2230),
                        border: Border.all(
                          color: Colors.deepPurple.withOpacity(0.4),
                          width: 3,
                        ),
                      ),
                    ),

                    // Pulsing Height Icon
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Icon(Icons.height, size: 55, color: Colors.white),
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

            SizedBox(height: 60),

            Text(
              "Select your height",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 30),

            // ==========================================
            // 🔥 Height Slider
            // ==========================================
            Text(
              height.toInt().toString() + " cm",
              style: TextStyle(
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

            Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  widget.data.height = height.toInt();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutQuestionsScreen(data: widget.data),
                    ),
                  );
                },
                child: Text(
                  "Next",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
