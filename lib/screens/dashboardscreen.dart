import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ai_personal_trainer/controllers/dashboardcontroller.dart';
import 'package:ai_personal_trainer/models/MonthlyStats.dart';
import 'package:ai_personal_trainer/utils/responsive.dart';
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
          padding: Responsive.horizontalPadding(context),
          child: Column(
            children: [
              // =============================
              // Chart Card with line + bars
              // =============================
              _buildChartCard(context, controller),

              const SizedBox(height: 24),

              // Monthly Stats Cards
              ...controller.monthlyStats
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

    final months = controller.monthlyStats
        .map((m) => DateFormat.MMM().format(DateTime.parse('${m.month}-01')))
        .toList();

    final dietData = controller.monthlyStats
        .map((m) => m.totalDays == 0 ? 0.0 : (m.dietDays / m.totalDays * 100))
        .toList();

    final workoutData = controller.monthlyStats
        .map((m) => m.totalDays == 0 ? 0.0 : (m.workoutDays / m.totalDays * 100))
        .toList();

    // Convert to FlSpot for line chart
    final dietSpots = List.generate(dietData.length, (i) => FlSpot(i.toDouble(), dietData[i]));
    final workoutSpots =
        List.generate(workoutData.length, (i) => FlSpot(i.toDouble(), workoutData[i]));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.borderRadius(context, mobile: 18))),
      elevation: 4,
      child: Padding(
        padding: Responsive.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, mobile: 16, tablet: 18, desktop: 20),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 16, tablet: 20, desktop: 24)),

            // =============================
            // Line Chart
            // =============================
            SizedBox(
              height: Responsive.fontSize(context, mobile: 180, tablet: 220, desktop: 260),
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

            SizedBox(height: Responsive.spacing(context, mobile: 16, tablet: 20, desktop: 24)),

            // =============================
            // Original bar-like progress summary
            // =============================
   

            SizedBox(height: Responsive.spacing(context, mobile: 12, tablet: 16, desktop: 20)),
            Wrap(
              spacing: Responsive.spacing(context, mobile: 16, tablet: 20),
              runSpacing: Responsive.spacing(context, mobile: 8, tablet: 12),
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: Responsive.iconSize(context, mobile: 12, tablet: 14)),
                    SizedBox(width: Responsive.spacing(context, mobile: 4)),
                    Text('Diet Adherence', style: TextStyle(fontSize: Responsive.fontSize(context, mobile: 12, tablet: 14))),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.blue, size: Responsive.iconSize(context, mobile: 12, tablet: 14)),
                    SizedBox(width: Responsive.spacing(context, mobile: 4)),
                    Flexible(
                      child: Text(
                        'Workout Adherence',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: Responsive.fontSize(context, mobile: 12, tablet: 14)),
                      ),
                    ),
                  ],
                ),
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
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, mobile: 16, tablet: 20)),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.borderRadius(context, mobile: 18))),
      child: Padding(
        padding: Responsive.cardPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, mobile: 16, tablet: 18, desktop: 20),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, mobile: 16, tablet: 20)),
            ProgressRow(label: 'Diet adherence', percent: dietPercent, color: Colors.green),
            SizedBox(height: Responsive.spacing(context, mobile: 12, tablet: 16)),
            ProgressRow(label: 'Workout adherence', percent: workoutPercent, color: Colors.blue),
            SizedBox(height: Responsive.spacing(context, mobile: 12, tablet: 16)),
            Divider(color: Colors.grey.withOpacity(0.3)),
            SizedBox(height: Responsive.spacing(context, mobile: 8, tablet: 12)),
            Text(
              'Active days: ${stats.totalDays}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: Responsive.fontSize(context, mobile: 12, tablet: 14),
              ),
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
          children: [
            Text(label, style: TextStyle(fontSize: Responsive.fontSize(context, mobile: 14, tablet: 16))),
            const Spacer(),
            Text('$percent%', style: TextStyle(fontSize: Responsive.fontSize(context, mobile: 14, tablet: 16))),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 6, tablet: 8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(Responsive.borderRadius(context, mobile: 10)),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: Responsive.fontSize(context, mobile: 8, tablet: 10),
            color: color,
            backgroundColor: color.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}
