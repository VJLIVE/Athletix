import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../features/performance_tracking/performance_chart.dart';
import 'package:intl/intl.dart';

class PerformanceLogScreen extends StatefulWidget {
  const PerformanceLogScreen({super.key});

  @override
  State<PerformanceLogScreen> createState() => _PerformanceLogScreenState();
}

class _PerformanceLogScreenState extends State<PerformanceLogScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _logDate;
  bool _isLoading = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _activityController.addListener(() => setState(() {}));
    _notesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _activityController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _activityController.text.trim().isNotEmpty && _logDate != null;

  void _clearForm() {
    _activityController.clear();
    _notesController.clear();
    _dateController.clear();
    setState(() {
      _logDate = null;
    });
  }

  Future<void> _addLog() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter activity & date")),
      );
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    await _firestore.collection('performance_logs').add({
      'uid': uid,
      'activity': _activityController.text.trim(),
      'notes': _notesController.text.trim(),
      'date': Timestamp.fromDate(_logDate!),
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _isLoading = false);
    _clearForm();

    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }

  Future<void> _deleteLog(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Log"),
        content:
        const Text("Are you sure you want to delete this performance log entry?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('performance_logs').doc(docId).delete();
    }
  }

  void _showAddLogSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        DateTime? modalLogDate = _logDate;
        _dateController.text =
        modalLogDate != null ? DateFormat('yyyy-MM-dd').format(modalLogDate) : '';

        return Padding(
          padding: EdgeInsets.only(
            bottom: bottomInset + 20,
            left: 24,
            right: 24,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> pickDate() async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: modalLogDate ?? DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setModalState(() {
                    modalLogDate = picked;
                    _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  });
                  setState(() {
                    _logDate = picked;
                  });
                }
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add Performance Log",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _activityController,
                      decoration: const InputDecoration(
                        labelText: "Activity *",
                        hintText: "What did you do?",
                        prefixIcon: Icon(Icons.fitness_center),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: "Date *",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: pickDate,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Notes (optional)",
                        hintText: "Any notes you want to add",
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: _isFormValid ? _addLog : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: _isFormValid ? Colors.black : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLogCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final activity = data['activity'] ?? '';
    final notes = data['notes'] ?? '';
    final rawDate = data['date'];
    String dateStr = '';
    if (rawDate is Timestamp) {
      dateStr = DateFormat('MMM d, yyyy').format(rawDate.toDate());
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(
          activity,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("Date: $dateStr\nNotes: $notes"),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _deleteLog(doc.id),
          tooltip: "Delete entry",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        centerTitle: true,
        title: const Text(
          "Performance Logs",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('performance_logs')
            .where('uid', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No performance logs yet."));
          }
          final docs = snapshot.data!.docs;

          // 🔁 Build chart data list
          final List<Map<String, dynamic>> logsForChart = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'activity': data['activity'],
              'notes': data['notes'],
              'date': (data['date'] as Timestamp).toDate(),
              'calories': 100, // Optional: make dynamic later
              'duration': 30,  // Optional: make dynamic later
            };
          }).toList();

          return Column(
            children: [
              SizedBox(
                height: 300,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PerformanceChart(logs: logsForChart),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Recent Logs",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final activity = data['activity'] ?? '';
                    final notes = data['notes'] ?? '-';

                    String dateStr = '';
                    final dateRaw = data['date'];
                    if (dateRaw is Timestamp) {
                      dateStr = dateRaw.toDate().toLocal().toString().split(' ')[0];
                    } else if (dateRaw is String) {
                      dateStr = dateRaw.split('T').first;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(activity),
                        subtitle: Text("Date: $dateStr\nNotes: $notes"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteLog(docs[index].id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLogSheet(context),
        icon: const Icon(Icons.add, color: Color(0xFF1565C0)),
        label: const Text(
          "Add Log",
          style: TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
    );
  },
}
