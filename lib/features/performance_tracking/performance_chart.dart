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

      final calories = (log['calories'] ?? log['calories_burned']) ?? 0;
      final duration = (log['duration'] ?? log['workout_duration']) ?? 0;
      final date = log['date']?.toString() ?? DateTime.now().toIso8601String();

      caloriesSpots.add(
        FlSpot(i.toDouble(), (calories is num) ? calories.toDouble() : double.tryParse(calories.toString()) ?? 0.0),
      );
      durationSpots.add(
        FlSpot(i.toDouble(), (duration is num) ? duration.toDouble() : double.tryParse(duration.toString()) ?? 0.0),
      );
      dates.add(date);
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
                    try {
                      return Text(
                        DateFormat.Md().format(DateTime.parse(dates[index])),
                        style: const TextStyle(fontSize: 10),
                      );
                    } catch (e) {
                      return const Text('');
                    }
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text("Calories / Duration"),
              sideTitles: SideTitles(showTitles: true),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
