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
  final String? weeklyFocus;

  WorkoutDay({
    required this.dayTitle,
    required this.muscles,
    required this.duration,
    required this.exercises,
    this.weeklyFocus,
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
    
    // Stop parsing if we hit diet plan markers
    final dietMarkers = [
      '===DIET PLAN===',
      '==DIET PLAN==',
      '[BREAKFAST]',
      '[LUNCH]',
      '[DINNER]',
      '[SNACK]',
      '[MEAL',
      'DAILY_TOTAL',
      'Name:',
      'Portions:',
      'Calories:',
      'Protein:',
      'Carbs:',
      'Fat:',
    ];
    
    // Find where diet plan starts and cut content there
    int cutIndex = content.length;
    for (final marker in dietMarkers) {
      final index = content.indexOf(marker);
      if (index != -1 && index < cutIndex) {
        cutIndex = index;
      }
    }
    
    // Only parse workout content, not diet content
    final workoutContent = content.substring(0, cutIndex);
    
    // Split content into lines for better parsing
    final lines = workoutContent.split('\n');
    
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
      for (final match in pattern.allMatches(workoutContent)) {
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
    
    // If we found exercises with numbered pattern, return them
    if (exercises.isNotEmpty) {
      return exercises;
    }
    
    // Pattern 2: Exercise name on one line, sets/reps on next line(s)
    // Example:
    // Barbell Bench Press
    // Sets: 4, Reps: 8-10
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // Skip if this line contains diet plan markers
      final lowerLine = line.toLowerCase();
      if (lowerLine.contains('name:') && 
          (lowerLine.contains('kcal') || lowerLine.contains('protein') || lowerLine.contains('carbs') || lowerLine.contains('fat'))) {
        print('⚠️ Skipping diet plan line: $line');
        break; // Stop parsing, we've hit diet content
      }

      // Check if this line contains an exercise name (not a header/metadata)
      if (_isExerciseNameLine(line)) {
        String originalName = line;
        
        // First, try to extract sets/reps from the line itself
        String? sets;
        String? reps;
        
        // Pattern: "Exercise Name: 4 sets, 8 reps" or "Exercise Name - 4 sets x 8 reps"
        final combinedPattern = RegExp(
          r'(.+?)[:\-]\s*(\d+)\s*(?:sets?|x)\s*([\d\-]+)\s*(?:reps?|repetitions?)',
          caseSensitive: false,
        );
        final combinedMatch = combinedPattern.firstMatch(originalName);
        if (combinedMatch != null) {
          sets = '${combinedMatch.group(2)} Sets';
          reps = '${combinedMatch.group(3)} Reps';
          originalName = combinedMatch.group(1)?.trim() ?? originalName;
        }
        
        // Pattern: "Exercise Name (4 sets, 8 reps)"
        final parenPattern = RegExp(
          r'(.+?)\s*\((\d+)\s*(?:sets?|x)\s*([\d\-]+)\s*(?:reps?|repetitions?)\)',
          caseSensitive: false,
        );
        final parenMatch = parenPattern.firstMatch(originalName);
        if (parenMatch != null && sets == null) {
          sets = '${parenMatch.group(2)} Sets';
          reps = '${parenMatch.group(3)} Reps';
          originalName = parenMatch.group(1)?.trim() ?? originalName;
        }
        
        String name = _cleanExerciseName(originalName);

        // Look ahead up to 3 lines for sets/reps info
        for (int j = i + 1; j < lines.length && j <= i + 3; j++) {
          final nextLine = lines[j].trim();
          if (nextLine.isEmpty) continue;
          
          // Try various patterns for sets/reps
          final setsPatterns = [
            RegExp(r'Sets?[:\-]?\s*(\d+)', caseSensitive: false),
            RegExp(r'(\d+)\s*sets?', caseSensitive: false),
            RegExp(r'(\d+)\s*x', caseSensitive: false),
          ];
          
          final repsPatterns = [
            RegExp(r'Reps?[:\-]?\s*([\d\-]+)', caseSensitive: false),
            RegExp(r'(\d+[\-]?\d*)\s*reps?', caseSensitive: false),
            RegExp(r'x\s*(\d+[\-]?\d*)', caseSensitive: false),
          ];
          
          for (final pattern in setsPatterns) {
            final match = pattern.firstMatch(nextLine);
            if (match != null && sets == null) {
              sets = '${match.group(1)} Sets';
              print('✅ Found sets: ${sets}');
              break;
            }
          }
          
          for (final pattern in repsPatterns) {
            final match = pattern.firstMatch(nextLine);
            if (match != null && reps == null) {
              reps = '${match.group(1)} Reps';
              print('✅ Found reps: ${reps}');
              break;
            }
          }
          
          // If we found both, stop looking
          if (sets != null && reps != null) break;
        }

        // Also check current line for sets/reps (in case it's all on one line)
        if (sets == null || reps == null) {
          final setsPatterns = [
            RegExp(r'Sets?[:\-]?\s*(\d+)', caseSensitive: false),
            RegExp(r'(\d+)\s*sets?', caseSensitive: false),
            RegExp(r'(\d+)\s*x', caseSensitive: false),
          ];
          
          final repsPatterns = [
            RegExp(r'Reps?[:\-]?\s*([\d\-]+)', caseSensitive: false),
            RegExp(r'(\d+[\-]?\d*)\s*reps?', caseSensitive: false),
            RegExp(r'x\s*(\d+[\-]?\d*)', caseSensitive: false),
          ];
          
          for (final pattern in setsPatterns) {
            final match = pattern.firstMatch(originalName);
            if (match != null && sets == null) {
              sets = '${match.group(1)} Sets';
              print('✅ Found sets inline: ${sets}');
              break;
            }
          }
          
          for (final pattern in repsPatterns) {
            final match = pattern.firstMatch(originalName);
            if (match != null && reps == null) {
              reps = '${match.group(1)} Reps';
              print('✅ Found reps inline: ${reps}');
              break;
            }
          }
        }

        // Only add if we have a valid name
        if (name.isNotEmpty && !seenExercises.contains(name.toLowerCase())) {
          exercises.add(Exercise(
            name: name, 
            sets: sets ?? '3 Sets', 
            reps: reps ?? '10-12 Reps'
          ));
          seenExercises.add(name.toLowerCase());
          print('✅ Added exercise: $name - ${sets ?? "3 Sets"} - ${reps ?? "10-12 Reps"}');
        }
      }
    }

    // Pattern 2: Exercise: Name, Sets: X, Reps: Y (all in one line)
    // Try multiple variations
    final exercisePatterns2 = [
      RegExp(r'(.+?)[:\-]\s*(\d+)\s*(?:sets?|x)\s*([\d\-]+)\s*(?:reps?|repetitions?)', caseSensitive: false),
      RegExp(r'(.+?)[,\-]\s*Sets?[:\-]?\s*(\d+).*?Reps?[:\-]?\s*([\d\-]+)', caseSensitive: false),
      RegExp(r'(.+?)[,\-]\s*Reps?[:\-]?\s*([\d\-]+).*?Sets?[:\-]?\s*(\d+)', caseSensitive: false),
      RegExp(r'(?:Exercise[:\-]?\s*)?(.+?)[,\-]\s*(?:Sets?[:\-]?\s*(\d+).*?Reps?[:\-]?\s*([\d\-]+)|Reps?[:\-]?\s*([\d\-]+).*?Sets?[:\-]?\s*(\d+))', caseSensitive: false),
    ];

    for (final pattern in exercisePatterns2) {
      for (final match in pattern.allMatches(workoutContent)) {
        try {
          String name = _cleanExerciseName(match.group(1)?.trim() ?? '');
          
          // Skip if this looks like diet plan content
          final lowerName = name.toLowerCase();
          if (lowerName.contains('name:') || 
              lowerName.contains('portions') || 
              lowerName.contains('calories') ||
              lowerName.contains('protein') ||
              lowerName.contains('carbs') ||
              lowerName.contains('fat') ||
              lowerName.contains('oatmeal') ||
              lowerName.contains('chicken') ||
              lowerName.contains('salmon') ||
              lowerName.contains('yogurt') ||
              lowerName.contains('meal') && (lowerName.contains('kcal') || lowerName.contains('g'))) {
            print('⚠️ Skipping diet-related content: $name');
            continue;
          }
          
          String? sets;
          String? reps;

          // Handle different group positions
          if (match.groupCount >= 3) {
            if (match.group(2) != null && match.group(3) != null) {
              // Check if group 2 is sets or reps based on context
              final group2 = match.group(2)!;
              final group3 = match.group(3)!;
              
              // Try to determine which is sets and which is reps
              // Default assumption: group 2 is sets, group 3 is reps
              // But check the match text to be sure
              try {
                final matchText = match.group(0) ?? '';
                if (matchText.toLowerCase().contains('rep') && 
                    matchText.toLowerCase().indexOf('rep') < matchText.toLowerCase().indexOf('set')) {
                  // Reps comes before sets in the text
                  sets = '$group3 Sets';
                  reps = '$group2 Reps';
                } else {
                  // Default: sets comes first
                  sets = '$group2 Sets';
                  reps = '$group3 Reps';
                }
              } catch (e) {
                // Fallback to default
                sets = '$group2 Sets';
                reps = '$group3 Reps';
              }
            } else if (match.group(4) != null && match.group(5) != null) {
              sets = '${match.group(5)} Sets';
              reps = '${match.group(4)} Reps';
            }
          }

          if (name.isNotEmpty && sets != null && reps != null && !seenExercises.contains(name.toLowerCase())) {
            exercises.add(Exercise(name: name, sets: sets, reps: reps));
            seenExercises.add(name.toLowerCase());
            print('✅ Added exercise (pattern 2): $name - $sets - $reps');
          }
        } catch (e) {
          print('⚠️ Error parsing exercise: $e');
        }
      }
    }

    // Pattern 3: Simple format: Name - X sets x Y reps
    final exercisePattern3 = RegExp(
      r'(.+?)[\-\–]\s*(\d+)\s*(?:sets?|x)\s*([\d\-]+)\s*(?:reps?|repetitions?)',
      caseSensitive: false,
    );

    for (final match in exercisePattern3.allMatches(workoutContent)) {
      try {
        String name = _cleanExerciseName(match.group(1)?.trim() ?? '');
        if (name.isNotEmpty && !seenExercises.contains(name.toLowerCase())) {
          exercises.add(Exercise(
            name: name,
            sets: '${match.group(2)} Sets',
            reps: '${match.group(3)} Reps',
          ));
          seenExercises.add(name.toLowerCase());
        }
      } catch (e) {
        print('⚠️ Error parsing exercise: $e');
      }
    }

    // Fallback: If no structured exercises found, try to extract exercise names
    if (exercises.isEmpty) {
      for (final line in lines) {
        final trimmed = line.trim();
        if (_isExerciseNameLine(trimmed) && trimmed.length > 3 && trimmed.length < 50) {
          final name = _cleanExerciseName(trimmed);
          if (name.isNotEmpty && !seenExercises.contains(name.toLowerCase())) {
            exercises.add(Exercise(
              name: name,
              sets: '3 Sets',
              reps: '10-12 Reps',
            ));
            seenExercises.add(name.toLowerCase());
          }
        }
      }
    }

    return exercises;
  }

  /// Check if a line looks like an exercise name
  static bool _isExerciseNameLine(String line) {
    final lower = line.toLowerCase();
    // Exclude headers and metadata
    if (lower.contains('day') || 
        lower.contains('muscle') || 
        lower.contains('duration') ||
        lower.contains('focus') ||
        lower.contains('tip') ||
        lower.startsWith('[') ||
        lower.contains('===') ||
        lower.length < 3) {
      return false;
    }
    
    // Exclude diet plan markers
    if (lower.startsWith('name:') ||
        lower.contains('portions:') ||
        lower.contains('calories:') ||
        lower.contains('protein:') ||
        lower.contains('carbs:') ||
        lower.contains('fat:') ||
        lower.contains('daily_total') ||
        lower.contains('[breakfast]') ||
        lower.contains('[lunch]') ||
        lower.contains('[dinner]') ||
        lower.contains('[snack]') ||
        lower.contains('[meal')) {
      return false;
    }
    
    // Check if it looks like an exercise name (has capital letters, reasonable length)
    return line.length >= 3 && line.length < 60 && RegExp(r'[A-Z]').hasMatch(line);
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

