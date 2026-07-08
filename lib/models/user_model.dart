class UserModel {
  final String uid;
  final String name;
  final String email;
  final double totalBalance;
  final int financialHealthScore;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.totalBalance,
    required this.financialHealthScore,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'totalBalance': totalBalance,
      'financialHealthScore': financialHealthScore,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      totalBalance: (map['totalBalance'] as num).toDouble(),
      financialHealthScore: map['financialHealthScore'],
      createdAt: map['createdAt'].toDate(),
    );
  }
}