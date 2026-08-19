class User {
  final int id;
  final String username;
  final String? firstName;
  final String? email;
  final String? phone;
  final String? avatarFileId;
  final String? avatarLocalPath;
  final String status;
  final String presence;
  final DateTime? lastSeen;
  final bool isActive;
  final String? token;

  User({
    required this.id,
    required this.username,
    this.firstName,
    this.email,
    this.phone,
    this.avatarFileId,
    this.avatarLocalPath,
    required this.status,
    required this.presence,
    this.lastSeen,
    required this.isActive,
    this.token
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarFileId: json['avatar_file_id'] as String?,
      avatarLocalPath: json['avatar_local_path'] as String?,
      status: json['status'] as String,
      presence: json['presence'] as String,
      lastSeen: json['last_seen'] != null ? DateTime.parse(json['last_seen'] as String) : null,
      isActive: json['is_active'] as bool,
      token: json['token'] as String?,
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? firstName,
    String? email,
    String? phone,
    String? avatarFileId,
    String? avatarLocalPath,
    String? status,
    String? presence,
    DateTime? lastSeen,
    bool? isActive,
    String? token
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarFileId: avatarFileId ?? this.avatarFileId,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      status: status ?? this.status,
      presence: presence ?? this.presence,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
      token: token ?? this.token
    );
  }
}