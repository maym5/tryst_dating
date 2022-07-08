import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  AuthenticationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future onEmailAndPasswordLogin(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return Future.value(userCredential.user);
    } on FirebaseAuthException catch (e) {
      return Future.value(e.code);
    }
  }

  Future onEmailAndPasswordSignUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return Future.value(userCredential.user);
    } on FirebaseAuthException catch (e) {
      return Future.value(e.code);
    }
  }

  static String? get currentUserUID {
    return currentUser?.uid;
  }

  static User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<bool> checkEmailVerified() async {
    if (currentUser != null) {
      await currentUser!.reload();
      return currentUser!.emailVerified;
    } return false;
  }

  static Future<void> sendVerificationEmail() async {
    if (currentUser != null && !currentUser!.emailVerified) {
      try {
        await currentUser?.sendEmailVerification();
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }
}