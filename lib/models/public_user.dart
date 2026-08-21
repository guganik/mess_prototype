class PublicUser {
  final int id;
  final String username;
  final String? firstName;
  final String? avatarFileId;
  final String? avatarLocalPath;
  final String status;
  final String presence;
  final DateTime? lastSeen;

  const PublicUser({
    required this.id,
    required this.username,
    this.firstName,
    this.avatarFileId,
    this.avatarLocalPath,
    required this.status,
    required this.presence,
    this.lastSeen,
  });

  factory PublicUser.fromJson(
    Map<String, dynamic> json,
  ) {
    return PublicUser(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['first_name'] as String?,
      avatarFileId:
          json['avatar_file_id'] as String?,
      avatarLocalPath:
          json['avatar_local_path'] as String?,
      status:
          json['status'] as String? ?? 'online',
      presence:
          json['presence'] as String? ?? 'offline',
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(
              json['last_seen'] as String,
            )
          : null,
    );
  }

  PublicUser copyWith({
    int? id,
    String? username,
    String? firstName,
    String? avatarFileId,
    String? avatarLocalPath,
    String? status,
    String? presence,
    DateTime? lastSeen,
  }) {
    return PublicUser(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      avatarFileId:
          avatarFileId ?? this.avatarFileId,
      avatarLocalPath:
          avatarLocalPath ?? this.avatarLocalPath,
      status: status ?? this.status,
      presence: presence ?? this.presence,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}