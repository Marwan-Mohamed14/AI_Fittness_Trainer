import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ai_personal_trainer/controllers/dashboardcontroller.dart';
import 'package:ai_personal_trainer/models/MonthlyStats.dart';
import 'package:fl_chart/fl_chart.dart'; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller =
        Get.put(DashboardController(), permanent: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.monthlyStats.isEmpty) {
          return const Center(
            child: Text(
              'No activity recorded yet',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // =============================
              // Chart Card with line + bars
              // =============================
              _buildChartCard(context, controller),

              const SizedBox(height: 24),

              // Monthly Stats Cards
              ...controller.monthlyStats.value
                  .map((stats) => MonthlyStatsCard(stats: stats))
                  .toList(),
            ],
          ),
        );
      }),
    );
  }

  /// ==============================
  /// Chart Card (Line + Bar Summary)
  /// ==============================
  Widget _buildChartCard(BuildContext context, DashboardController controller) {
    final theme = Theme.of(context);

    final months = controller.monthlyStats.value
        .map((m) => DateFormat.MMM().format(DateTime.parse('${m.month}-01')))
        .toList();

    final dietData = controller.monthlyStats.value
        .map((m) => m.totalDays == 0 ? 0.0 : (m.dietDays / m.totalDays * 100))
        .toList();

    final workoutData = controller.monthlyStats.value
        .map((m) => m.totalDays == 0 ? 0.0 : (m.workoutDays / m.totalDays * 100))
        .toList();

    // Convert to FlSpot for line chart
    final dietSpots = List.generate(dietData.length, (i) => FlSpot(i.toDouble(), dietData[i]));
    final workoutSpots =
        List.generate(workoutData.length, (i) => FlSpot(i.toDouble(), workoutData[i]));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // =============================
            // Line Chart
            // =============================
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= months.length) return const SizedBox();
                          return Text(
                            months[index],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 20,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}%'),
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  minX: 0,
                  maxX: (months.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: dietSpots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.green,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: workoutSpots,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.blue,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =============================
            // Original bar-like progress summary
            // =============================
            Column(
              children: List.generate(months.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(months[index], style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            flex: dietData[index].round(),
                            child: Container(
                              height: 16,
                              color: Colors.green,
                            ),
                          ),
                          Expanded(
                            flex: 100 - dietData[index].round(),
                            child: Container(
                              height: 16,
                              color: Colors.green.withOpacity(0.2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${dietData[index].round()}%',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            flex: workoutData[index].round(),
                            child: Container(
                              height: 16,
                              color: Colors.blue,
                            ),
                          ),
                          Expanded(
                            flex: 100 - workoutData[index].round(),
                            child: Container(
                              height: 16,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${workoutData[index].round()}%',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.circle, color: Colors.green, size: 12),
                SizedBox(width: 4),
                Text('Diet Adherence'),
                SizedBox(width: 16),
                Icon(Icons.circle, color: Colors.blue, size: 12),
                SizedBox(width: 4),
                Text('Workout Adherence'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ==============================
/// Monthly Stats Card
/// ==============================
class MonthlyStatsCard extends StatelessWidget {
  final MonthlyStats stats;

  const MonthlyStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final int dietPercent =
        stats.totalDays == 0 ? 0 : ((stats.dietDays / stats.totalDays) * 100).round();
    final int workoutPercent =
        stats.totalDays == 0 ? 0 : ((stats.workoutDays / stats.totalDays) * 100).round();
    final String monthLabel =
        DateFormat('MMMM yyyy').format(DateTime.parse('${stats.month}-01'));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthLabel,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ProgressRow(label: 'Diet adherence', percent: dietPercent, color: Colors.green),
            const SizedBox(height: 12),
            ProgressRow(label: 'Workout adherence', percent: workoutPercent, color: Colors.blue),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 8),
            Text(
              'Active days: ${stats.totalDays}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==============================
/// Progress Row Widget
/// ==============================
class ProgressRow extends StatelessWidget {
  final String label;
  final int percent;
  final Color color;

  const ProgressRow({super.key, required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [Text(label), const Spacer(), Text('$percent%')],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            color: color,
            backgroundColor: color.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
