import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerformanceLogScreen extends StatefulWidget {
  const PerformanceLogScreen({super.key});

  @override
  State<PerformanceLogScreen> createState() => _PerformanceLogScreenState();
}

class _PerformanceLogScreenState extends State<PerformanceLogScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _activityController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _logDate;

  Future<void> _addLog() async {
    if (_activityController.text.trim().isEmpty || _logDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter activity & date")),
      );
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('performance_logs').add({
      'uid': uid,
      'activity': _activityController.text.trim(),
      'notes': _notesController.text.trim(),
      'date': Timestamp.fromDate(_logDate!), // ✅ store as Timestamp
      'createdAt': FieldValue.serverTimestamp(), // ✅ server time
    });

    _activityController.clear();
    _notesController.clear();
    setState(() {
      _logDate = null;
    });

    Navigator.of(context).pop();
  }

  Future<void> _deleteLog(String docId) async {
    await _firestore.collection('performance_logs').doc(docId).delete();
  }

  void _showAddLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Add Performance Log"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _activityController,
                    decoration: const InputDecoration(labelText: "Activity"),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _logDate = picked;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Date",
                          hintText:
                              _logDate == null
                                  ? "Pick Date"
                                  : "${_logDate!.toLocal()}".split(' ')[0],
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: "Notes (optional)",
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _activityController.clear();
                  _notesController.clear();
                  setState(() {
                    _logDate = null;
                  });
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(onPressed: _addLog, child: const Text("Add")),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Performance Logs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddLogDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('performance_logs')
                .where('uid', isEqualTo: uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No performance logs yet."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
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
                dateStr =
                    dateRaw
                        .split('T')
                        .first; // fallback if it was stored as ISO string
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
          );
        },
      ),
    );
  }
}
