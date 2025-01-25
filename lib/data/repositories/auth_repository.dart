import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Log in method
  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception("Failed to login: $e");
    }
  }

  // Logout method
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Check if user is already logged in
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
