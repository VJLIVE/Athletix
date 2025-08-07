import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _addActivity() async {
    final TextEditingController workController = TextEditingController();
    DateTime? startTime;
    DateTime? endTime;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Activity"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: workController,
                decoration: const InputDecoration(labelText: "Work/Activity"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDay,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (time != null) {
                      setState(() {
                        startTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: Text(startTime == null
                    ? "Select Start Time"
                    : "Start: $startTime"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDay,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 10, minute: 0),
                    );
                    if (time != null) {
                      setState(() {
                        endTime = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: Text(endTime == null
                    ? "Select End Time"
                    : "End: $endTime"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (workController.text.isNotEmpty &&
                  startTime != null &&
                  endTime != null) {
                await FirebaseFirestore.instance.collection('timetables').add({
                  'uid': uid,
                  'work': workController.text,
                  'startTime': Timestamp.fromDate(startTime!.toUtc()),
                  'endTime': Timestamp.fromDate(endTime!.toUtc()),
                  'createdAt': Timestamp.now(),
                  'notified': false,
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                selectedDay = selected;
              });
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('timetables')
                  .where('uid', isEqualTo: uid)
                  .where(
                'startTime',
                isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime.now().toUtc(),
                ),
              )
                  .where(
                'startTime',
                isLessThan: Timestamp.fromDate(
                  DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day + 1),
                ),
              )
                  .orderBy('startTime')
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No upcoming activities for this day."));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['work']),
                      subtitle: Text(
                        "${(data['startTime'] as Timestamp).toDate()} → ${(data['endTime'] as Timestamp).toDate()}",
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        child: const Icon(Icons.add),
      ),
    );
  }
}
