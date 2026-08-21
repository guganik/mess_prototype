import 'package:drift/drift.dart';

class LocalUsers extends Table {
  IntColumn get id => integer()();

  TextColumn get username => text()();
  TextColumn get firstName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();

  TextColumn get status => text().withDefault(const Constant('offline'))();

  TextColumn get presence => text().withDefault(const Constant('offline'))();

  DateTimeColumn get lastSeen => dateTime().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  TextColumn get token => text().nullable()();

  TextColumn get avatarFileId => text().nullable()();
  TextColumn get avatarLocalPath => text().nullable()();
}

class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get theme => text().withDefault(const Constant('Light'))();
  TextColumn get language => text().withDefault(const Constant('ru'))();
  
  BoolColumn get notifications => boolean().withDefault(const Constant(true))();
}

class LocalChats extends Table {
  IntColumn get id => integer()();

  TextColumn get type => text()();

  IntColumn get otherUserId =>
      integer().nullable()();

  TextColumn get title =>
      text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime()();

  DateTimeColumn get updatedAt =>
      dateTime()();

  IntColumn get lastMessageId =>
      integer().nullable()();

  TextColumn get lastMessageText =>
      text().nullable()();

  IntColumn get lastMessageSenderId =>
      integer().nullable()();

  DateTimeColumn get lastMessageCreatedAt =>
      dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}


class LocalChatMembers extends Table {
  IntColumn get id =>
      integer().autoIncrement()();

  IntColumn get chatId =>
      integer()();

  IntColumn get userId =>
      integer()();

  BoolColumn get isActive =>
      boolean().withDefault(
        const Constant(true),
      )();
}


class LocalMessages extends Table {
  IntColumn get localId =>
      integer().autoIncrement()();

  IntColumn get serverId =>
      integer().nullable()();

  IntColumn get chatId =>
      integer()();

  IntColumn get senderId =>
      integer()();

  TextColumn get clientMessageId =>
      text()();

  TextColumn get messageText =>
      text()();

  DateTimeColumn get createdAt =>
      dateTime()();

  DateTimeColumn get editedAt =>
      dateTime().nullable()();

  BoolColumn get isDeleted =>
      boolean().withDefault(
        const Constant(false),
      )();

  TextColumn get sendStatus =>
      text().withDefault(
        const Constant('sent'),
      )();
}