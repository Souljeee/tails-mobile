import 'package:shared_preferences/shared_preferences.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/persisted_entry.dart';

/// Запоминает, что пользователь уже видел подсказку о двух зонах на карточке события.
class ScheduleHintStore {
  /// [entry] подменяют в тестах; по умолчанию значение лежит в `SharedPreferences`.
  ScheduleHintStore({PersistedEntry<bool>? entry})
    : _entry =
          entry ??
          BoolPreferencesEntry(
            sharedPreferences: SharedPreferencesAsync(),
            key: 'schedule_two_zones_hint_seen',
          );

  final PersistedEntry<bool> _entry;

  /// Подсказка уже закрыта. При сбое хранилища считаем, что закрыта: лучше промолчать, чем
  /// показывать её при каждом запуске.
  Future<bool> isSeen() async {
    try {
      return await _entry.read() ?? false;
    } catch (e, s) {
      TailsLogger.warning(
        'Не удалось прочитать флаг подсказки',
        source: 'ScheduleHintStore',
        error: e,
        stackTrace: s,
      );

      return true;
    }
  }

  Future<void> markSeen() async {
    try {
      await _entry.set(true);
    } catch (e, s) {
      // Не удалось сохранить: подсказка просто покажется ещё раз.
      TailsLogger.warning(
        'Не удалось сохранить флаг подсказки',
        source: 'ScheduleHintStore',
        error: e,
        stackTrace: s,
      );
    }
  }
}
