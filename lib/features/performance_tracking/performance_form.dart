import 'package:flutter/material.dart';
import 'performance_controller.dart';

class PerformanceForm extends StatefulWidget {
  final VoidCallback onSubmit;

  const PerformanceForm({super.key, required this.onSubmit});

  @override
  State<PerformanceForm> createState() => _PerformanceFormState();
}

class _PerformanceFormState extends State<PerformanceForm> {
  final _caloriesController = TextEditingController();
  final _durationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final calories = int.tryParse(_caloriesController.text);
    final duration = int.tryParse(_durationController.text);

    if (calories == null || duration == null) return;

    setState(() => isLoading = true);

    try {
      await PerformanceController.saveDailyLog(
        calories: calories,
        duration: duration,
      );
      widget.onSubmit();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Performance data saved!")),
      );
      _caloriesController.clear();
      _durationController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _caloriesController,
            decoration: const InputDecoration(
              labelText: "Calories Burned",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (val) =>
                val == null || val.isEmpty ? 'Enter calories' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: "Workout Duration (minutes)",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (val) =>
                val == null || val.isEmpty ? 'Enter duration' : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isLoading ? null : _save,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text("Save"),
          ),
        ],
      ),
    );
  }
}
