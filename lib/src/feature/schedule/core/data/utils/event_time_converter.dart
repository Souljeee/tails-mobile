/// Перевод времени события между локальным (то, что видит пользователь) и UTC (то, что ждёт API).
///
/// API принимает и отдаёт время в UTC вместе со смещением `timezone_offset` (минуты) события.
/// Дата события всегда локальная и не сдвигается — меняется только время суток, поэтому
/// переход через полночь сохраняет дату (01:00 в Москве — это 22:00 UTC предыдущих суток).
///
/// Класс без зависимостей от Flutter: форматы — `HH:mm` на вход и выход, `HH:mm:ss` принимается.
abstract final class EventTimeConverter {
  static const _minutesInDay = 24 * 60;

  /// Локальное `HH:mm` → UTC `HH:mm` при смещении [offsetMinutes].
  static String? localToUtc(String? local, {required int offsetMinutes}) =>
      _shift(local, -offsetMinutes);

  /// UTC `HH:mm[:ss]` → локальное `HH:mm` при смещении [offsetMinutes].
  static String? utcToLocal(String? utc, {required int offsetMinutes}) =>
      _shift(utc, offsetMinutes);

  /// Смещение устройства (минуты) на момент [date] + [time] (`HH:mm`); без времени — на полдень.
  ///
  /// Нужно, чтобы смещение соответствовало реальному моменту события, а не полуночи
  /// (разница видна только в день перехода на летнее время).
  static int deviceOffsetMinutes(DateTime date, {String? time}) {
    final parsed = _parse(time);
    final moment = DateTime(date.year, date.month, date.day, parsed?.$1 ?? 12, parsed?.$2 ?? 0);

    return moment.timeZoneOffset.inMinutes;
  }

  static String? _shift(String? value, int deltaMinutes) {
    final parsed = _parse(value);
    if (parsed == null) {
      return null;
    }

    final total = (parsed.$1 * 60 + parsed.$2 + deltaMinutes) % _minutesInDay;
    final hours = (total ~/ 60).toString().padLeft(2, '0');
    final minutes = (total % 60).toString().padLeft(2, '0');

    return '$hours:$minutes';
  }

  static (int, int)? _parse(String? value) {
    final text = value?.trim();
    if (text == null || text.length < 5) {
      return null;
    }

    final hours = int.tryParse(text.substring(0, 2));
    final minutes = int.tryParse(text.substring(3, 5));
    if (hours == null || minutes == null || hours > 23 || minutes > 59) {
      return null;
    }

    return (hours, minutes);
  }
}
