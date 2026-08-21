import 'package:drift/drift.dart';

import 'package:mess_prototype/database/app_database.dart';
import 'package:mess_prototype/models/local_message.dart';

class MessageRepository {
  final AppDatabase database;

  MessageRepository({
    required this.database,
  });

  Future<int> insertSendingMessage({
    required int chatId,
    required int senderId,
    required String clientMessageId,
    required String text,
    required DateTime createdAt,
  }) async {
    return database.into(
      database.localMessages,
    ).insert(
      LocalMessagesCompanion.insert(
        chatId: chatId,
        senderId: senderId,
        clientMessageId: clientMessageId,
        text: text,
        createdAt: createdAt,
        sendStatus: const Value('sending'),
      ),
    );
  }

  Future<void> markAsSent({
    required int localId,
    required int serverId,
  }) async {
    await (
      database.update(
        database.localMessages,
      )..where(
        (table) => table.localId.equals(localId),
      )
    ).write(
      LocalMessagesCompanion(
        serverId: Value(serverId),
        sendStatus: const Value('sent'),
      ),
    );
  }

  Future<void> markAsFailed(
    int localId,
  ) async {
    await (
      database.update(
        database.localMessages,
      )..where(
        (table) => table.localId.equals(localId),
      )
    ).write(
      const LocalMessagesCompanion(
        sendStatus: Value('failed'),
      ),
    );
  }

  Future<LocalMessage?> findByClientMessageId(
    String clientMessageId,
  ) async {
    final row = await (
      database.select(
        database.localMessages,
      )..where(
        (table) =>
            table.clientMessageId.equals(
              clientMessageId,
            ),
      )
    ).getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _map(row);
  }

  Future<void> insertServerMessage({
    required int serverId,
    required int chatId,
    required int senderId,
    required String clientMessageId,
    required String text,
    required DateTime createdAt,
    DateTime? editedAt,
    bool isDeleted = false,
  }) async {
    final existing =
        await findByClientMessageId(
      clientMessageId,
    );

    if (existing != null) {
      await markAsSent(
        localId: existing.localId,
        serverId: serverId,
      );

      return;
    }

    await database.into(
      database.localMessages,
    ).insert(
      LocalMessagesCompanion.insert(
        serverId: Value(serverId),
        chatId: chatId,
        senderId: senderId,
        clientMessageId: clientMessageId,
        text: text,
        createdAt: createdAt,
        editedAt: Value(editedAt),
        isDeleted: Value(isDeleted),
        sendStatus: const Value('sent'),
      ),
    );
  }

  Stream<List<LocalMessage>> watchChat(
    int chatId,
  ) {
    return (
      database.select(
        database.localMessages,
      )
        ..where(
          (table) => table.chatId.equals(chatId),
        )
        ..orderBy([
          (table) => OrderingTerm(
                expression: table.createdAt,
                mode: OrderingMode.asc,
              ),
        ])
    ).watch().map(
      (rows) => rows.map(_map).toList(),
    );
  }

  LocalMessage _map(
    LocalMessageData row,
  ) {
    return LocalMessage(
      localId: row.localId,
      serverId: row.serverId,
      chatId: row.chatId,
      senderId: row.senderId,
      clientMessageId: row.clientMessageId,
      text: row.text,
      createdAt: row.createdAt,
      editedAt: row.editedAt,
      isDeleted: row.isDeleted,
      sendStatus: MessageSendStatus.values.firstWhere(
        (value) => value.name == row.sendStatus,
        orElse: () => MessageSendStatus.sent,
      ),
    );
  }
}