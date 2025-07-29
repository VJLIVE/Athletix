import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/financial_entry_model.dart';

/// Service class for handling Firestore operations related to financial entries.
class FirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Adds a [FinancialEntry] to the current user's financial logs in Firestore.
  Future<void> addFinancialEntry(FinancialEntry entry) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('financial_logs')
        .doc(uid)
        .collection('entries')
        .add(entry.toMap());
  }

  /// Returns a stream of [FinancialEntry]s for the current user, ordered by date descending.
  Stream<List<FinancialEntry>> getFinancialEntries() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('financial_logs')
        .doc(uid)
        .collection('entries')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialEntry.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Updates an existing [FinancialEntry] for the current user in Firestore.
  Future<void> updateFinancialEntry(FinancialEntry entry) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('financial_logs')
        .doc(uid)
        .collection('entries')
        .doc(entry.id)
        .update(entry.toMap());
  }

  /// Deletes a [FinancialEntry] by its [entryId] for the current user in Firestore.
  Future<void> deleteFinancialEntry(String entryId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('financial_logs')
        .doc(uid)
        .collection('entries')
        .doc(entryId)
        .delete();
  }
}