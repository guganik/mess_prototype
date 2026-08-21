class PublicUser {
  final int id;
  final String username;
  final String? firstName;
  final String? avatarFileId;
  final String status;
  final String presence;
  final DateTime? lastSeen;

  const PublicUser({
    required this.id,
    required this.username,
    this.firstName,
    this.avatarFileId,
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
      status: json['status'] as String,
      presence: json['presence'] as String,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(
              json['last_seen'] as String,
            )
          : null,
    );
  }
}