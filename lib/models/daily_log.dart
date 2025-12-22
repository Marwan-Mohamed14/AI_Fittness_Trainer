class DailyLog {
  final String date;
  final String userId;
  final bool dietDone;
  final bool workoutDone;

  DailyLog({
    required this.date,
    required this.userId,
    required this.dietDone,
    required this.workoutDone,
  });

  factory DailyLog.fromMap(Map<String, dynamic> map) {
    return DailyLog(
      date: map['date'],
      userId: map['user_id'] ?? '',
      dietDone: map['diet_done'] == 1,
      workoutDone: map['workout_done'] == 1,
    );
  }
}
