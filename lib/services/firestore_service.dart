import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    return UserModel.fromMap(doc.data()!);
  }

  Future<void> saveUserPreferences({
    required String uid,
    required bool isDarkMode,
    required int accentIndex,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'preferences': {'isDarkMode': isDarkMode, 'accentIndex': accentIndex},
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getUserPreferences(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      return {'isDarkMode': false, 'accentIndex': 0};
    }

    final data = doc.data();

    if (data == null || data['preferences'] == null) {
      return {'isDarkMode': false, 'accentIndex': 0};
    }

    return Map<String, dynamic>.from(data['preferences']);
  }
}
