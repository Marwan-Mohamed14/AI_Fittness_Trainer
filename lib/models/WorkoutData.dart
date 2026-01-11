class Exercise {
  final String name;
  final String sets;
  final String reps;
  final String? videoUrl;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.videoUrl,
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

 
      String? weeklyFocus = _extractWeeklyFocus(workoutPlanText);

    
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

 
  static String? _extractWeeklyFocus(String text) {
    try {
     
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


  static List<WorkoutDay> _extractWorkoutDays(String text) {
    final List<WorkoutDay> days = [];

 
    final dayPattern1 = RegExp(
      r'\[DAY\s+(\d+)\s*-\s*([^\]]+)\](.*?)(?=\[DAY\s+\d+|$)',
      dotAll: true,
      caseSensitive: false,
    );

  
    final dayPattern2 = RegExp(
      r'\[DAY\s+(\d+)\](.*?)(?=\[DAY\s+\d+\]|$)',
      dotAll: true,
      caseSensitive: false,
    );

    
    final dayPattern3 = RegExp(
      r'Day\s+(\d+)[:\-\s]+([^:\n]+)?[:\-]?(.*?)(?=Day\s+\d+[:\-]|$)',
      dotAll: true,
      caseSensitive: false,
    );

  
    final dayPattern4 = RegExp(
      r'(Push\s+Day|Pull\s+Day|Leg\s+Day|Upper\s+Body|Lower\s+Body|Full\s+Body|Cardio\s+Day|Rest\s+Day)[:\-]?(.*?)(?=(?:Push|Pull|Leg|Upper|Lower|Full|Cardio|Rest)\s+Day|$)',
      dotAll: true,
      caseSensitive: false,
    );

 
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

  
    if (days.isEmpty) {
      final day = _parseDayContent(text, 'Workout Day', '');
      if (day != null) days.add(day);
    }

    return days;
  }


  static WorkoutDay? _parseDayContent(String content, String defaultTitle, String muscleGroup) {
    try {
      print('🔍 Parsing day content for: $defaultTitle');
      print('📄 Day content (first 300 chars): ${content.length > 300 ? content.substring(0, 300) + "..." : content}');
      
  
      String dayTitle = defaultTitle;
      String muscles = muscleGroup.isNotEmpty ? muscleGroup.toUpperCase() : '';

   
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
      

      if (muscles.isEmpty) {
        muscles = 'FULL BODY';
      }

 
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


  static List<Exercise> _extractExercises(String content) {
    final List<Exercise> exercises = [];
    final Set<String> seenExercises = {};

    print('🔍 Extracting exercises from content (${content.length} chars)');
    

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
    
  
    int cutIndex = content.length;
    for (final marker in dietMarkers) {
      final index = content.indexOf(marker);
      if (index != -1 && index < cutIndex) {
        cutIndex = index;
      }
    }
    
   
    final workoutContent = content.substring(0, cutIndex);
    
  
    final lines = workoutContent.split('\n');
    
 
    final numberedPatterns = [
      RegExp(r'\d+[\.\)]\s*(.+?)[:\-]\s*(\d+)\s*sets?[,\s]+(\d+[\-]?\d*)\s*reps?', caseSensitive: false),
      RegExp(r'\d+[\.\)]\s*(.+?)[:\-]\s*(\d+)\s*sets?,\s*(\d+[\-]?\d*)\s*reps?', caseSensitive: false),
      RegExp(r'\d+[\.\)]\s*(.+?)[:\-]\s*(\d+)\s*sets?\s+(\d+[\-]?\d*)\s*reps?', caseSensitive: false),
    ];
    
    print('🔍 Looking for numbered exercises...');
    
    for (final pattern in numberedPatterns) {
      for (final match in pattern.allMatches(workoutContent)) {
        try {
        
          String name = match.group(1)?.trim() ?? '';
          String sets = '${match.group(2)} Sets';
          String reps = '${match.group(3)} Reps';
          
       
          name = _cleanExerciseName(name);
          
          if (name.isNotEmpty && !seenExercises.contains(name.toLowerCase())) {
            // Look for video URL in the lines after this exercise
            String? videoUrl = _extractVideoUrlForExercise(workoutContent, match.end, name);
            
            exercises.add(Exercise(name: name, sets: sets, reps: reps, videoUrl: videoUrl));
            seenExercises.add(name.toLowerCase());
            print('✅ Added exercise (numbered): $name - $sets - $reps${videoUrl != null ? " - Video: $videoUrl" : ""}');
          }
        } catch (e) {
          print('⚠️ Error parsing numbered exercise: $e');
        }
      }
    }
    
 
    if (exercises.isNotEmpty) {
      return exercises;
    }
    

    if (exercises.isNotEmpty) {
      return exercises;
    }
    

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
   
      final lowerLine = line.toLowerCase();
      if (lowerLine.contains('name:') && 
          (lowerLine.contains('kcal') || lowerLine.contains('protein') || lowerLine.contains('carbs') || lowerLine.contains('fat'))) {
        print('⚠️ Skipping diet plan line: $line');
        break; 
      }

     
      if (_isExerciseNameLine(line)) {
        String originalName = line;
        
     
        String? sets;
        String? reps;
        
      
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


        for (int j = i + 1; j < lines.length && j <= i + 3; j++) {
          final nextLine = lines[j].trim();
          if (nextLine.isEmpty) continue;
          
        
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
          
       
          if (sets != null && reps != null) break;
        }

     
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

    
          if (match.groupCount >= 3) {
            if (match.group(2) != null && match.group(3) != null) {
              // Check if group 2 is sets or reps based on context
              final group2 = match.group(2)!;
              final group3 = match.group(3)!;
              
           
              try {
                final matchText = match.group(0) ?? '';
                if (matchText.toLowerCase().contains('rep') && 
                    matchText.toLowerCase().indexOf('rep') < matchText.toLowerCase().indexOf('set')) {
              
                  sets = '$group3 Sets';
                  reps = '$group2 Reps';
                } else {
              
                  sets = '$group2 Sets';
                  reps = '$group3 Reps';
                }
              } catch (e) {
            
                sets = '$group2 Sets';
                reps = '$group3 Reps';
              }
            } else if (match.group(4) != null && match.group(5) != null) {
              sets = '${match.group(5)} Sets';
              reps = '${match.group(4)} Reps';
            }
          }

          if (name.isNotEmpty && sets != null && reps != null && !seenExercises.contains(name.toLowerCase())) {
            // Look for video URL in the match context
            String? videoUrl = _extractVideoUrlForExercise(workoutContent, match.end, name);
            
            exercises.add(Exercise(name: name, sets: sets, reps: reps, videoUrl: videoUrl));
            seenExercises.add(name.toLowerCase());
            print('✅ Added exercise (pattern 2): $name - $sets - $reps${videoUrl != null ? " - Video: $videoUrl" : ""}');
          }
        } catch (e) {
          print('⚠️ Error parsing exercise: $e');
        }
      }
    }

   
    final exercisePattern3 = RegExp(
      r'(.+?)[\-\–]\s*(\d+)\s*(?:sets?|x)\s*([\d\-]+)\s*(?:reps?|repetitions?)',
      caseSensitive: false,
    );

    for (final match in exercisePattern3.allMatches(workoutContent)) {
      try {
        String name = _cleanExerciseName(match.group(1)?.trim() ?? '');
        if (name.isNotEmpty && !seenExercises.contains(name.toLowerCase())) {
          String? videoUrl = _extractVideoUrlForExercise(workoutContent, match.end, name);
          
          exercises.add(Exercise(
            name: name,
            sets: '${match.group(2)} Sets',
            reps: '${match.group(3)} Reps',
            videoUrl: videoUrl,
          ));
          seenExercises.add(name.toLowerCase());
        }
      } catch (e) {
        print('⚠️ Error parsing exercise: $e');
      }
    }

 
    if (exercises.isEmpty) {
      for (final line in lines) {
        final trimmed = line.trim();
        if (_isExerciseNameLine(trimmed) && trimmed.length > 3 && trimmed.length < 50) {
          final name = _cleanExerciseName(trimmed);
          if (name.isNotEmpty && !seenExercises.contains(name.toLowerCase())) {
            // Look for video URL in surrounding lines
            int lineIndex = lines.indexOf(trimmed);
            String? videoUrl;
            if (lineIndex >= 0 && lineIndex + 1 < lines.length) {
              for (int j = lineIndex + 1; j < lines.length && j <= lineIndex + 5; j++) {
                final videoMatch = RegExp(r'(?:Video\s+URL?[:\-]?\s*|Video[:\-]?\s*)(https?://[^\s]+)', caseSensitive: false)
                    .firstMatch(lines[j]);
                if (videoMatch != null) {
                  videoUrl = videoMatch.group(1)?.trim();
                  break;
                }
              }
            }
            
            exercises.add(Exercise(
              name: name,
              sets: '3 Sets',
              reps: '10-12 Reps',
              videoUrl: videoUrl,
            ));
            seenExercises.add(name.toLowerCase());
          }
        }
      }
    }

    return exercises;
  }

 
  static bool _isExerciseNameLine(String line) {
    final lower = line.toLowerCase();
 
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
    
 
    return line.length >= 3 && line.length < 60 && RegExp(r'[A-Z]').hasMatch(line);
  }

  
  static String _cleanExerciseName(String name) {
 
    String cleaned = name
        .replaceAll(RegExp(r'^(Exercise[:\-]?\s*|\d+[\.\)]\s*|[-•]\s*)', caseSensitive: false), '')
        .replaceAll(RegExp(r'[:\-]\s*\d+\s*(?:sets?|reps?|x)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\d+\s*(?:sets?|reps?|x)\s*\d+', caseSensitive: false), '')
        .replaceAll(RegExp(r'Sets?[:\-]?\s*\d+', caseSensitive: false), '')
        .replaceAll(RegExp(r'Reps?[:\-]?\s*[\d\-]+', caseSensitive: false), '')
        .replaceAll(RegExp(r',\s*\d+\s*(?:sets?|reps?)', caseSensitive: false), '')
        .replaceAll(RegExp(r'[⭐★☆]', caseSensitive: false), '') // Remove star emojis
        .replaceAll(RegExp(r'\s*star\s*', caseSensitive: true), ' ') // Remove "star" text
        .replaceAll('**', '') // Remove Markdown bold markers (double asterisks)
        .trim();
    

    cleaned = cleaned.replaceAll(RegExp(r'[:\-,\s]+$'), '').trim();
    
    return cleaned;
  }

  // Extract video URL for an exercise from the workout content
  static String? _extractVideoUrlForExercise(String content, int startPosition, String exerciseName) {
    try {
      // Look for video URL in the next 500 characters after the exercise
      final searchArea = content.substring(
        startPosition, 
        (startPosition + 500 < content.length) ? startPosition + 500 : content.length
      );
      
      // Try multiple patterns for video URL
      final videoPatterns = [
        // Pattern 1: "Video URL: https://..."
        RegExp(r'Video\s+URL[:\-]?\s*(https?://[^\s\n]+)', caseSensitive: false),
        // Pattern 2: "Video: https://..."
        RegExp(r'Video[:\-]\s*(https?://[^\s\n]+)', caseSensitive: false),
        // Pattern 3: Just a YouTube URL on the next line
        RegExp(r'(https?://(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/results\?search_query=)[^\s\n]+)', caseSensitive: false),
      ];
      
      for (final pattern in videoPatterns) {
        final match = pattern.firstMatch(searchArea);
        if (match != null) {
          String url = match.group(1)?.trim() ?? '';
          // Clean up URL - remove any trailing punctuation or brackets
          url = url.replaceAll(RegExp(r'[.,;:!?)\]}>]+$'), '');
          
          // Validate it's a YouTube URL and normalize it
          if (url.contains('youtube.com') || url.contains('youtu.be')) {
            // Basic validation - ensure it's a proper YouTube URL
            if (url.contains('youtube.com/watch?v=') || 
                url.contains('youtu.be/') || 
                url.contains('youtube.com/results?search_query=')) {
              return url;
            }
          }
        }
      }
      
      return null;
    } catch (e) {
      print('⚠️ Error extracting video URL for $exerciseName: $e');
      return null;
    }
  }
}

