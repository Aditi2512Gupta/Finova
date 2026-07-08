import 'package:firebase_auth/firebase_auth.dart';
import 'category_service.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final CategoryService _categoryService = CategoryService();

  // =========================
  // Sign Up
  // =========================
  // Future<UserCredential> signUp({
  //   required String email,
  //   required String password,
  //   required String name,
  // }) async {
  //   try {
  //     final UserCredential userCredential = await _auth
  //         .createUserWithEmailAndPassword(email: email, password: password);

  //     final user = UserModel(
  //       uid: userCredential.user!.uid,
  //       name: name,
  //       email: email,
  //       totalBalance: 0,
  //       financialHealthScore: 100,
  //       createdAt: DateTime.now(),
  //     );

  //     await _firestoreService.saveUser(user);

  //     return userCredential;
  //   } on FirebaseAuthException catch (e) {
  //     throw Exception(e.message);
  //   }
  // }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print("Creating user...");

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      print("User Created");

      final user = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        totalBalance: 0,
        financialHealthScore: 100,
        createdAt: DateTime.now(),
      );

      print("Saving to Firestore...");

      await _firestoreService.saveUser(user);
      await _categoryService.seedDefaultCategories();
      
      print("Saved Successfully");

      return userCredential;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  // =========================
  // Login
  // =========================
  Future<User?> login({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // =========================
  // Forgot Password
  // =========================
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // =========================
  // Logout
  // =========================
  Future<void> logout() async {
    await _auth.signOut();
  }
}
