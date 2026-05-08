/// Authentication Service
///
/// Wraps Firebase Auth with friendly error messages and a clean API.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of auth state changes (signed in / signed out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  // ═══════════════════════════════════════
  //  SIGN UP
  // ═══════════════════════════════════════

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) throw const AuthException('Sign up failed.');

      // Update display name
      await user.updateDisplayName(name.trim());

      // Create user document in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email.trim(),
        'name': name.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyError(e.code));
    } catch (e) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  // ═══════════════════════════════════════
  //  SIGN IN
  // ═══════════════════════════════════════

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyError(e.code));
    } catch (e) {
      throw AuthException('Something went wrong. Please try again.');
    }
  }

  // ═══════════════════════════════════════
  //  SIGN OUT
  // ═══════════════════════════════════════

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ═══════════════════════════════════════
  //  PASSWORD RESET
  // ═══════════════════════════════════════

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_friendlyError(e.code));
    }
  }

  // ═══════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════

  String _friendlyError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
