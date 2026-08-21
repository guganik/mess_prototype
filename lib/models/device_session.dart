class DeviceSession {
  final String sessionId;
  final String deviceId;
  final String deviceName;
  final String platform;
  final DateTime createdAt;
  final DateTime lastSeen;
  final bool isActive;

  const DeviceSession({
    required this.sessionId,
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.createdAt,
    required this.lastSeen,
    required this.isActive,
  });

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      sessionId: json['session_id'] as String,
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      platform: json['platform'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSeen: DateTime.parse(json['last_seen'] as String),
      isActive: json['is_active'] as bool,
    );
  }
}