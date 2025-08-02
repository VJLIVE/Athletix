import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerformanceController {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> saveDailyLog({
    required int calories,
    required int duration,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not logged in');

    final today = DateTime.now();
    final dateId =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    await _firestore
        .collection('performance_logs')
        .doc(uid)
        .collection('logs')
        .doc(dateId)
        .set({
      'calories': calories,
      'duration': duration,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchLogs() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('performance_logs')
        .doc(uid)
        .collection('logs')
        .orderBy(FieldPath.documentId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'date': doc.id,
        'calories': data['calories'] ?? data['calories_burned'],
        'duration': data['duration'] ?? data['workout_duration'],
      };
    }).toList();
  }
}
