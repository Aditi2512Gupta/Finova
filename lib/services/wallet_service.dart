import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/wallet_model.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get walletCollection =>
      _firestore.collection('users').doc(uid).collection('wallets');

  // Create Wallet
  Future<void> addWallet(WalletModel wallet) async {
    await walletCollection.doc(wallet.id).set(wallet.toMap());
  }

  // Read Wallets
  Stream<List<WalletModel>> getWallets() {
    return walletCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => WalletModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Update Wallet
  Future<void> updateWallet(WalletModel wallet) async {
    await walletCollection.doc(wallet.id).update(wallet.toMap());
  }

  // Delete Wallet
  Future<void> deleteWallet(WalletModel wallet) async {
    await walletCollection.doc(wallet.id).delete();
  }

  Future<List<WalletModel>> getWalletList() async {
    final snapshot = await walletCollection.get();

    return snapshot.docs.map((doc) => WalletModel.fromMap(doc.data())).toList();
  }

  Future<WalletModel> getWalletById(String walletId) async {
    final doc = await walletCollection.doc(walletId).get();

    return WalletModel.fromMap(doc.data()!);
  }

  Future<Map<String, WalletModel>> getWalletMap() async {
    final snapshot = await walletCollection.get();

    final Map<String, WalletModel> map = {};

    for (final doc in snapshot.docs) {
      final wallet = WalletModel.fromMap(doc.data());
      map[wallet.id] = wallet;
    }

    return map;
  }

  Future<void> updateWalletBalance({
    required String walletId,
    required double newBalance,
  }) async {
    await walletCollection.doc(walletId).update({"balance": newBalance});
  }

  Future<bool> hasTransactions(String walletId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where("walletId", isEqualTo: walletId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<bool> hasLowBalanceAlertShown(String walletId) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('wallet_alerts')
        .doc(walletId)
        .get();

    if (!doc.exists) return false;

    return (doc.data()?['lowBalanceShown'] ?? false) as bool;
  }

  Future<void> setLowBalanceAlertShown({
    required String walletId,
    required bool shown,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('wallet_alerts')
        .doc(walletId)
        .set({'lowBalanceShown': shown}, SetOptions(merge: true));
  }
}
