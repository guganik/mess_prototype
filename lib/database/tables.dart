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