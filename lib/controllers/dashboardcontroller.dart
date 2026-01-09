import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ai_personal_trainer/models/MonthlyStats.dart';
import 'package:ai_personal_trainer/services/Authservice.dart';
import 'package:ai_personal_trainer/data/repositories/daily_log_repository.dart';

class DashboardController extends GetxController {
  final repo = DailyLogRepository();
  final auth = AuthService();

  // Observables
  final RxList<MonthlyStats> monthlyStats = <MonthlyStats>[].obs;
  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    loading.value = true;
    final uid = auth.getCurrentUserId();
    if (uid == null) {
      loading.value = false;
      return;
    }

    try {
      final stats = await repo.getMonthlyStats(uid);
      monthlyStats.value = stats;
    } catch (e) {
      print("Error loading stats: $e");
      monthlyStats.value = [];
    }

    loading.value = false;
  }

  /// =============================
  /// Chart Data Helpers
  /// =============================

  // Get formatted month labels: "2026-01" -> "Jan 2026"
  List<String> get months {
    return monthlyStats.map((m) {
      try {
        final date = DateTime.parse('${m.month}-01');
        return DateFormat('MMM yyyy').format(date);
      } catch (e) {
        return m.month; // fallback
      }
    }).toList();
  }

  // Diet adherence percentages
  List<double> get dietPercentages {
    return monthlyStats.map((m) {
      if (m.totalDays == 0) return 0.0;
      return (m.dietDays / m.totalDays * 100);
    }).toList();
  }

  // Workout adherence percentages
  List<double> get workoutPercentages {
    return monthlyStats.map((m) {
      if (m.totalDays == 0) return 0.0;
      return (m.workoutDays / m.totalDays * 100);
    }).toList();
  }
}
