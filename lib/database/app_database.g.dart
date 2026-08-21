// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('offline'),
  );
  static const VerificationMeta _presenceMeta = const VerificationMeta(
    'presence',
  );
  @override
  late final GeneratedColumn<String> presence = GeneratedColumn<String>(
    'presence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('offline'),
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
    'last_seen',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarFileIdMeta = const VerificationMeta(
    'avatarFileId',
  );
  @override
  late final GeneratedColumn<String> avatarFileId = GeneratedColumn<String>(
    'avatar_file_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarLocalPathMeta = const VerificationMeta(
    'avatarLocalPath',
  );
  @override
  late final GeneratedColumn<String> avatarLocalPath = GeneratedColumn<String>(
    'avatar_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    firstName,
    email,
    phone,
    status,
    presence,
    lastSeen,
    isActive,
    token,
    avatarFileId,
    avatarLocalPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('presence')) {
      context.handle(
        _presenceMeta,
        presence.isAcceptableOrUnknown(data['presence']!, _presenceMeta),
      );
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    }
    if (data.containsKey('avatar_file_id')) {
      context.handle(
        _avatarFileIdMeta,
        avatarFileId.isAcceptableOrUnknown(
          data['avatar_file_id']!,
          _avatarFileIdMeta,
        ),
      );
    }
    if (data.containsKey('avatar_local_path')) {
      context.handle(
        _avatarLocalPathMeta,
        avatarLocalPath.isAcceptableOrUnknown(
          data['avatar_local_path']!,
          _avatarLocalPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      presence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presence'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      ),
      avatarFileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_file_id'],
      ),
      avatarLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_local_path'],
      ),
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final int id;
  final String username;
  final String? firstName;
  final String? email;
  final String? phone;
  final String status;
  final String presence;
  final DateTime? lastSeen;
  final bool isActive;
  final String? token;
  final String? avatarFileId;
  final String? avatarLocalPath;
  const LocalUser({
    required this.id,
    required this.username,
    this.firstName,
    this.email,
    this.phone,
    required this.status,
    required this.presence,
    this.lastSeen,
    required this.isActive,
    this.token,
    this.avatarFileId,
    this.avatarLocalPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['status'] = Variable<String>(status);
    map['presence'] = Variable<String>(presence);
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<DateTime>(lastSeen);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<String>(token);
    }
    if (!nullToAbsent || avatarFileId != null) {
      map['avatar_file_id'] = Variable<String>(avatarFileId);
    }
    if (!nullToAbsent || avatarLocalPath != null) {
      map['avatar_local_path'] = Variable<String>(avatarLocalPath);
    }
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      username: Value(username),
      firstName: firstName == null && nullToAbsent
          ? const Value.absent()
          : Value(firstName),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      status: Value(status),
      presence: Value(presence),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
      isActive: Value(isActive),
      token: token == null && nullToAbsent
          ? const Value.absent()
          : Value(token),
      avatarFileId: avatarFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarFileId),
      avatarLocalPath: avatarLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarLocalPath),
    );
  }

  factory LocalUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      firstName: serializer.fromJson<String?>(json['firstName']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      status: serializer.fromJson<String>(json['status']),
      presence: serializer.fromJson<String>(json['presence']),
      lastSeen: serializer.fromJson<DateTime?>(json['lastSeen']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      token: serializer.fromJson<String?>(json['token']),
      avatarFileId: serializer.fromJson<String?>(json['avatarFileId']),
      avatarLocalPath: serializer.fromJson<String?>(json['avatarLocalPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'firstName': serializer.toJson<String?>(firstName),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'status': serializer.toJson<String>(status),
      'presence': serializer.toJson<String>(presence),
      'lastSeen': serializer.toJson<DateTime?>(lastSeen),
      'isActive': serializer.toJson<bool>(isActive),
      'token': serializer.toJson<String?>(token),
      'avatarFileId': serializer.toJson<String?>(avatarFileId),
      'avatarLocalPath': serializer.toJson<String?>(avatarLocalPath),
    };
  }

  LocalUser copyWith({
    int? id,
    String? username,
    Value<String?> firstName = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? status,
    String? presence,
    Value<DateTime?> lastSeen = const Value.absent(),
    bool? isActive,
    Value<String?> token = const Value.absent(),
    Value<String?> avatarFileId = const Value.absent(),
    Value<String?> avatarLocalPath = const Value.absent(),
  }) => LocalUser(
    id: id ?? this.id,
    username: username ?? this.username,
    firstName: firstName.present ? firstName.value : this.firstName,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    status: status ?? this.status,
    presence: presence ?? this.presence,
    lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
    isActive: isActive ?? this.isActive,
    token: token.present ? token.value : this.token,
    avatarFileId: avatarFileId.present ? avatarFileId.value : this.avatarFileId,
    avatarLocalPath: avatarLocalPath.present
        ? avatarLocalPath.value
        : this.avatarLocalPath,
  );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      status: data.status.present ? data.status.value : this.status,
      presence: data.presence.present ? data.presence.value : this.presence,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      token: data.token.present ? data.token.value : this.token,
      avatarFileId: data.avatarFileId.present
          ? data.avatarFileId.value
          : this.avatarFileId,
      avatarLocalPath: data.avatarLocalPath.present
          ? data.avatarLocalPath.value
          : this.avatarLocalPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('firstName: $firstName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('status: $status, ')
          ..write('presence: $presence, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('isActive: $isActive, ')
          ..write('token: $token, ')
          ..write('avatarFileId: $avatarFileId, ')
          ..write('avatarLocalPath: $avatarLocalPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    firstName,
    email,
    phone,
    status,
    presence,
    lastSeen,
    isActive,
    token,
    avatarFileId,
    avatarLocalPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.username == this.username &&
          other.firstName == this.firstName &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.status == this.status &&
          other.presence == this.presence &&
          other.lastSeen == this.lastSeen &&
          other.isActive == this.isActive &&
          other.token == this.token &&
          other.avatarFileId == this.avatarFileId &&
          other.avatarLocalPath == this.avatarLocalPath);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<int> id;
  final Value<String> username;
  final Value<String?> firstName;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String> status;
  final Value<String> presence;
  final Value<DateTime?> lastSeen;
  final Value<bool> isActive;
  final Value<String?> token;
  final Value<String?> avatarFileId;
  final Value<String?> avatarLocalPath;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.firstName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.status = const Value.absent(),
    this.presence = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.isActive = const Value.absent(),
    this.token = const Value.absent(),
    this.avatarFileId = const Value.absent(),
    this.avatarLocalPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required int id,
    required String username,
    this.firstName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.status = const Value.absent(),
    this.presence = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.isActive = const Value.absent(),
    this.token = const Value.absent(),
    this.avatarFileId = const Value.absent(),
    this.avatarLocalPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       username = Value(username);
  static Insertable<LocalUser> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? firstName,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? status,
    Expression<String>? presence,
    Expression<DateTime>? lastSeen,
    Expression<bool>? isActive,
    Expression<String>? token,
    Expression<String>? avatarFileId,
    Expression<String>? avatarLocalPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (firstName != null) 'first_name': firstName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (status != null) 'status': status,
      if (presence != null) 'presence': presence,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (isActive != null) 'is_active': isActive,
      if (token != null) 'token': token,
      if (avatarFileId != null) 'avatar_file_id': avatarFileId,
      if (avatarLocalPath != null) 'avatar_local_path': avatarLocalPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String?>? firstName,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String>? status,
    Value<String>? presence,
    Value<DateTime?>? lastSeen,
    Value<bool>? isActive,
    Value<String?>? token,
    Value<String?>? avatarFileId,
    Value<String?>? avatarLocalPath,
    Value<int>? rowid,
  }) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      presence: presence ?? this.presence,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
      token: token ?? this.token,
      avatarFileId: avatarFileId ?? this.avatarFileId,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (presence.present) {
      map['presence'] = Variable<String>(presence.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (avatarFileId.present) {
      map['avatar_file_id'] = Variable<String>(avatarFileId.value);
    }
    if (avatarLocalPath.present) {
      map['avatar_local_path'] = Variable<String>(avatarLocalPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('firstName: $firstName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('status: $status, ')
          ..write('presence: $presence, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('isActive: $isActive, ')
          ..write('token: $token, ')
          ..write('avatarFileId: $avatarFileId, ')
          ..write('avatarLocalPath: $avatarLocalPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Light'),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ru'),
  );
  static const VerificationMeta _notificationsMeta = const VerificationMeta(
    'notifications',
  );
  @override
  late final GeneratedColumn<bool> notifications = GeneratedColumn<bool>(
    'notifications',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, theme, language, notifications];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('notifications')) {
      context.handle(
        _notificationsMeta,
        notifications.isAcceptableOrUnknown(
          data['notifications']!,
          _notificationsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      notifications: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final String theme;
  final String language;
  final bool notifications;
  const AppSetting({
    required this.id,
    required this.theme,
    required this.language,
    required this.notifications,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme'] = Variable<String>(theme);
    map['language'] = Variable<String>(language);
    map['notifications'] = Variable<bool>(notifications);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      theme: Value(theme),
      language: Value(language),
      notifications: Value(notifications),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      theme: serializer.fromJson<String>(json['theme']),
      language: serializer.fromJson<String>(json['language']),
      notifications: serializer.fromJson<bool>(json['notifications']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'theme': serializer.toJson<String>(theme),
      'language': serializer.toJson<String>(language),
      'notifications': serializer.toJson<bool>(notifications),
    };
  }

  AppSetting copyWith({
    int? id,
    String? theme,
    String? language,
    bool? notifications,
  }) => AppSetting(
    id: id ?? this.id,
    theme: theme ?? this.theme,
    language: language ?? this.language,
    notifications: notifications ?? this.notifications,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      theme: data.theme.present ? data.theme.value : this.theme,
      language: data.language.present ? data.language.value : this.language,
      notifications: data.notifications.present
          ? data.notifications.value
          : this.notifications,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('theme: $theme, ')
          ..write('language: $language, ')
          ..write('notifications: $notifications')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, theme, language, notifications);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.theme == this.theme &&
          other.language == this.language &&
          other.notifications == this.notifications);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> theme;
  final Value<String> language;
  final Value<bool> notifications;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.theme = const Value.absent(),
    this.language = const Value.absent(),
    this.notifications = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.theme = const Value.absent(),
    this.language = const Value.absent(),
    this.notifications = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? theme,
    Expression<String>? language,
    Expression<bool>? notifications,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (theme != null) 'theme': theme,
      if (language != null) 'language': language,
      if (notifications != null) 'notifications': notifications,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? theme,
    Value<String>? language,
    Value<bool>? notifications,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (notifications.present) {
      map['notifications'] = Variable<bool>(notifications.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('theme: $theme, ')
          ..write('language: $language, ')
          ..write('notifications: $notifications')
          ..write(')'))
        .toString();
  }
}

class $LocalChatsTable extends LocalChats
    with TableInfo<$LocalChatsTable, LocalChat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _otherUserIdMeta = const VerificationMeta(
    'otherUserId',
  );
  @override
  late final GeneratedColumn<int> otherUserId = GeneratedColumn<int>(
    'other_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMessageIdMeta = const VerificationMeta(
    'lastMessageId',
  );
  @override
  late final GeneratedColumn<int> lastMessageId = GeneratedColumn<int>(
    'last_message_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageTextMeta = const VerificationMeta(
    'lastMessageText',
  );
  @override
  late final GeneratedColumn<String> lastMessageText = GeneratedColumn<String>(
    'last_message_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageSenderIdMeta =
      const VerificationMeta('lastMessageSenderId');
  @override
  late final GeneratedColumn<int> lastMessageSenderId = GeneratedColumn<int>(
    'last_message_sender_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMessageCreatedAtMeta =
      const VerificationMeta('lastMessageCreatedAt');
  @override
  late final GeneratedColumn<DateTime> lastMessageCreatedAt =
      GeneratedColumn<DateTime>(
        'last_message_created_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    otherUserId,
    title,
    createdAt,
    updatedAt,
    lastMessageId,
    lastMessageText,
    lastMessageSenderId,
    lastMessageCreatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_chats';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('other_user_id')) {
      context.handle(
        _otherUserIdMeta,
        otherUserId.isAcceptableOrUnknown(
          data['other_user_id']!,
          _otherUserIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_message_id')) {
      context.handle(
        _lastMessageIdMeta,
        lastMessageId.isAcceptableOrUnknown(
          data['last_message_id']!,
          _lastMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_text')) {
      context.handle(
        _lastMessageTextMeta,
        lastMessageText.isAcceptableOrUnknown(
          data['last_message_text']!,
          _lastMessageTextMeta,
        ),
      );
    }
    if (data.containsKey('last_message_sender_id')) {
      context.handle(
        _lastMessageSenderIdMeta,
        lastMessageSenderId.isAcceptableOrUnknown(
          data['last_message_sender_id']!,
          _lastMessageSenderIdMeta,
        ),
      );
    }
    if (data.containsKey('last_message_created_at')) {
      context.handle(
        _lastMessageCreatedAtMeta,
        lastMessageCreatedAt.isAcceptableOrUnknown(
          data['last_message_created_at']!,
          _lastMessageCreatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalChat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      otherUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}other_user_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_id'],
      ),
      lastMessageText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_text'],
      ),
      lastMessageSenderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_message_sender_id'],
      ),
      lastMessageCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_created_at'],
      ),
    );
  }

  @override
  $LocalChatsTable createAlias(String alias) {
    return $LocalChatsTable(attachedDatabase, alias);
  }
}

class LocalChat extends DataClass implements Insertable<LocalChat> {
  final int id;
  final String type;
  final int? otherUserId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? lastMessageId;
  final String? lastMessageText;
  final int? lastMessageSenderId;
  final DateTime? lastMessageCreatedAt;
  const LocalChat({
    required this.id,
    required this.type,
    this.otherUserId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageId,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageCreatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || otherUserId != null) {
      map['other_user_id'] = Variable<int>(otherUserId);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastMessageId != null) {
      map['last_message_id'] = Variable<int>(lastMessageId);
    }
    if (!nullToAbsent || lastMessageText != null) {
      map['last_message_text'] = Variable<String>(lastMessageText);
    }
    if (!nullToAbsent || lastMessageSenderId != null) {
      map['last_message_sender_id'] = Variable<int>(lastMessageSenderId);
    }
    if (!nullToAbsent || lastMessageCreatedAt != null) {
      map['last_message_created_at'] = Variable<DateTime>(lastMessageCreatedAt);
    }
    return map;
  }

  LocalChatsCompanion toCompanion(bool nullToAbsent) {
    return LocalChatsCompanion(
      id: Value(id),
      type: Value(type),
      otherUserId: otherUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(otherUserId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastMessageId: lastMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageId),
      lastMessageText: lastMessageText == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageText),
      lastMessageSenderId: lastMessageSenderId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageSenderId),
      lastMessageCreatedAt: lastMessageCreatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageCreatedAt),
    );
  }

  factory LocalChat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChat(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      otherUserId: serializer.fromJson<int?>(json['otherUserId']),
      title: serializer.fromJson<String?>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastMessageId: serializer.fromJson<int?>(json['lastMessageId']),
      lastMessageText: serializer.fromJson<String?>(json['lastMessageText']),
      lastMessageSenderId: serializer.fromJson<int?>(
        json['lastMessageSenderId'],
      ),
      lastMessageCreatedAt: serializer.fromJson<DateTime?>(
        json['lastMessageCreatedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'otherUserId': serializer.toJson<int?>(otherUserId),
      'title': serializer.toJson<String?>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastMessageId': serializer.toJson<int?>(lastMessageId),
      'lastMessageText': serializer.toJson<String?>(lastMessageText),
      'lastMessageSenderId': serializer.toJson<int?>(lastMessageSenderId),
      'lastMessageCreatedAt': serializer.toJson<DateTime?>(
        lastMessageCreatedAt,
      ),
    };
  }

  LocalChat copyWith({
    int? id,
    String? type,
    Value<int?> otherUserId = const Value.absent(),
    Value<String?> title = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<int?> lastMessageId = const Value.absent(),
    Value<String?> lastMessageText = const Value.absent(),
    Value<int?> lastMessageSenderId = const Value.absent(),
    Value<DateTime?> lastMessageCreatedAt = const Value.absent(),
  }) => LocalChat(
    id: id ?? this.id,
    type: type ?? this.type,
    otherUserId: otherUserId.present ? otherUserId.value : this.otherUserId,
    title: title.present ? title.value : this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastMessageId: lastMessageId.present
        ? lastMessageId.value
        : this.lastMessageId,
    lastMessageText: lastMessageText.present
        ? lastMessageText.value
        : this.lastMessageText,
    lastMessageSenderId: lastMessageSenderId.present
        ? lastMessageSenderId.value
        : this.lastMessageSenderId,
    lastMessageCreatedAt: lastMessageCreatedAt.present
        ? lastMessageCreatedAt.value
        : this.lastMessageCreatedAt,
  );
  LocalChat copyWithCompanion(LocalChatsCompanion data) {
    return LocalChat(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      otherUserId: data.otherUserId.present
          ? data.otherUserId.value
          : this.otherUserId,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastMessageId: data.lastMessageId.present
          ? data.lastMessageId.value
          : this.lastMessageId,
      lastMessageText: data.lastMessageText.present
          ? data.lastMessageText.value
          : this.lastMessageText,
      lastMessageSenderId: data.lastMessageSenderId.present
          ? data.lastMessageSenderId.value
          : this.lastMessageSenderId,
      lastMessageCreatedAt: data.lastMessageCreatedAt.present
          ? data.lastMessageCreatedAt.value
          : this.lastMessageCreatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChat(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('otherUserId: $otherUserId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessageText: $lastMessageText, ')
          ..write('lastMessageSenderId: $lastMessageSenderId, ')
          ..write('lastMessageCreatedAt: $lastMessageCreatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    otherUserId,
    title,
    createdAt,
    updatedAt,
    lastMessageId,
    lastMessageText,
    lastMessageSenderId,
    lastMessageCreatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChat &&
          other.id == this.id &&
          other.type == this.type &&
          other.otherUserId == this.otherUserId &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastMessageId == this.lastMessageId &&
          other.lastMessageText == this.lastMessageText &&
          other.lastMessageSenderId == this.lastMessageSenderId &&
          other.lastMessageCreatedAt == this.lastMessageCreatedAt);
}

class LocalChatsCompanion extends UpdateCompanion<LocalChat> {
  final Value<int> id;
  final Value<String> type;
  final Value<int?> otherUserId;
  final Value<String?> title;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int?> lastMessageId;
  final Value<String?> lastMessageText;
  final Value<int?> lastMessageSenderId;
  final Value<DateTime?> lastMessageCreatedAt;
  const LocalChatsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.otherUserId = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastMessageId = const Value.absent(),
    this.lastMessageText = const Value.absent(),
    this.lastMessageSenderId = const Value.absent(),
    this.lastMessageCreatedAt = const Value.absent(),
  });
  LocalChatsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    this.otherUserId = const Value.absent(),
    this.title = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastMessageId = const Value.absent(),
    this.lastMessageText = const Value.absent(),
    this.lastMessageSenderId = const Value.absent(),
    this.lastMessageCreatedAt = const Value.absent(),
  }) : type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalChat> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? otherUserId,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? lastMessageId,
    Expression<String>? lastMessageText,
    Expression<int>? lastMessageSenderId,
    Expression<DateTime>? lastMessageCreatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (otherUserId != null) 'other_user_id': otherUserId,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastMessageId != null) 'last_message_id': lastMessageId,
      if (lastMessageText != null) 'last_message_text': lastMessageText,
      if (lastMessageSenderId != null)
        'last_message_sender_id': lastMessageSenderId,
      if (lastMessageCreatedAt != null)
        'last_message_created_at': lastMessageCreatedAt,
    });
  }

  LocalChatsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<int?>? otherUserId,
    Value<String?>? title,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int?>? lastMessageId,
    Value<String?>? lastMessageText,
    Value<int?>? lastMessageSenderId,
    Value<DateTime?>? lastMessageCreatedAt,
  }) {
    return LocalChatsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      otherUserId: otherUserId ?? this.otherUserId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageCreatedAt: lastMessageCreatedAt ?? this.lastMessageCreatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (otherUserId.present) {
      map['other_user_id'] = Variable<int>(otherUserId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastMessageId.present) {
      map['last_message_id'] = Variable<int>(lastMessageId.value);
    }
    if (lastMessageText.present) {
      map['last_message_text'] = Variable<String>(lastMessageText.value);
    }
    if (lastMessageSenderId.present) {
      map['last_message_sender_id'] = Variable<int>(lastMessageSenderId.value);
    }
    if (lastMessageCreatedAt.present) {
      map['last_message_created_at'] = Variable<DateTime>(
        lastMessageCreatedAt.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChatsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('otherUserId: $otherUserId, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastMessageId: $lastMessageId, ')
          ..write('lastMessageText: $lastMessageText, ')
          ..write('lastMessageSenderId: $lastMessageSenderId, ')
          ..write('lastMessageCreatedAt: $lastMessageCreatedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalChatMembersTable extends LocalChatMembers
    with TableInfo<$LocalChatMembersTable, LocalChatMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalChatMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, chatId, userId, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_chat_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalChatMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalChatMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalChatMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $LocalChatMembersTable createAlias(String alias) {
    return $LocalChatMembersTable(attachedDatabase, alias);
  }
}

class LocalChatMember extends DataClass implements Insertable<LocalChatMember> {
  final int id;
  final int chatId;
  final int userId;
  final bool isActive;
  const LocalChatMember({
    required this.id,
    required this.chatId,
    required this.userId,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chat_id'] = Variable<int>(chatId);
    map['user_id'] = Variable<int>(userId);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  LocalChatMembersCompanion toCompanion(bool nullToAbsent) {
    return LocalChatMembersCompanion(
      id: Value(id),
      chatId: Value(chatId),
      userId: Value(userId),
      isActive: Value(isActive),
    );
  }

  factory LocalChatMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalChatMember(
      id: serializer.fromJson<int>(json['id']),
      chatId: serializer.fromJson<int>(json['chatId']),
      userId: serializer.fromJson<int>(json['userId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chatId': serializer.toJson<int>(chatId),
      'userId': serializer.toJson<int>(userId),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  LocalChatMember copyWith({
    int? id,
    int? chatId,
    int? userId,
    bool? isActive,
  }) => LocalChatMember(
    id: id ?? this.id,
    chatId: chatId ?? this.chatId,
    userId: userId ?? this.userId,
    isActive: isActive ?? this.isActive,
  );
  LocalChatMember copyWithCompanion(LocalChatMembersCompanion data) {
    return LocalChatMember(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      userId: data.userId.present ? data.userId.value : this.userId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalChatMember(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('userId: $userId, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, chatId, userId, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalChatMember &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.userId == this.userId &&
          other.isActive == this.isActive);
}

class LocalChatMembersCompanion extends UpdateCompanion<LocalChatMember> {
  final Value<int> id;
  final Value<int> chatId;
  final Value<int> userId;
  final Value<bool> isActive;
  const LocalChatMembersCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.userId = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  LocalChatMembersCompanion.insert({
    this.id = const Value.absent(),
    required int chatId,
    required int userId,
    this.isActive = const Value.absent(),
  }) : chatId = Value(chatId),
       userId = Value(userId);
  static Insertable<LocalChatMember> custom({
    Expression<int>? id,
    Expression<int>? chatId,
    Expression<int>? userId,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (userId != null) 'user_id': userId,
      if (isActive != null) 'is_active': isActive,
    });
  }

  LocalChatMembersCompanion copyWith({
    Value<int>? id,
    Value<int>? chatId,
    Value<int>? userId,
    Value<bool>? isActive,
  }) {
    return LocalChatMembersCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalChatMembersCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('userId: $userId, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $LocalMessagesTable extends LocalMessages
    with TableInfo<$LocalMessagesTable, LocalMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<int> senderId = GeneratedColumn<int>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientMessageIdMeta = const VerificationMeta(
    'clientMessageId',
  );
  @override
  late final GeneratedColumn<String> clientMessageId = GeneratedColumn<String>(
    'client_message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageTextMeta = const VerificationMeta(
    'messageText',
  );
  @override
  late final GeneratedColumn<String> messageText = GeneratedColumn<String>(
    'message_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sendStatusMeta = const VerificationMeta(
    'sendStatus',
  );
  @override
  late final GeneratedColumn<String> sendStatus = GeneratedColumn<String>(
    'send_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sent'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    chatId,
    senderId,
    clientMessageId,
    messageText,
    createdAt,
    editedAt,
    isDeleted,
    sendStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('client_message_id')) {
      context.handle(
        _clientMessageIdMeta,
        clientMessageId.isAcceptableOrUnknown(
          data['client_message_id']!,
          _clientMessageIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientMessageIdMeta);
    }
    if (data.containsKey('message_text')) {
      context.handle(
        _messageTextMeta,
        messageText.isAcceptableOrUnknown(
          data['message_text']!,
          _messageTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('send_status')) {
      context.handle(
        _sendStatusMeta,
        sendStatus.isAcceptableOrUnknown(data['send_status']!, _sendStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMessage(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_id'],
      ),
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sender_id'],
      )!,
      clientMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_message_id'],
      )!,
      messageText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_text'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      sendStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}send_status'],
      )!,
    );
  }

  @override
  $LocalMessagesTable createAlias(String alias) {
    return $LocalMessagesTable(attachedDatabase, alias);
  }
}

class LocalMessage extends DataClass implements Insertable<LocalMessage> {
  final int localId;
  final int? serverId;
  final int chatId;
  final int senderId;
  final String clientMessageId;
  final String messageText;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isDeleted;
  final String sendStatus;
  const LocalMessage({
    required this.localId,
    this.serverId,
    required this.chatId,
    required this.senderId,
    required this.clientMessageId,
    required this.messageText,
    required this.createdAt,
    this.editedAt,
    required this.isDeleted,
    required this.sendStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['chat_id'] = Variable<int>(chatId);
    map['sender_id'] = Variable<int>(senderId);
    map['client_message_id'] = Variable<String>(clientMessageId);
    map['message_text'] = Variable<String>(messageText);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['send_status'] = Variable<String>(sendStatus);
    return map;
  }

  LocalMessagesCompanion toCompanion(bool nullToAbsent) {
    return LocalMessagesCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      chatId: Value(chatId),
      senderId: Value(senderId),
      clientMessageId: Value(clientMessageId),
      messageText: Value(messageText),
      createdAt: Value(createdAt),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
      isDeleted: Value(isDeleted),
      sendStatus: Value(sendStatus),
    );
  }

  factory LocalMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMessage(
      localId: serializer.fromJson<int>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      chatId: serializer.fromJson<int>(json['chatId']),
      senderId: serializer.fromJson<int>(json['senderId']),
      clientMessageId: serializer.fromJson<String>(json['clientMessageId']),
      messageText: serializer.fromJson<String>(json['messageText']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      sendStatus: serializer.fromJson<String>(json['sendStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'chatId': serializer.toJson<int>(chatId),
      'senderId': serializer.toJson<int>(senderId),
      'clientMessageId': serializer.toJson<String>(clientMessageId),
      'messageText': serializer.toJson<String>(messageText),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'sendStatus': serializer.toJson<String>(sendStatus),
    };
  }

  LocalMessage copyWith({
    int? localId,
    Value<int?> serverId = const Value.absent(),
    int? chatId,
    int? senderId,
    String? clientMessageId,
    String? messageText,
    DateTime? createdAt,
    Value<DateTime?> editedAt = const Value.absent(),
    bool? isDeleted,
    String? sendStatus,
  }) => LocalMessage(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    chatId: chatId ?? this.chatId,
    senderId: senderId ?? this.senderId,
    clientMessageId: clientMessageId ?? this.clientMessageId,
    messageText: messageText ?? this.messageText,
    createdAt: createdAt ?? this.createdAt,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    sendStatus: sendStatus ?? this.sendStatus,
  );
  LocalMessage copyWithCompanion(LocalMessagesCompanion data) {
    return LocalMessage(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      clientMessageId: data.clientMessageId.present
          ? data.clientMessageId.value
          : this.clientMessageId,
      messageText: data.messageText.present
          ? data.messageText.value
          : this.messageText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      sendStatus: data.sendStatus.present
          ? data.sendStatus.value
          : this.sendStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessage(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('messageText: $messageText, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('sendStatus: $sendStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    chatId,
    senderId,
    clientMessageId,
    messageText,
    createdAt,
    editedAt,
    isDeleted,
    sendStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMessage &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.chatId == this.chatId &&
          other.senderId == this.senderId &&
          other.clientMessageId == this.clientMessageId &&
          other.messageText == this.messageText &&
          other.createdAt == this.createdAt &&
          other.editedAt == this.editedAt &&
          other.isDeleted == this.isDeleted &&
          other.sendStatus == this.sendStatus);
}

class LocalMessagesCompanion extends UpdateCompanion<LocalMessage> {
  final Value<int> localId;
  final Value<int?> serverId;
  final Value<int> chatId;
  final Value<int> senderId;
  final Value<String> clientMessageId;
  final Value<String> messageText;
  final Value<DateTime> createdAt;
  final Value<DateTime?> editedAt;
  final Value<bool> isDeleted;
  final Value<String> sendStatus;
  const LocalMessagesCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.chatId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.clientMessageId = const Value.absent(),
    this.messageText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.sendStatus = const Value.absent(),
  });
  LocalMessagesCompanion.insert({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    required int chatId,
    required int senderId,
    required String clientMessageId,
    required String messageText,
    required DateTime createdAt,
    this.editedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.sendStatus = const Value.absent(),
  }) : chatId = Value(chatId),
       senderId = Value(senderId),
       clientMessageId = Value(clientMessageId),
       messageText = Value(messageText),
       createdAt = Value(createdAt);
  static Insertable<LocalMessage> custom({
    Expression<int>? localId,
    Expression<int>? serverId,
    Expression<int>? chatId,
    Expression<int>? senderId,
    Expression<String>? clientMessageId,
    Expression<String>? messageText,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? editedAt,
    Expression<bool>? isDeleted,
    Expression<String>? sendStatus,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (chatId != null) 'chat_id': chatId,
      if (senderId != null) 'sender_id': senderId,
      if (clientMessageId != null) 'client_message_id': clientMessageId,
      if (messageText != null) 'message_text': messageText,
      if (createdAt != null) 'created_at': createdAt,
      if (editedAt != null) 'edited_at': editedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (sendStatus != null) 'send_status': sendStatus,
    });
  }

  LocalMessagesCompanion copyWith({
    Value<int>? localId,
    Value<int?>? serverId,
    Value<int>? chatId,
    Value<int>? senderId,
    Value<String>? clientMessageId,
    Value<String>? messageText,
    Value<DateTime>? createdAt,
    Value<DateTime?>? editedAt,
    Value<bool>? isDeleted,
    Value<String>? sendStatus,
  }) {
    return LocalMessagesCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      messageText: messageText ?? this.messageText,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      sendStatus: sendStatus ?? this.sendStatus,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<int>(senderId.value);
    }
    if (clientMessageId.present) {
      map['client_message_id'] = Variable<String>(clientMessageId.value);
    }
    if (messageText.present) {
      map['message_text'] = Variable<String>(messageText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (sendStatus.present) {
      map['send_status'] = Variable<String>(sendStatus.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMessagesCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('chatId: $chatId, ')
          ..write('senderId: $senderId, ')
          ..write('clientMessageId: $clientMessageId, ')
          ..write('messageText: $messageText, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('sendStatus: $sendStatus')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $LocalChatsTable localChats = $LocalChatsTable(this);
  late final $LocalChatMembersTable localChatMembers = $LocalChatMembersTable(
    this,
  );
  late final $LocalMessagesTable localMessages = $LocalMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localUsers,
    appSettings,
    localChats,
    localChatMembers,
    localMessages,
  ];
}

typedef $$LocalUsersTableCreateCompanionBuilder =
    LocalUsersCompanion Function({
      required int id,
      required String username,
      Value<String?> firstName,
      Value<String?> email,
      Value<String?> phone,
      Value<String> status,
      Value<String> presence,
      Value<DateTime?> lastSeen,
      Value<bool> isActive,
      Value<String?> token,
      Value<String?> avatarFileId,
      Value<String?> avatarLocalPath,
      Value<int> rowid,
    });
typedef $$LocalUsersTableUpdateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String?> firstName,
      Value<String?> email,
      Value<String?> phone,
      Value<String> status,
      Value<String> presence,
      Value<DateTime?> lastSeen,
      Value<bool> isActive,
      Value<String?> token,
      Value<String?> avatarFileId,
      Value<String?> avatarLocalPath,
      Value<int> rowid,
    });

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presence => $composableBuilder(
    column: $table.presence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarFileId => $composableBuilder(
    column: $table.avatarFileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarLocalPath => $composableBuilder(
    column: $table.avatarLocalPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presence => $composableBuilder(
    column: $table.presence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarFileId => $composableBuilder(
    column: $table.avatarFileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarLocalPath => $composableBuilder(
    column: $table.avatarLocalPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get presence =>
      $composableBuilder(column: $table.presence, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get avatarFileId => $composableBuilder(
    column: $table.avatarFileId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarLocalPath => $composableBuilder(
    column: $table.avatarLocalPath,
    builder: (column) => column,
  );
}

class $$LocalUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUsersTable,
          LocalUser,
          $$LocalUsersTableFilterComposer,
          $$LocalUsersTableOrderingComposer,
          $$LocalUsersTableAnnotationComposer,
          $$LocalUsersTableCreateCompanionBuilder,
          $$LocalUsersTableUpdateCompanionBuilder,
          (
            LocalUser,
            BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>,
          ),
          LocalUser,
          PrefetchHooks Function()
        > {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String?> firstName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> presence = const Value.absent(),
                Value<DateTime?> lastSeen = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<String?> avatarFileId = const Value.absent(),
                Value<String?> avatarLocalPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion(
                id: id,
                username: username,
                firstName: firstName,
                email: email,
                phone: phone,
                status: status,
                presence: presence,
                lastSeen: lastSeen,
                isActive: isActive,
                token: token,
                avatarFileId: avatarFileId,
                avatarLocalPath: avatarLocalPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String username,
                Value<String?> firstName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> presence = const Value.absent(),
                Value<DateTime?> lastSeen = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<String?> avatarFileId = const Value.absent(),
                Value<String?> avatarLocalPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion.insert(
                id: id,
                username: username,
                firstName: firstName,
                email: email,
                phone: phone,
                status: status,
                presence: presence,
                lastSeen: lastSeen,
                isActive: isActive,
                token: token,
                avatarFileId: avatarFileId,
                avatarLocalPath: avatarLocalPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUsersTable,
      LocalUser,
      $$LocalUsersTableFilterComposer,
      $$LocalUsersTableOrderingComposer,
      $$LocalUsersTableAnnotationComposer,
      $$LocalUsersTableCreateCompanionBuilder,
      $$LocalUsersTableUpdateCompanionBuilder,
      (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
      LocalUser,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> theme,
      Value<String> language,
      Value<bool> notifications,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> theme,
      Value<String> language,
      Value<bool> notifications,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<bool> get notifications => $composableBuilder(
    column: $table.notifications,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<bool> notifications = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                theme: theme,
                language: language,
                notifications: notifications,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<bool> notifications = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                theme: theme,
                language: language,
                notifications: notifications,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$LocalChatsTableCreateCompanionBuilder =
    LocalChatsCompanion Function({
      Value<int> id,
      required String type,
      Value<int?> otherUserId,
      Value<String?> title,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int?> lastMessageId,
      Value<String?> lastMessageText,
      Value<int?> lastMessageSenderId,
      Value<DateTime?> lastMessageCreatedAt,
    });
typedef $$LocalChatsTableUpdateCompanionBuilder =
    LocalChatsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<int?> otherUserId,
      Value<String?> title,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int?> lastMessageId,
      Value<String?> lastMessageText,
      Value<int?> lastMessageSenderId,
      Value<DateTime?> lastMessageCreatedAt,
    });

class $$LocalChatsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get otherUserId => $composableBuilder(
    column: $table.otherUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessageText => $composableBuilder(
    column: $table.lastMessageText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastMessageSenderId => $composableBuilder(
    column: $table.lastMessageSenderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageCreatedAt => $composableBuilder(
    column: $table.lastMessageCreatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get otherUserId => $composableBuilder(
    column: $table.otherUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessageText => $composableBuilder(
    column: $table.lastMessageText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastMessageSenderId => $composableBuilder(
    column: $table.lastMessageSenderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageCreatedAt => $composableBuilder(
    column: $table.lastMessageCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalChatsTable> {
  $$LocalChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get otherUserId => $composableBuilder(
    column: $table.otherUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastMessageId => $composableBuilder(
    column: $table.lastMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMessageText => $composableBuilder(
    column: $table.lastMessageText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastMessageSenderId => $composableBuilder(
    column: $table.lastMessageSenderId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageCreatedAt => $composableBuilder(
    column: $table.lastMessageCreatedAt,
    builder: (column) => column,
  );
}

class $$LocalChatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalChatsTable,
          LocalChat,
          $$LocalChatsTableFilterComposer,
          $$LocalChatsTableOrderingComposer,
          $$LocalChatsTableAnnotationComposer,
          $$LocalChatsTableCreateCompanionBuilder,
          $$LocalChatsTableUpdateCompanionBuilder,
          (
            LocalChat,
            BaseReferences<_$AppDatabase, $LocalChatsTable, LocalChat>,
          ),
          LocalChat,
          PrefetchHooks Function()
        > {
  $$LocalChatsTableTableManager(_$AppDatabase db, $LocalChatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> otherUserId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int?> lastMessageId = const Value.absent(),
                Value<String?> lastMessageText = const Value.absent(),
                Value<int?> lastMessageSenderId = const Value.absent(),
                Value<DateTime?> lastMessageCreatedAt = const Value.absent(),
              }) => LocalChatsCompanion(
                id: id,
                type: type,
                otherUserId: otherUserId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastMessageId: lastMessageId,
                lastMessageText: lastMessageText,
                lastMessageSenderId: lastMessageSenderId,
                lastMessageCreatedAt: lastMessageCreatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                Value<int?> otherUserId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int?> lastMessageId = const Value.absent(),
                Value<String?> lastMessageText = const Value.absent(),
                Value<int?> lastMessageSenderId = const Value.absent(),
                Value<DateTime?> lastMessageCreatedAt = const Value.absent(),
              }) => LocalChatsCompanion.insert(
                id: id,
                type: type,
                otherUserId: otherUserId,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastMessageId: lastMessageId,
                lastMessageText: lastMessageText,
                lastMessageSenderId: lastMessageSenderId,
                lastMessageCreatedAt: lastMessageCreatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalChatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalChatsTable,
      LocalChat,
      $$LocalChatsTableFilterComposer,
      $$LocalChatsTableOrderingComposer,
      $$LocalChatsTableAnnotationComposer,
      $$LocalChatsTableCreateCompanionBuilder,
      $$LocalChatsTableUpdateCompanionBuilder,
      (LocalChat, BaseReferences<_$AppDatabase, $LocalChatsTable, LocalChat>),
      LocalChat,
      PrefetchHooks Function()
    >;
typedef $$LocalChatMembersTableCreateCompanionBuilder =
    LocalChatMembersCompanion Function({
      Value<int> id,
      required int chatId,
      required int userId,
      Value<bool> isActive,
    });
typedef $$LocalChatMembersTableUpdateCompanionBuilder =
    LocalChatMembersCompanion Function({
      Value<int> id,
      Value<int> chatId,
      Value<int> userId,
      Value<bool> isActive,
    });

class $$LocalChatMembersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalChatMembersTable> {
  $$LocalChatMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalChatMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalChatMembersTable> {
  $$LocalChatMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalChatMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalChatMembersTable> {
  $$LocalChatMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$LocalChatMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalChatMembersTable,
          LocalChatMember,
          $$LocalChatMembersTableFilterComposer,
          $$LocalChatMembersTableOrderingComposer,
          $$LocalChatMembersTableAnnotationComposer,
          $$LocalChatMembersTableCreateCompanionBuilder,
          $$LocalChatMembersTableUpdateCompanionBuilder,
          (
            LocalChatMember,
            BaseReferences<
              _$AppDatabase,
              $LocalChatMembersTable,
              LocalChatMember
            >,
          ),
          LocalChatMember,
          PrefetchHooks Function()
        > {
  $$LocalChatMembersTableTableManager(
    _$AppDatabase db,
    $LocalChatMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalChatMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalChatMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalChatMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> chatId = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => LocalChatMembersCompanion(
                id: id,
                chatId: chatId,
                userId: userId,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int chatId,
                required int userId,
                Value<bool> isActive = const Value.absent(),
              }) => LocalChatMembersCompanion.insert(
                id: id,
                chatId: chatId,
                userId: userId,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalChatMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalChatMembersTable,
      LocalChatMember,
      $$LocalChatMembersTableFilterComposer,
      $$LocalChatMembersTableOrderingComposer,
      $$LocalChatMembersTableAnnotationComposer,
      $$LocalChatMembersTableCreateCompanionBuilder,
      $$LocalChatMembersTableUpdateCompanionBuilder,
      (
        LocalChatMember,
        BaseReferences<_$AppDatabase, $LocalChatMembersTable, LocalChatMember>,
      ),
      LocalChatMember,
      PrefetchHooks Function()
    >;
typedef $$LocalMessagesTableCreateCompanionBuilder =
    LocalMessagesCompanion Function({
      Value<int> localId,
      Value<int?> serverId,
      required int chatId,
      required int senderId,
      required String clientMessageId,
      required String messageText,
      required DateTime createdAt,
      Value<DateTime?> editedAt,
      Value<bool> isDeleted,
      Value<String> sendStatus,
    });
typedef $$LocalMessagesTableUpdateCompanionBuilder =
    LocalMessagesCompanion Function({
      Value<int> localId,
      Value<int?> serverId,
      Value<int> chatId,
      Value<int> senderId,
      Value<String> clientMessageId,
      Value<String> messageText,
      Value<DateTime> createdAt,
      Value<DateTime?> editedAt,
      Value<bool> isDeleted,
      Value<String> sendStatus,
    });

class $$LocalMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sendStatus => $composableBuilder(
    column: $table.sendStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sendStatus => $composableBuilder(
    column: $table.sendStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMessagesTable> {
  $$LocalMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<int> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get clientMessageId => $composableBuilder(
    column: $table.clientMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageText => $composableBuilder(
    column: $table.messageText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get sendStatus => $composableBuilder(
    column: $table.sendStatus,
    builder: (column) => column,
  );
}

class $$LocalMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMessagesTable,
          LocalMessage,
          $$LocalMessagesTableFilterComposer,
          $$LocalMessagesTableOrderingComposer,
          $$LocalMessagesTableAnnotationComposer,
          $$LocalMessagesTableCreateCompanionBuilder,
          $$LocalMessagesTableUpdateCompanionBuilder,
          (
            LocalMessage,
            BaseReferences<_$AppDatabase, $LocalMessagesTable, LocalMessage>,
          ),
          LocalMessage,
          PrefetchHooks Function()
        > {
  $$LocalMessagesTableTableManager(_$AppDatabase db, $LocalMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                Value<int> chatId = const Value.absent(),
                Value<int> senderId = const Value.absent(),
                Value<String> clientMessageId = const Value.absent(),
                Value<String> messageText = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> sendStatus = const Value.absent(),
              }) => LocalMessagesCompanion(
                localId: localId,
                serverId: serverId,
                chatId: chatId,
                senderId: senderId,
                clientMessageId: clientMessageId,
                messageText: messageText,
                createdAt: createdAt,
                editedAt: editedAt,
                isDeleted: isDeleted,
                sendStatus: sendStatus,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<int?> serverId = const Value.absent(),
                required int chatId,
                required int senderId,
                required String clientMessageId,
                required String messageText,
                required DateTime createdAt,
                Value<DateTime?> editedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> sendStatus = const Value.absent(),
              }) => LocalMessagesCompanion.insert(
                localId: localId,
                serverId: serverId,
                chatId: chatId,
                senderId: senderId,
                clientMessageId: clientMessageId,
                messageText: messageText,
                createdAt: createdAt,
                editedAt: editedAt,
                isDeleted: isDeleted,
                sendStatus: sendStatus,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMessagesTable,
      LocalMessage,
      $$LocalMessagesTableFilterComposer,
      $$LocalMessagesTableOrderingComposer,
      $$LocalMessagesTableAnnotationComposer,
      $$LocalMessagesTableCreateCompanionBuilder,
      $$LocalMessagesTableUpdateCompanionBuilder,
      (
        LocalMessage,
        BaseReferences<_$AppDatabase, $LocalMessagesTable, LocalMessage>,
      ),
      LocalMessage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$LocalChatsTableTableManager get localChats =>
      $$LocalChatsTableTableManager(_db, _db.localChats);
  $$LocalChatMembersTableTableManager get localChatMembers =>
      $$LocalChatMembersTableTableManager(_db, _db.localChatMembers);
  $$LocalMessagesTableTableManager get localMessages =>
      $$LocalMessagesTableTableManager(_db, _db.localMessages);
}
