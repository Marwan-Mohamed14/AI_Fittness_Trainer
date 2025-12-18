class Exercise {
  final String name;
  final String sets;
  final String reps;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
  });
}

class WorkoutDay {
  final String dayTitle;
  final String muscles;
  final String duration;
  final List<Exercise> exercises;

  WorkoutDay({
    required this.dayTitle,
    required this.muscles,
    required this.duration,
    required this.exercises,
  });
}

class WorkoutPlan {
  final List<WorkoutDay> days;
  final String? weeklyFocus;

  WorkoutPlan({
    required this.days,
    this.weeklyFocus,
  });
}

class WorkoutPlanParser {
  /// Parse workout plan text into structured data
  static WorkoutPlan? parseWorkoutPlan(String workoutPlanText) {
    try {
      print('🔍 Parsing workout plan...');
      print('📄 Workout plan text (first 500 chars):');
      print(workoutPlanText.length > 500 ? workoutPlanText.substring(0, 500) + '...' : workoutPlanText);
      print('📄 Full workout plan text length: ${workoutPlanText.length}');

      if (workoutPlanText.isEmpty) {
        print('⚠️ Empty workout plan text');
        return null;
      }

      // Extract weekly focus if present
      String? weeklyFocus = _extractWeeklyFocus(workoutPlanText);

      // Extract workout days
      final days = _extractWorkoutDays(workoutPlanText);

      if (days.isEmpty) {
        print('⚠️ No workout days found');
        return null;
      }

      print('✅ Workout plan parsed successfully! Found ${days.length} days');

      return WorkoutPlan(
        days: days,
        weeklyFocus: weeklyFocus,
      );
    } catch (e) {
      print('❌ Error parsing workout plan: $e');
      return null;
    }
  }

