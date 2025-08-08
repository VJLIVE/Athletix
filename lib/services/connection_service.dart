import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get pending connection requests for an athlete
  Stream<List<Map<String, dynamic>>> getConnectionRequests() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('connection_requests')
        .where('athleteId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  /// Accept a connection request
  Future<bool> acceptConnectionRequest(String requestId, Map<String, dynamic> requestData) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      final batch = _firestore.batch();

      // Update request status
      batch.update(
        _firestore.collection('connection_requests').doc(requestId),
        {'status': 'accepted', 'updatedAt': FieldValue.serverTimestamp()},
      );

      // Add player to organization's connected players
      batch.set(
        _firestore
            .collection('organization_players')
            .doc(requestData['organizationId'])
            .collection('connected_players')
            .doc(uid),
        {
          'connectedAt': FieldValue.serverTimestamp(),
          'status': 'active',
        },
      );

      // Add organization to player's connected organizations
      batch.set(
        _firestore
            .collection('player_organizations')
            .doc(uid)
            .collection('connected_organizations')
            .doc(requestData['organizationId']),
        {
          'connectedAt': FieldValue.serverTimestamp(),
          'status': 'active',
        },
      );

      // Create notification for organization
      batch.add(
        _firestore
            .collection('notifications')
            .doc(requestData['organizationId'])
            .collection('user_notifications'),
        {
          'title': 'Connection Accepted',
          'message': '${requestData['athleteName']} accepted your connection request',
          'type': 'connection_accepted',
          'athleteId': uid,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        },
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('Error accepting connection request: $e');
      return false;
    }
  }

  /// Reject a connection request
  Future<bool> rejectConnectionRequest(String requestId, Map<String, dynamic> requestData) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      final batch = _firestore.batch();

      // Update request status
      batch.update(
        _firestore.collection('connection_requests').doc(requestId),
        {'status': 'rejected', 'updatedAt': FieldValue.serverTimestamp()},
      );

      // Create notification for organization
      batch.add(
        _firestore
            .collection('notifications')
            .doc(requestData['organizationId'])
            .collection('user_notifications'),
        {
          'title': 'Connection Rejected',
          'message': '${requestData['athleteName']} rejected your connection request',
          'type': 'connection_rejected',
          'athleteId': uid,
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        },
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('Error rejecting connection request: $e');
      return false;
    }
  }

  /// Get connected organizations for an athlete
  Stream<List<Map<String, dynamic>>> getConnectedOrganizations() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('player_organizations')
        .doc(uid)
        .collection('connected_organizations')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> organizations = [];
      for (var doc in snapshot.docs) {
        try {
          final orgDoc = await _firestore
              .collection('users')
              .doc(doc.id)
              .get();
          if (orgDoc.exists) {
            final orgData = orgDoc.data() as Map<String, dynamic>;
            orgData['id'] = doc.id;
            orgData['connectedAt'] = doc.data()['connectedAt'];
            organizations.add(orgData);
          }
        } catch (e) {
          print('Error loading organization: $e');
        }
      }
      return organizations;
    });
  }

  /// Disconnect from an organization
  Future<bool> disconnectFromOrganization(String organizationId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      final batch = _firestore.batch();

      // Remove from organization's connected players
      batch.delete(
        _firestore
            .collection('organization_players')
            .doc(organizationId)
            .collection('connected_players')
            .doc(uid),
      );

      // Remove from player's connected organizations
      batch.delete(
        _firestore
            .collection('player_organizations')
            .doc(uid)
            .collection('connected_organizations')
            .doc(organizationId),
      );

      await batch.commit();
      return true;
    } catch (e) {
      print('Error disconnecting from organization: $e');
      return false;
    }
  }
}
