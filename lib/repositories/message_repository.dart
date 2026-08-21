import 'package:drift/drift.dart';

import 'package:mess_prototype/database/app_database.dart';

class MessageRepository {
  final AppDatabase database;

  MessageRepository({
    required this.database,
  });

  Future<int> insertSendingMessage({
    required int chatId,
    required int senderId,
    required String clientMessageId,
    required String messageText,
    required DateTime createdAt,
  }) async {
    return database.into(
      database.localMessages,
    ).insert(
      LocalMessagesCompanion.insert(
        chatId: chatId,
        senderId: senderId,
        clientMessageId: clientMessageId,
        messageText: messageText,
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
  ) {
    return (
      database.select(
        database.localMessages,
      )..where(
        (table) =>
            table.clientMessageId.equals(
              clientMessageId,
            ),
      )
    ).getSingleOrNull();
  }

  Future<void> insertServerMessage({
    required int serverId,
    required int chatId,
    required int senderId,
    required String clientMessageId,
    required String messageText,
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
        messageText: messageText,
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
      )..where(
        (table) => table.chatId.equals(chatId),
      )..orderBy([
        (table) => OrderingTerm(
          expression: table.createdAt,
          mode: OrderingMode.asc,
        ),
      ])
    ).watch();
  }
}