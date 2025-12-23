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
  double _age = 20; 

  @override
  void initState() {
    super.initState();


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
  final padding = Responsive.padding(context);

  final titleSize =
      Responsive.fontSize(context, mobile: 18, tablet: 20, desktop: 22);
  final ageSize =
      Responsive.fontSize(context, mobile: 36, tablet: 40, desktop: 44);
  final iconSize =
      Responsive.fontSize(context, mobile: 36, tablet: 40, desktop: 45);
  final circleSize =
      Responsive.fontSize(context, mobile: 100, tablet: 120, desktop: 140);

  return Scaffold(
    backgroundColor: const Color(0xFF0F111A),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              AnimatedBuilder(
                animation: _animController,
                builder: (_, __) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(
                                  _fadeAnimation.value * 0.5),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: circleSize * 0.8,
                        height: circleSize * 0.8,
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
                        child: Icon(
                          Icons.cake,
                          size: iconSize,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

             
              Text(
                "Select your age",
                style: TextStyle(
                  fontSize: titleSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

         
              Text(
                _age.toInt().toString(),
                style: TextStyle(
                  fontSize: ageSize,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

            
              Slider(
                value: _age,
                min: 10,
                max: 80,
                divisions: 70,
                activeColor: Colors.deepPurple,
                inactiveColor: Colors.grey.shade700,
                onChanged: (value) {
                  setState(() => _age = value);
                },
              ),

              const SizedBox(height: 32),

       
              Obx(
                () => SizedBox(
                  width: Responsive.isDesktop(context) ? 400 : double.infinity,
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
                            await profileController.saveAge(_age.toInt());
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
                            style:
                                TextStyle(fontSize: 16, color: Colors.white),
                          ),
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