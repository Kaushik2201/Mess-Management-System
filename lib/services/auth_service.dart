import 'package:firebase_auth/firebase_auth.dart';
import 'package:mess_management_system/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Userdef? _userFromFirebaseUser(User? user) {
    return user != null ? Userdef(uid: user.uid) : null;
  }

  Stream<Userdef?> get user {
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user));
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email already exists. Please log in.';
      } else {
        return 'Error: ${e.message}';
      }
    }
  }

  Future<String?> checkEmail(String email) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: 'temporary_password',
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'Invalid email address';
      } else if (e.code == 'email-already-in-use') {
        return 'Email already exists. Please log in.';
      } else {
        return 'Error: ${e.message}';
      }
    }
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return 'Invalid credentials. Please try again.';
      } else {
        return 'Error: ${e.message}';
      }
    }
  }

  Future<String?> adminLogin(String email, String password) async {
    try {
      // ignore: unused_local_variable
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return 'Invalid credentials. Please try again.';
      } else {
        return 'Error: ${e.message}';
      }
    }
  }

  String getCurrentUserUid() {
    final user = _auth.currentUser;
    return user?.uid ?? '';
  }

  bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
