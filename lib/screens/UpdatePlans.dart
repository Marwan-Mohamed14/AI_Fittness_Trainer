import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/Profilecontroller.dart';
import '../services/ProfileService.dart';
import '../services/Ai_plan_service.dart';
import '../utils/responsive.dart';

class UpdatePlans extends StatefulWidget {
  const UpdatePlans({super.key});

  @override
  State<UpdatePlans> createState() => _UpdatePlansState();
}

class _UpdatePlansState extends State<UpdatePlans>
    with SingleTickerProviderStateMixin {
  final ProfileController _profileController = Get.put(ProfileController());
  late TabController _tabController;
  bool _isLoading = false;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _mealsPerDayController;
  late TextEditingController _allergiesController;
  String? _selectedGender;
  String? _selectedWorkoutGoal;
  String? _selectedWorkoutLevel;
  int? _selectedTrainingDays;
  String? _selectedTrainingLocation;
  String? _selectedDietPreference;
  String? _selectedActivityLevel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeControllers();
    _loadProfileData();
  }

  void _initializeControllers() {
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _targetWeightController = TextEditingController();
    _mealsPerDayController = TextEditingController(text: '3');
    _allergiesController = TextEditingController();
  }

  void _loadProfileData() {
    _profileController.loadExistingProfile().then((_) {
      if (mounted) {
        setState(() {
          final data = _profileController.onboardingData.value;
          _ageController.text = data.age?.toString() ?? '';
          _heightController.text = data.height?.toString() ?? '';
          _weightController.text = data.weight?.toString() ?? '';
          _targetWeightController.text = data.targetWeight?.toString() ?? '';
          _mealsPerDayController.text = data.mealsPerDay?.toString() ?? '3';
          _allergiesController.text = data.allergies?.join(', ') ?? '';
          _selectedGender = data.gender;
          _selectedWorkoutGoal = data.workoutGoal;
          _selectedWorkoutLevel = data.workoutLevel;
          _selectedTrainingDays = data.trainingDays;
          _selectedTrainingLocation = data.trainingLocation;
          
          final savedPreference = data.dietPreference;
          if (savedPreference == 'High-Protein') {
            _selectedDietPreference = 'High Protein';
          } else if (savedPreference == 'Low-Carb') {
            _selectedDietPreference = 'Low Carb';
          } else {
            _selectedDietPreference = savedPreference;
          }
          _selectedActivityLevel = data.activityLevel;
        });
      }
    });
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Success 🎉', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Your profile has been updated successfully.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/home');
            },
            child: const Text('Go to Home', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _mealsPerDayController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  // --- UI Helper Methods ---

  Widget _buildInputCard({required String label, required Widget child, IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1A1F2E).withOpacity(0.8), const Color(0xFF141722).withOpacity(0.9)],
        ) : null,
        color: !isDark ? const Color(0xFFFAFBFC) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.15),
          width: isDark ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? minValue,
    int? maxValue,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F111A) : const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.15),
          width: isDark ? 1 : 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: [
          if (keyboardType == TextInputType.number) FilteringTextInputFormatter.digitsOnly,
          if (keyboardType == TextInputType.number && maxValue != null)
            _NumericRangeFormatter(maxValue: maxValue),
        ],
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)]) : null,
          color: isSelected ? null : (isDark ? const Color(0xFF0F111A) : const Color(0xFFFAFBFC)),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.7), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }

  // --- Tab Widgets ---

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInputCard(
            label: 'Basic Information',
            icon: Icons.person_outline,
            child: Column(
              children: [
                _buildTextField(controller: _ageController, label: 'Age (10-80)', icon: Icons.cake_outlined, keyboardType: TextInputType.number, maxValue: 80),
                const SizedBox(height: 16),
                _buildTextField(controller: _heightController, label: 'Height (80-230 cm)', icon: Icons.height, keyboardType: TextInputType.number, maxValue: 230),
                const SizedBox(height: 16),
                Wrap(
                  children: [
                    _buildChip('Male', _selectedGender == 'Male', () => setState(() => _selectedGender = 'Male')),
                    _buildChip('Female', _selectedGender == 'Female', () => setState(() => _selectedGender = 'Female')),
                  ],
                ),
              ],
            ),
          ),
          _buildInputCard(
            label: 'Weight Goals',
            icon: Icons.monitor_weight_outlined,
            child: Column(
              children: [
                _buildTextField(controller: _weightController, label: 'Current Weight (30-200 kg)', icon: Icons.scale, keyboardType: TextInputType.number, maxValue: 200),
                const SizedBox(height: 16),
                _buildTextField(controller: _targetWeightController, label: 'Target Weight (30-200 kg)', icon: Icons.flag_outlined, keyboardType: TextInputType.number, maxValue: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInputCard(
            label: 'Workout Goal',
            icon: Icons.fitness_center,
            child: Wrap(
              children: ['Lose Weight', 'Build Muscle', 'Gain Strength', 'Maintain Fitness']
                  .map((goal) => _buildChip(goal, _selectedWorkoutGoal == goal, () => setState(() => _selectedWorkoutGoal = goal)))
                  .toList(),
            ),
          ),
          _buildInputCard(
            label: 'Experience Level',
            icon: Icons.trending_up,
            child: Wrap(
              children: ['Beginner', 'Intermediate', 'Advanced']
                  .map((lvl) => _buildChip(lvl, _selectedWorkoutLevel == lvl, () => setState(() => _selectedWorkoutLevel = lvl)))
                  .toList(),
            ),
          ),
          _buildInputCard(
            label: 'Training Frequency',
            icon: Icons.calendar_today,
            child: Wrap(
              children: List.generate(6, (i) {
                int days = i + 1;
                return _buildChip('$days ${days == 1 ? 'Day' : 'Days'}', _selectedTrainingDays == days, () => setState(() => _selectedTrainingDays = days));
              }),
            ),
          ),
          _buildInputCard(
            label: 'Training Location',
            icon: Icons.place_outlined,
            child: Wrap(
              children: ['Gym', 'Home']
                  .map((loc) => _buildChip(loc, _selectedTrainingLocation == loc, () => setState(() => _selectedTrainingLocation = loc)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInputCard(
            label: 'Diet Preference',
            icon: Icons.restaurant_menu,
            child: Wrap(
              children: ['Normal', 'Low Carb', 'High Protein', 'Vegetarian', 'Keto']
                  .map((diet) => _buildChip(diet, _selectedDietPreference == diet, () => setState(() => _selectedDietPreference = diet)))
                  .toList(),
            ),
          ),
          _buildInputCard(
            label: 'Meal Planning',
            icon: Icons.restaurant_outlined,
            child: Wrap(
              children: [2, 3, 4, 5].map((count) {
                return _buildChip('$count meals', _mealsPerDayController.text == count.toString(), () => setState(() => _mealsPerDayController.text = count.toString()));
              }).toList(),
            ),
          ),
          _buildInputCard(
            label: 'Food Restrictions',
            icon: Icons.warning_amber_rounded,
            child: _buildTextField(controller: _allergiesController, label: 'Allergies (comma separated)', icon: Icons.info_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildInputCard(
        label: 'Profile Summary',
        icon: Icons.summarize,
        child: Column(
          children: [
            _buildSummaryRow('Age', _ageController.text.isEmpty ? 'Not set' : '${_ageController.text} years'),
            _buildSummaryRow('Height', _heightController.text.isEmpty ? 'Not set' : '${_heightController.text} cm'),
            _buildSummaryRow('Current Weight', _weightController.text.isEmpty ? 'Not set' : '${_weightController.text} kg'),
            _buildSummaryRow('Target Weight', _targetWeightController.text.isEmpty ? 'Not set' : '${_targetWeightController.text} kg'),
            _buildSummaryRow('Workout Goal', _selectedWorkoutGoal ?? 'Not set'),
            _buildSummaryRow('Diet Type', _selectedDietPreference ?? 'Not set'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Logical Operations ---

  Future<void> _saveProfile() async {
    // Basic final validation
    final age = int.tryParse(_ageController.text) ?? 0;
    if (age < 10 || age > 80) {
      Get.snackbar('Invalid Input', 'Age must be between 10 and 80', backgroundColor: Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String>? allergies = _allergiesController.text.isNotEmpty 
          ? _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() 
          : null;

      await _profileController.loadExistingProfile();
      final currentData = _profileController.onboardingData.value;
      
      currentData.age = age;
      currentData.height = int.tryParse(_heightController.text);
      currentData.gender = _selectedGender;
      currentData.workoutGoal = _selectedWorkoutGoal;
      currentData.workoutLevel = _selectedWorkoutLevel;
      currentData.trainingDays = _selectedTrainingDays;
      currentData.trainingLocation = _selectedTrainingLocation;
      currentData.dietPreference = _selectedDietPreference;
      currentData.mealsPerDay = int.tryParse(_mealsPerDayController.text);
      currentData.weight = int.tryParse(_weightController.text);
      currentData.targetWeight = int.tryParse(_targetWeightController.text);
      currentData.activityLevel = _selectedActivityLevel;
      currentData.allergies = allergies;

      Get.snackbar('Generating Plan', 'Creating your personalized fitness plan...', 
          backgroundColor: Theme.of(context).colorScheme.primary, colorText: Colors.white);

      final aiPlanService = AiPlanService();
      final generatedPlans = await aiPlanService.generateWeeklyPlan(currentData);

      currentData.dietPlan = generatedPlans['diet'];
      currentData.workoutPlan = generatedPlans['workout'];

      await ProfileService().saveProfile(currentData);
      _profileController.onboardingData.value = currentData;

      _showSuccessDialog();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Plans', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Personal'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Workout'),
            Tab(icon: Icon(Icons.restaurant), text: 'Diet'),
            Tab(icon: Icon(Icons.summarize), text: 'Summary'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildPersonalInfoTab(), _buildWorkoutTab(), _buildDietTab(), _buildSummaryTab()],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Regenerate Plans & Save', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Corrected Formatter: Prevents values larger than max, but allows typing/deleting.
class _NumericRangeFormatter extends TextInputFormatter {
  final int maxValue;

  _NumericRangeFormatter({required this.maxValue});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    
    final int? value = int.tryParse(newValue.text);
    
    // If input is not a number OR it exceeds the maximum allowed, reject it.
    if (value == null || value > maxValue) {
      return oldValue;
    }
    
    // Allow the value even if it's below a "minimum" during typing,
    // otherwise the user could never type "10" if the min is 10.
    return newValue;
  }
}