import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalUsers,
    AppSettings,
    LocalChats,
    LocalChatMembers,
    LocalMessages,
  ],
)

class AppDatabase extends _$AppDatabase {
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },

    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 7) {
        await m.addColumn(
          localUsers,
          localUsers.avatarFileId
        );
        await m.addColumn(
          localUsers,
          localUsers.avatarLocalPath
        );
      }
    }
  );

  AppDatabase()
    : super(_openConnection());

  @override
  int get schemaVersion => 7;

  Future<int> saveUser(LocalUsersCompanion user) {
    return into(localUsers).insert(user);
  }

  Future<LocalUser?> getUser() {
    return select(localUsers).getSingleOrNull();
  }

  Future deleteUser() {
    return delete(localUsers).go();
  }

  Future<void> updateUser(
    int id, {
      String? username,
      String? firstName,
      String? email,
      String? phone,
      String? status,
      String? presence,
      DateTime? lastSeen,
      bool? isActive,
      String? token,
      Value<String?> avatarFileId = const Value.absent(),
      Value<String?> avatarLocalPath = const Value.absent(),
    }) {
    return (update(localUsers)..where((u) => u.id.equals(id))).write(
      LocalUsersCompanion(
        username: username != null ? Value(username) : const Value.absent(),
        firstName: firstName != null ? Value(firstName) : const Value.absent(),
        email: email != null ? Value(email) : const Value.absent(),
        phone: phone != null ? Value(phone) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        presence: presence != null ? Value(presence) : const Value.absent(),
        lastSeen: lastSeen != null ? Value(lastSeen) : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        token: token != null ? Value(token) : const Value.absent(),
        avatarFileId: avatarFileId,
        avatarLocalPath: avatarLocalPath,
      )
    );
  }


  Future<int> createSettings() {
    return into(appSettings).insert(AppSettingsCompanion.insert());
  }

  Future<AppSetting?> getSettings() {
    return select(appSettings).getSingleOrNull();
  }

  Future updateTheme(String value) {
    return update(appSettings).write(AppSettingsCompanion(theme: Value(value)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();

    final file = File(p.join(dir.path, 'app.sqlite'));

    return NativeDatabase(file);
  });
}