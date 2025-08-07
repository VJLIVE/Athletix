import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'cloudinary_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email,
      String password,
      ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    return await _auth.fetchSignInMethodsForEmail(email);
  }

  Future<void> storeUserDataInFirestore(UserModel userModel) async {
    await _firestore
        .collection('users')
        .doc(userModel.uid)
        .set(userModel.toFirestore());
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  Future<UserModel?> getUserDataByEmail(String email) async {
    try {
      final querySnapshot =
      await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data by email: $e');
      return null;
    }
  }

  Future<void> updateEmailVerificationStatus(
      String uid,
      bool isVerified,
      ) async {
    await _firestore.collection('users').doc(uid).update({
      'emailVerified': isVerified,
    });
  }

  /// Updates the current user's profile image URL in Firestore
  /// Note: Old images are not deleted from Cloudinary due to client-side limitations
  Future<void> updateProfileImage(String newImageUrl) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('No user logged in');
    }

    try {
      // Update Firestore with new image URL
      await _firestore.collection('users').doc(uid).update({
        'profileImage': newImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Profile image updated successfully');
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      rethrow;
    }
  }

  /// Removes the current user's profile image URL from Firestore
  /// Note: The actual image is not deleted from Cloudinary due to client-side limitations
  Future<void> removeProfileImage() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('No user logged in');
    }

    try {
      // Remove profile image field from Firestore
      await _firestore.collection('users').doc(uid).update({
        'profileImage': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Profile image URL removed successfully');
    } catch (e) {
      debugPrint('Error removing profile image: $e');
      rethrow;
    }
  }

  /// Gets the current user's profile image URL
  Future<String?> getProfileImageUrl() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['profileImage'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting profile image URL: $e');
      return null;
    }
  }

  Future<void> saveFcmToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        debugPrint('Failed to get FCM token');
        return;
      }

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        debugPrint('No user logged in');
        return;
      }

      await _firestore.collection('users').doc(uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));

      debugPrint('FCM Token saved to Firestore');
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }
}
