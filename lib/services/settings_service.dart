import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get settingsDoc =>
      _firestore
          .collection("users")
          .doc(uid)
          .collection("settings")
          .doc("preferences");

  Future<void> setNotificationPrivacy(bool enabled) async {
    await settingsDoc.set({
      "notificationPrivacy": enabled,
    }, SetOptions(merge: true));
  }

  Future<bool> getNotificationPrivacy() async {
    final doc = await settingsDoc.get();

    if (!doc.exists) return true;

    return doc.data()?["notificationPrivacy"] ?? true;
  }
}