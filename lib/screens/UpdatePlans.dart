import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdatePlans extends StatefulWidget {
  const UpdatePlans({super.key});

  @override
  State<UpdatePlans> createState() => _UpdatePlansState();
}

class _UpdatePlansState extends State<UpdatePlans>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for text fields
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _mealsPerDayController;
  late TextEditingController _allergiesController;

  // Selected values
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
  }

  void _initializeControllers() {
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _targetWeightController = TextEditingController();
    _mealsPerDayController = TextEditingController(text: '3');
    _allergiesController = TextEditingController();
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

  Widget _buildInputCard({
    required String label,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F2E).withOpacity(0.8),
            const Color(0xFF141722).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.deepPurple, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F111A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: Colors.deepPurple.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurple.shade700])
              : null,
          color: isSelected ? null : const Color(0xFF0F111A),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurple.shade300
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

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
                _buildTextField(
                  controller: _ageController,
                  label: 'Age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _heightController,
                  label: 'Height (cm)',
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Gender',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  children: [
                    _buildChip(
                      'Male',
                      _selectedGender == 'Male',
                      () => setState(() => _selectedGender = 'Male'),
                    ),
                    _buildChip(
                      'Female',
                      _selectedGender == 'Female',
                      () => setState(() => _selectedGender = 'Female'),
                    ),
                    
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
                _buildTextField(
                  controller: _weightController,
                  label: 'Current Weight (kg)',
                  icon: Icons.scale,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _targetWeightController,
                  label: 'Target Weight (kg)',
                  icon: Icons.flag_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          _buildInputCard(
            label: 'Activity Level',
            icon: Icons.directions_run,
            child: Wrap(
              children: [
                _buildChip(
                  'Low',
                  _selectedActivityLevel == 'Low',
                  () => setState(() => _selectedActivityLevel = 'Low'),
                ),
                _buildChip(
                  'Medium',
                  _selectedActivityLevel == 'Medium',
                  () => setState(() => _selectedActivityLevel = 'Medium'),
                ),
                _buildChip(
                  'High',
                  _selectedActivityLevel == 'High',
                  () => setState(() => _selectedActivityLevel = 'High'),
                ),
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
              children: [
                _buildChip(
                  'Lose Weight',
                  _selectedWorkoutGoal == 'Lose Weight',
                  () => setState(() => _selectedWorkoutGoal = 'Lose Weight'),
                ),
                _buildChip(
                  'Build Muscle',
                  _selectedWorkoutGoal == 'Build Muscle',
                  () => setState(() => _selectedWorkoutGoal = 'Build Muscle'),
                ),
                _buildChip(
                  'Gain Strength',
                  _selectedWorkoutGoal == 'Gain Strength',
                  () => setState(() => _selectedWorkoutGoal = 'Gain Strength'),
                ),
                _buildChip(
                  'Maintain Fitness',
                  _selectedWorkoutGoal == 'Maintain Fitness',
                  () => setState(() => _selectedWorkoutGoal = 'Maintain Fitness'),
                ),
              ],
            ),
          ),
          _buildInputCard(
            label: 'Experience Level',
            icon: Icons.trending_up,
            child: Wrap(
              children: [
                _buildChip(
                  'Beginner',
                  _selectedWorkoutLevel == 'Beginner',
                  () => setState(() => _selectedWorkoutLevel = 'Beginner'),
                ),
                _buildChip(
                  'Intermediate',
                  _selectedWorkoutLevel == 'Intermediate',
                  () => setState(() => _selectedWorkoutLevel = 'Intermediate'),
                ),
                _buildChip(
                  'Advanced',
                  _selectedWorkoutLevel == 'Advanced',
                  () => setState(() => _selectedWorkoutLevel = 'Advanced'),
                ),
              ],
            ),
          ),
          _buildInputCard(
            label: 'Training Frequency',
            icon: Icons.calendar_today,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Days per week',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  children: List.generate(7, (i) {
                    int days = i + 1;
                    return _buildChip(
                      '$days ${days == 1 ? 'Day' : 'Days'}',
                      _selectedTrainingDays == days,
                      () => setState(() => _selectedTrainingDays = days),
                    );
                  }),
                ),
              ],
            ),
          ),
          _buildInputCard(
            label: 'Training Location',
            icon: Icons.place_outlined,
            child: Wrap(
              children: [
                _buildChip(
                  'Gym',
                  _selectedTrainingLocation == 'Gym',
                  () => setState(() => _selectedTrainingLocation = 'Gym'),
                ),
                _buildChip(
                  'Home',
                  _selectedTrainingLocation == 'Home',
                  () => setState(() => _selectedTrainingLocation = 'Home'),
                ),
              ],
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
              children: [
                _buildChip(
                  'Low-Carb',
                  _selectedDietPreference == 'Low-Carb',
                  () => setState(() => _selectedDietPreference = 'Low-Carb'),
                ),
                _buildChip(
                  'Normal',
                  _selectedDietPreference == 'Normal',
                  () => setState(() => _selectedDietPreference = 'Normal'),
                ),
                _buildChip(
                  'High-Protein',
                  _selectedDietPreference == 'High-Protein',
                  () => setState(() => _selectedDietPreference = 'High-Protein'),
                ),
                _buildChip(
                  'Vegetarian',
                  _selectedDietPreference == 'Vegetarian',
                  () => setState(() => _selectedDietPreference = 'Vegetarian'),
                ),
                _buildChip(
                  'Vegan',
                  _selectedDietPreference == 'Vegan',
                  () => setState(() => _selectedDietPreference = 'Vegan'),
                ),
              ],
            ),
          ),
          _buildInputCard(
            label: 'Meal Planning',
            icon: Icons.restaurant_outlined,
            child: _buildTextField(
              controller: _mealsPerDayController,
              label: 'Meals Per Day',
              icon: Icons.dining_outlined,
              keyboardType: TextInputType.number,
            ),
          ),
          _buildInputCard(
            label: 'Food Restrictions',
            icon: Icons.warning_amber_rounded,
            child: _buildTextField(
              controller: _allergiesController,
              label: 'Allergies (comma separated)',
              icon: Icons.info_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInputCard(
            label: 'Profile Summary',
            icon: Icons.summarize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Age', _ageController.text.isEmpty ? 'Not set' : '${_ageController.text} years'),
                _buildSummaryRow('Height', _heightController.text.isEmpty ? 'Not set' : '${_heightController.text} cm'),
                _buildSummaryRow('Gender', _selectedGender ?? 'Not set'),
                _buildSummaryRow('Current Weight', _weightController.text.isEmpty ? 'Not set' : '${_weightController.text} kg'),
                _buildSummaryRow('Target Weight', _targetWeightController.text.isEmpty ? 'Not set' : '${_targetWeightController.text} kg'),
                _buildSummaryRow('Activity Level', _selectedActivityLevel ?? 'Not set'),
                _buildSummaryRow('Workout Goal', _selectedWorkoutGoal ?? 'Not set'),
                _buildSummaryRow('Experience', _selectedWorkoutLevel ?? 'Not set'),
                _buildSummaryRow('Training Days', _selectedTrainingDays == null ? 'Not set' : '$_selectedTrainingDays days/week'),
                _buildSummaryRow('Location', _selectedTrainingLocation ?? 'Not set'),
                _buildSummaryRow('Diet Type', _selectedDietPreference ?? 'Not set'),
                _buildSummaryRow('Meals/Day', _mealsPerDayController.text.isEmpty ? 'Not set' : '${_mealsPerDayController.text}'),
                if (_allergiesController.text.isNotEmpty)
                  _buildSummaryRow('Allergies', _allergiesController.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    // Just navigate back - no backend saving
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Update Plans',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurple,
          indicatorWeight: 3,
          labelColor: Colors.deepPurple,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.person, size: 20), text: 'Personal'),
            Tab(icon: Icon(Icons.fitness_center, size: 20), text: 'Workout'),
            Tab(icon: Icon(Icons.restaurant, size: 20), text: 'Diet'),
            Tab(icon: Icon(Icons.summarize, size: 20), text: 'Summary'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalInfoTab(),
                _buildWorkoutTab(),
                _buildDietTab(),
                _buildSummaryTab(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F111A),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _saveProfile,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Save All Changes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}