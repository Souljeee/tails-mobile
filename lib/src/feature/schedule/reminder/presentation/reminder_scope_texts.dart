import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_texts.dart';

/// Тексты шага «Сохранить изменения», когда у серии изменено только напоминание.
class ReminderScopeTexts {
  const ReminderScopeTexts({
    required this.question,
    required this.oneHint,
    required this.futureHint,
  });

  factory ReminderScopeTexts.of(
    AppLocalizations l10n, {
    required EventReminder reminder,
    required EventReminder previous,
    required bool allDay,
  }) {
    final texts = ReminderTexts(l10n);
    final value = lowerFirst(texts.label(reminder, allDay: allDay));
    final old = lowerFirst(texts.label(previous, allDay: allDay));

    return ReminderScopeTexts(
      question: l10n.reminderScopeQuestion(value),
      oneHint: reminder.isNone
          ? l10n.reminderScopeOneHintNone(old)
          : l10n.reminderScopeOneHint(value, old),
      futureHint: reminder.isNone
          ? l10n.reminderScopeFutureHintNone
          : l10n.reminderScopeFutureHint(value),
    );
  }

  /// «Новое напоминание «за 30 минут» — для каких событий?»
  final String question;

  /// Пояснение под «Только {дата}».
  final String oneHint;

  /// Пояснение под «{дата} и все следующие».
  final String futureHint;
}
