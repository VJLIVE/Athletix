import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> logs;

  const PerformanceChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> caloriesSpots = [];
    final List<FlSpot> durationSpots = [];
    final List<String> dates = [];

    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      caloriesSpots.add(FlSpot(i.toDouble(), log['calories_burned'].toDouble()));
      durationSpots.add(FlSpot(i.toDouble(), log['workout_duration'].toDouble()));
      dates.add(log['date']);
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: const Text("Date"),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < dates.length) {
                    return Text(DateFormat.Md().format(DateTime.parse(dates[index])));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text("Calories"),
              sideTitles: SideTitles(showTitles: true),
            ),
            rightTitles: AxisTitles(
              axisNameWidget: const Text("Duration"),
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: caloriesSpots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
            LineChartBarData(
              spots: durationSpots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}
