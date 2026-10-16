import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/event_type_rules.dart';

/// Поля формы, которые пользователь мог изменить при редактировании.
enum EditedField { title, description, type, time, date, pet, recurrence }

/// Что изменено в форме относительно редактируемого вхождения.
///
/// «Только эта дата» принимает лишь [overridable] поля: название, описание, тип и время. Если
/// тронуты дата, питомец или повторение, остаётся область «эта дата и все следующие».
class EditChanges extends Equatable {
  const EditChanges(this.fields);

  /// Сравнивает форму [edited] с вхождением [original]. [originalTime] — время, с которым
  /// форма была открыта (`HH:mm` либо `null`).
  factory EditChanges.compare({
    required ScheduleEventModel original,
    required CreateEventModel edited,
    required String? originalTime,
  }) {
    String normalized(String? value) => (value ?? '').trim();

    return EditChanges({
      if (normalized(original.title) != normalized(edited.title)) EditedField.title,
      if (normalized(original.description) != normalized(edited.description))
        EditedField.description,
      if (EventTypeRules.pickerType(original.type) != EventTypeRules.pickerType(edited.type))
        EditedField.type,
      if (normalized(originalTime) != normalized(edited.time)) EditedField.time,
      if (!_sameDay(original.date, edited.date)) EditedField.date,
      if (original.petId != edited.petId) EditedField.pet,
      if (original.recurrence != edited.recurrence) EditedField.recurrence,
    });
  }

  /// Поля, которые можно переопределить на одно вхождение.
  static const Set<EditedField> overridable = {
    EditedField.title,
    EditedField.description,
    EditedField.type,
    EditedField.time,
  };

  final Set<EditedField> fields;

  bool get isEmpty => fields.isEmpty;

  /// Вариант «Только {дата}» доступен.
  bool get allowsSingleOccurrence => fields.every(overridable.contains);

  /// Изменено повторение или дата: отмены дат, которых нет в новом расписании, сбросятся.
  bool get changesSchedule =>
      fields.contains(EditedField.recurrence) || fields.contains(EditedField.date);

  /// У серии с окончанием «после N повторений» N заменяется остатком с выбранной даты:
  /// [past] событий уже прошло и в новую серию не входят.
  static RecurrenceModel? withRemainingCount(RecurrenceModel? rule, {required int past}) {
    if (rule == null) {
      return null;
    }

    final end = rule.end;
    if (end is! RecurrenceEnd$AfterCount) {
      return rule;
    }

    final remaining = end.count - past;

    return RecurrenceModel(
      period: rule.period,
      interval: rule.interval,
      weekDays: rule.weekDays,
      monthDays: rule.monthDays,
      yearDates: rule.yearDates,
      times: rule.times,
      end: RecurrenceEnd.afterCount(remaining < 1 ? 1 : remaining),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  List<Object?> get props => [fields];
}
