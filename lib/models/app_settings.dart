class Settings {
  String theme;
  String language;
  
  bool notifications;

  Settings({
    required this.theme,
    required this.language,
    required this.notifications,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      theme: json['theme'],
      language: json['language'],
      notifications: json['notifications'],
    );
  }
}