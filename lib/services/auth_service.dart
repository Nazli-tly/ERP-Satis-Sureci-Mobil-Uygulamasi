import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserModel?> signIn(String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = result.user;
    return user != null ? UserModel(uid: user.uid, email: user.email) : null;
  }

  Future<UserModel?> register(String email, String password) async {
    UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = result.user;
    return user != null ? UserModel(uid: user.uid, email: user.email) : null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
