import 'package:flutter/material.dart';
import 'performance_chart.dart';
import 'performance_controller.dart';
import 'performance_form.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    final data = await PerformanceController.fetchLogs();
    setState(() => logs = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Performance Tracker")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PerformanceForm(onSubmit: loadLogs),
            const SizedBox(height: 24),
            logs.isEmpty
                ? const Text("No logs yet.")
                : PerformanceChart(logs: logs),
          ],
        ),
      ),
    );
  }
}
