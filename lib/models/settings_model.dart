class SettingsModel {
  final bool notificationPrivacy;

  const SettingsModel({
    required this.notificationPrivacy,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      notificationPrivacy: map["notificationPrivacy"] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "notificationPrivacy": notificationPrivacy,
    };
  }

  SettingsModel copyWith({
    bool? notificationPrivacy,
  }) {
    return SettingsModel(
      notificationPrivacy:
          notificationPrivacy ?? this.notificationPrivacy,
    );
  }
}