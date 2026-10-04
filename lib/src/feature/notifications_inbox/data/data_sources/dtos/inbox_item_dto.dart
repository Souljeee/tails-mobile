/// Элемент списка `GET /notifications/`.
class InboxItemDto {
  const InboxItemDto({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.petId,
    this.eventId,
    this.eventType,
    this.occurrenceDate,
  });

  /// Разбирает элемент ответа. Throws [FormatException], если нет обязательных полей.
  factory InboxItemDto.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final createdAt = json['created_at'];

    if (id is! String || createdAt is! String) {
      throw const FormatException('Некорректный элемент центра уведомлений');
    }

    return InboxItemDto(
      id: id,
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: createdAt,
      isRead: json['is_read'] as bool? ?? false,
      petId: json['pet_id'] as int?,
      eventId: json['event_id'] as String?,
      eventType: json['event_type'] as String?,
      occurrenceDate: json['occurrence_date'] as String?,
    );
  }

  final String id;

  /// `event` или `announcement`.
  final String kind;
  final String title;
  final String body;

  /// Момент создания, ISO 8601 в UTC.
  final String createdAt;
  final bool isRead;
  final int? petId;
  final String? eventId;

  /// Тип события (`ScheduleEventTypeEnum.name`); пустая строка с сервера означает «нет».
  final String? eventType;

  /// Дата вхождения `yyyy-MM-dd`.
  final String? occurrenceDate;
}

/// Страница списка уведомлений.
class InboxPageDto {
  const InboxPageDto({required this.results, required this.nextCursor, required this.unreadCount});

  factory InboxPageDto.fromJson(Map<String, Object?> json) {
    final results = json['results'];
    final unreadCount = json['unread_count'];

    if (results is! List<Object?> || unreadCount is! int) {
      throw const FormatException('Некорректный ответ центра уведомлений');
    }

    return InboxPageDto(
      results: [for (final item in results) InboxItemDto.fromJson(_asMap(item))],
      nextCursor: json['next_cursor'] as String?,
      unreadCount: unreadCount,
    );
  }

  final List<InboxItemDto> results;
  final String? nextCursor;
  final int unreadCount;

  static Map<String, Object?> _asMap(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }

    throw const FormatException('Некорректный элемент центра уведомлений');
  }
}
