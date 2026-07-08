import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String type;
  final int color;
  final int icon;
  final Timestamp createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "type": type,
      "color": color,
      "icon": icon,
      "createdAt": createdAt,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map["id"],
      name: map["name"],
      type: map["type"],
      color: map["color"],
      icon: map["icon"],
      createdAt: map["createdAt"],
    );
  }
}