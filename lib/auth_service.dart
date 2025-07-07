import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User roles
  static const String customerRole = 'customer';
  static const String storeRole = 'store';
  static const String adminRole = 'admin';

  // Get current user role
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['role'];
  }

  // Login with email/password
  Future<UserCredential> loginWithEmailPassword(
      String email, String password, String role) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify user has the correct role
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (userDoc.data()?['role'] != role) {
        await _auth.signOut();
        throw Exception('User does not have $role role');
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Register new user with role
  Future<void> registerWithEmailPassword(
      String email, String password, String name, String role) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data with role
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Additional setup based on role
      if (role == storeRole) {
        await _setupStoreProfile(userCredential.user!.uid);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _setupStoreProfile(String userId) async {
    await _firestore.collection('stores').doc(userId).set({
      'storeId': userId,
      'notifications': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
