import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String id;
  final String name;
  final String type;
  final double balance;
  final int color;
  final int icon;
  final Timestamp createdAt;

  WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'color': color,
      'icon': icon,
      'createdAt': createdAt,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      balance: (map['balance'] as num).toDouble(),
      color: map['color'],
      icon: map['icon'],
      createdAt: map['createdAt'],
    );
  }
}