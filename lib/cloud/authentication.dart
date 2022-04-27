import 'package:firebase_auth/firebase_auth.dart';

Future onEmailAndPasswordLogin(String email, String password) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  try {
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email, password: password);
    return Future.value(userCredential.user);
  } on FirebaseAuthException catch (e) {
    return Future.value(e.code);
  }
}

Future onEmailAndPasswordSignUp(String email, String password) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  try {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return Future.value(userCredential.user);
  } on FirebaseAuthException catch (e) {
    return Future.value(e.code);
  }
}

Future verifyEmail() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && !user.emailVerified) {
    return user.sendEmailVerification();
  } else {
    return Future.error('invalid user');
  }
}