  /// Extract weekly focus message
  static String? _extractWeeklyFocus(String text) {
    try {
      // Look for patterns like "Weekly Focus:", "Focus:", "Tip:", etc.
      final focusPatterns = [
        RegExp(r'Weekly\s+Focus[:\-]?\s*(.+?)(?:\n\n|\[|DAY|===)', dotAll: true, caseSensitive: false),
        RegExp(r'Focus[:\-]?\s*(.+?)(?:\n\n|\[|DAY|===)', dotAll: true, caseSensitive: false),
        RegExp(r'Tip[:\-]?\s*(.+?)(?:\n\n|\[|DAY|===)', dotAll: true, caseSensitive: false),
      ];

      for (final pattern in focusPatterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          final focus = match.group(1)?.trim();
          if (focus != null && focus.isNotEmpty && focus.length < 200) {
            return focus;
          }
        }
      }
      return null;
    } catch (e) {
      print('⚠️ Error extracting weekly focus: $e');
      return null;
    }
  }

  /// Extract all workout days from the text
  static List<WorkoutDay> _extractWorkoutDays(String text) {
    final List<WorkoutDay> days = [];

    // Pattern 1: [DAY X - MUSCLE GROUP] format (most common)
    final dayPattern1 = RegExp(
      r'\[DAY\s+(\d+)\s*-\s*([^\]]+)\](.*?)(?=\[DAY\s+\d+|$)',
      dotAll: true,
      caseSensitive: false,
    );

    // Pattern 2: [DAY X] format
    final dayPattern2 = RegExp(
      r'\[DAY\s+(\d+)\](.*?)(?=\[DAY\s+\d+\]|$)',
      dotAll: true,
      caseSensitive: false,
    );

    // Pattern 3: Day X:, Day X - format
    final dayPattern3 = RegExp(
      r'Day\s+(\d+)[:\-\s]+([^:\n]+)?[:\-]?(.*?)(?=Day\s+\d+[:\-]|$)',
      dotAll: true,
      caseSensitive: false,
    );

    // Pattern 4: Push Day, Pull Day, Leg Day, etc.
    final dayPattern4 = RegExp(
      r'(Push\s+Day|Pull\s+Day|Leg\s+Day|Upper\s+Body|Lower\s+Body|Full\s+Body|Cardio\s+Day|Rest\s+Day)[:\-]?(.*?)(?=(?:Push|Pull|Leg|Upper|Lower|Full|Cardio|Rest)\s+Day|$)',
      dotAll: true,
      caseSensitive: false,
    );

    // Try pattern 1 first (most specific)
    final matches1 = dayPattern1.allMatches(text);
    if (matches1.isNotEmpty) {
      for (final match in matches1) {
        final dayNumber = match.group(1) ?? '';
        final muscleGroup = match.group(2)?.trim() ?? '';
        final dayContent = match.group(3) ?? '';
        final dayTitle = muscleGroup.isNotEmpty 
            ? 'Day $dayNumber - ${muscleGroup.toUpperCase()}'
            : 'Day $dayNumber';
        final day = _parseDayContent(dayContent, dayTitle, muscleGroup);
        if (day != null) days.add(day);
      }
      if (days.isNotEmpty) return days;
    }

    // Try pattern 2
    final matches2 = dayPattern2.allMatches(text);
    if (matches2.isNotEmpty) {
      for (final match in matches2) {
        final dayNumber = match.group(1) ?? '';
        final dayContent = match.group(2) ?? '';
        final day = _parseDayContent(dayContent, 'Day $dayNumber', '');
        if (day != null) days.add(day);
      }
      if (days.isNotEmpty) return days;
    }

    // Try pattern 3
    final matches3 = dayPattern3.allMatches(text);
    if (matches3.isNotEmpty) {
      for (final match in matches3) {
        final dayNumber = match.group(1) ?? '';
        final muscleGroup = match.group(2)?.trim() ?? '';
        final dayContent = match.group(3) ?? '';
        final dayTitle = muscleGroup.isNotEmpty 
            ? 'Day $dayNumber - ${muscleGroup.toUpperCase()}'
            : 'Day $dayNumber';
        final day = _parseDayContent(dayContent, dayTitle, muscleGroup);
        if (day != null) days.add(day);
      }
      if (days.isNotEmpty) return days;
    }

    // Try pattern 4
    final matches4 = dayPattern4.allMatches(text);
    if (matches4.isNotEmpty) {
      for (final match in matches4) {
        final dayTitle = match.group(1) ?? '';
        final dayContent = match.group(2) ?? '';
        final day = _parseDayContent(dayContent, dayTitle, '');
        if (day != null) days.add(day);
      }
      if (days.isNotEmpty) return days;
    }

    // Fallback: Try to parse the entire text as a single day
    if (days.isEmpty) {
      final day = _parseDayContent(text, 'Workout Day', '');
      if (day != null) days.add(day);
    }

    return days;
  }

  /// Parse a single day's content
  static WorkoutDay? _parseDayContent(String content, String defaultTitle, String muscleGroup) {
    try {
      print('🔍 Parsing day content for: $defaultTitle');
      print('📄 Day content (first 300 chars): ${content.length > 300 ? content.substring(0, 300) + "..." : content}');
      
      // Use the provided title and muscle group
      String dayTitle = defaultTitle;
      String muscles = muscleGroup.isNotEmpty ? muscleGroup.toUpperCase() : '';

      // If muscle group wasn't provided, try to extract it
      if (muscles.isEmpty) {
        final musclesPatterns = [
          RegExp(r'Muscles?[:\-]?\s*(.+?)(?:\n|Duration|Exercises|$)', caseSensitive: false),
          RegExp(r'Target[:\-]?\s*(.+?)(?:\n|Duration|Exercises|$)', caseSensitive: false),
          RegExp(r'(CHEST|SHOULDERS|TRICEPS|BACK|BICEPS|QUADS|HAMS|CALVES|GLUTES|ARMS|LEGS)(?:\s*•\s*(CHEST|SHOULDERS|TRICEPS|BACK|BICEPS|QUADS|HAMS|CALVES|GLUTES|ARMS|LEGS))*', caseSensitive: false),
        ];

        for (final pattern in musclesPatterns) {
          final match = pattern.firstMatch(content);
          if (match != null) {
            muscles = match.group(0)?.trim().toUpperCase() ?? '';
            if (muscles.isNotEmpty) break;
          }
        }
      }
      
      // If still no muscles found, default to FULL BODY
      if (muscles.isEmpty) {
        muscles = 'FULL BODY';
      }

      // Extract duration
      String duration = '45 Min';
      final durationPatterns = [
        RegExp(r'Duration[:\-]?\s*(\d+\s*(?:Min|min|minutes?))', caseSensitive: false),
        RegExp(r'(\d+\s*(?:Min|min|minutes?))', caseSensitive: false),
      ];

      for (final pattern in durationPatterns) {
        final match = pattern.firstMatch(content);
        if (match != null) {
          duration = match.group(1)?.trim() ?? '45 Min';
          break;
        }
      }

      // Extract exercises
      final exercises = _extractExercises(content);

      if (exercises.isEmpty) {
        print('⚠️ No exercises found for $dayTitle');
        return null;
      }

      return WorkoutDay(
        dayTitle: dayTitle,
        muscles: muscles,
        duration: duration,
        exercises: exercises,
      );
    } catch (e) {
      print('❌ Error parsing day content: $e');
      return null;
    }
  }

  /// Extract exercises from day content
  static List<Exercise> _extractExercises(String content) {
    final List<Exercise> exercises = [];
    final Set<String> seenExercises = {}; // To avoid duplicates

    print('🔍 Extracting exercises from content (${content.length} chars)');
    
    // Split content into lines for better parsing
    final lines = content.split('\n');
    
    // Pattern 1: Numbered format "1. Exercise Name: X sets, Y reps" (most common format)
    // Matches: "1. Barbell Bench Press: 4 sets, 8 reps"
    // Try multiple variations of the pattern
    final numberedPatterns = [
      RegExp(r'\d+[\.\)]\s*(.+?)[:\-]\s*(\d+)\s*sets?[,\s]+(\d+[\-]?\d*)\s*reps?', caseSensitive: false),
      RegExp(r'\d+[\.\)]\s*(.+?)[:\-]\s*(\d+)\s*sets?,\s*(\d+[\-]?\d*)\s*reps?', caseSensitive: false),
      RegExp(r'\d+[\.\)]\s*(.+?)[:\-]\s*(\d+)\s*sets?\s+(\d+[\-]?\d*)\s*reps?', caseSensitive: false),
    ];
    
    print('🔍 Looking for numbered exercises...');
    
    for (final pattern in numberedPatterns) {
      for (final match in pattern.allMatches(content)) {
        try {
          // Extract the exercise name - it's already clean from the regex, just trim it
          String name = match.group(1)?.trim() ?? '';
          String sets = '${match.group(2)} Sets';
          String reps = '${match.group(3)} Reps';
          
          // Clean the name to remove any trailing colons or dashes
          name = name.replaceAll(RegExp(r'[:\-,\s]+$'), '').trim();
          
          if (name.isNotEmpty && !seenExercises.contains(name.toLowerCase())) {
            exercises.add(Exercise(name: name, sets: sets, reps: reps));
            seenExercises.add(name.toLowerCase());
            print('✅ Added exercise (numbered): $name - $sets - $reps');
          }
        } catch (e) {
          print('⚠️ Error parsing numbered exercise: $e');
        }
      }
    }
    
    // If we found exercises with numbered pattern, return them
    if (exercises.isNotEmpty) {
      return exercises;
    }

    return exercises;
  }


  /// Clean exercise name from common prefixes and sets/reps
  static String _cleanExerciseName(String name) {
    // Remove sets and reps from the name
    String cleaned = name
        .replaceAll(RegExp(r'^(Exercise[:\-]?\s*|\d+[\.\)]\s*|[-•]\s*)', caseSensitive: false), '')
        .replaceAll(RegExp(r'[:\-]\s*\d+\s*(?:sets?|reps?|x)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\d+\s*(?:sets?|reps?|x)\s*\d+', caseSensitive: false), '')
        .replaceAll(RegExp(r'Sets?[:\-]?\s*\d+', caseSensitive: false), '')
        .replaceAll(RegExp(r'Reps?[:\-]?\s*[\d\-]+', caseSensitive: false), '')
        .replaceAll(RegExp(r',\s*\d+\s*(?:sets?|reps?)', caseSensitive: false), '')
        .trim();
    
    // Remove trailing colons, dashes, or commas
    cleaned = cleaned.replaceAll(RegExp(r'[:\-,\s]+$'), '').trim();
    
    return cleaned;
  }
}

