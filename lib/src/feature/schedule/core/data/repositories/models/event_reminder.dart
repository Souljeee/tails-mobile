import 'package:equatable/equatable.dart';

/// Напоминание о событии: за сколько минут до вхождения придёт уведомление либо «не напоминать».
///
/// На сервере это список `reminders`: `[]` — не напоминать, `[m]` — за `m` минут (`0` — в момент
/// события), `null` — значение не задано (старое событие): в приложении оно читается как «в момент
/// события» и представлено `null` в моделях, а не этим типом.
class EventReminder extends Equatable {
  /// Уведомление не придёт.
  const EventReminder.none() : minutes = null;

  /// Уведомление за [minutes] минут до вхождения; `0` — в момент события.
  const EventReminder.before(int this.minutes) : assert(minutes >= 0, 'minutes must be >= 0');

  /// В момент события.
  static const EventReminder atEvent = EventReminder.before(0);

  /// Минуты до вхождения; `null` у «не напоминать».
  final int? minutes;

  bool get isNone => minutes == null;

  /// Значение для поля `reminders` запроса.
  List<int> toWire() => [?minutes];

  /// Значение из поля `reminders` ответа; `null` — не задано.
  static EventReminder? fromWire(List<int>? wire) {
    if (wire == null) {
      return null;
    }

    return wire.isEmpty ? const EventReminder.none() : EventReminder.before(wire.first);
  }

  @override
  List<Object?> get props => [minutes];
}
