abstract class DefaultDatabaseItem {
  final int? databaseId;
  final DateTime createdAt;

  const DefaultDatabaseItem({
    this.databaseId,
    required this.createdAt,
  });

  Map<String, Object?> toDatabaseRow() => {
        if (databaseId != null) 'id': databaseId,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}
