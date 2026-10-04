import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

/// Вид записи центра уведомлений.
enum InboxItemKind {
  /// Напоминание о событии питомца.
  event,

  /// Общее объявление без питомца и события.
  announcement;

  static InboxItemKind fromWire(String value) =>
      value == 'announcement' ? announcement : InboxItemKind.event;
}

/// Уведомление в списке центра уведомлений.
class InboxItem extends Equatable {
  const InboxItem({
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

  final String id;
  final InboxItemKind kind;
  final String title;
  final String body;

  /// Момент создания в локальной таймзоне пользователя.
  final DateTime createdAt;
  final bool isRead;
  final int? petId;
  final String? eventId;

  /// Тип события; `null` у объявлений и у типов, которых приложение не знает.
  final ScheduleEventTypeEnum? eventType;

  /// Дата вхождения события, о котором уведомление.
  final DateTime? occurrenceDate;

  InboxItem copyWith({bool? isRead}) => InboxItem(
    id: id,
    kind: kind,
    title: title,
    body: body,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
    petId: petId,
    eventId: eventId,
    eventType: eventType,
    occurrenceDate: occurrenceDate,
  );

  @override
  List<Object?> get props => [
    id,
    kind,
    title,
    body,
    createdAt,
    isRead,
    petId,
    eventId,
    eventType,
    occurrenceDate,
  ];
}

/// Страница списка уведомлений.
class InboxPage extends Equatable {
  const InboxPage({required this.items, required this.nextCursor, required this.unreadCount});

  final List<InboxItem> items;

  /// Курсор следующей страницы; `null`, если страниц больше нет.
  final String? nextCursor;

  /// Все непрочитанные пользователя, а не только на этой странице.
  final int unreadCount;

  @override
  List<Object?> get props => [items, nextCursor, unreadCount];
}
