import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InjuryTrackerScreen extends StatefulWidget {
  const InjuryTrackerScreen({super.key});

  @override
  State<InjuryTrackerScreen> createState() => _InjuryTrackerScreenState();
}

class _InjuryTrackerScreenState extends State<InjuryTrackerScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _injuryController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _injuryDate;

  Future<void> _addInjury() async {
    if (_injuryController.text.isEmpty || _injuryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter injury & date")),
      );
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('injuries').add({
      'uid': uid,
      'description': _injuryController.text,
      'notes': _notesController.text,
      'date': _injuryDate!.toIso8601String(),
      'createdAt': Timestamp.now(),
    });

    _injuryController.clear();
    _notesController.clear();
    setState(() {
      _injuryDate = null;
    });

    Navigator.of(context).pop();
  }

  Future<void> _deleteInjury(String docId) async {
    await _firestore.collection('injuries').doc(docId).delete();
  }

  void _showAddInjuryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Add Injury"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _injuryController,
                    decoration: const InputDecoration(
                      labelText: "Injury Description",
                    ),
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
                          _injuryDate = picked;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Injury Date",
                          hintText:
                              _injuryDate == null
                                  ? "Pick Date"
                                  : _injuryDate!.toLocal().toString().split(
                                    ' ',
                                  )[0],
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
                  _injuryController.clear();
                  _notesController.clear();
                  setState(() {
                    _injuryDate = null;
                  });
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(onPressed: _addInjury, child: const Text("Add")),
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
        title: const Text("Injury Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddInjuryDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('injuries')
                .where('uid', isEqualTo: uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No injuries logged yet."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final dateStr = data['date']?.toString().split('T').first ?? '';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(data['description'] ?? ''),
                  subtitle: Text(
                    "Date: $dateStr\nNotes: ${data['notes'] ?? '-'}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteInjury(docs[index].id),
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
