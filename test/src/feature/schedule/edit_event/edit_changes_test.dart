import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/edit_event/domain/edit_changes.dart';

void main() {
  final original = ScheduleEventModel(
    id: 'e1',
    petId: 1,
    title: 'Таблетки',
    description: 'После еды',
    type: ScheduleEventTypeEnum.dailyPills,
    done: false,
    date: DateTime(2026, 10, 20),
    time: '17:05:00',
    recurrence: const RecurrenceModel(period: RecurrencePeriod.day),
  );

  CreateEventModel form({
    String title = 'Таблетки',
    String? description = 'После еды',
    String? time = '17:05',
    DateTime? date,
    int petId = 1,
    RecurrenceModel? recurrence = const RecurrenceModel(period: RecurrencePeriod.day),
  }) => CreateEventModel(
    title: title,
    description: description,
    time: time,
    date: date ?? DateTime(2026, 10, 20),
    petId: petId,
    type: ScheduleEventTypeEnum.dailyPills,
    isRecurring: recurrence != null,
    recurrence: recurrence,
  );

  EditChanges compare(CreateEventModel edited) =>
      EditChanges.compare(original: original, edited: edited, originalTime: '17:05');

  test('без правок изменений нет', () {
    expect(compare(form()).isEmpty, isTrue);
  });

  test('пробелы по краям названия и описания не считаются правкой', () {
    expect(compare(form(title: ' Таблетки ', description: 'После еды ')).isEmpty, isTrue);
  });

  test('название, описание и время можно переопределить на одно вхождение', () {
    final changes = compare(form(title: 'Другое', description: null, time: '18:00'));

    expect(changes.fields, {EditedField.title, EditedField.description, EditedField.time});
    expect(changes.allowsSingleOccurrence, isTrue);
    expect(changes.changesSchedule, isFalse);
  });

  test('дата, питомец и повторение требуют области «и все следующие»', () {
    for (final edited in [
      form(date: DateTime(2026, 10, 21)),
      form(petId: 2),
      form(recurrence: const RecurrenceModel(period: RecurrencePeriod.week)),
    ]) {
      expect(compare(edited).allowsSingleOccurrence, isFalse);
    }
  });

  test('изменение даты или повторения меняет расписание', () {
    expect(compare(form(date: DateTime(2026, 10, 21))).changesSchedule, isTrue);
    expect(compare(form(recurrence: null)).changesSchedule, isTrue);
    expect(compare(form(title: 'x')).changesSchedule, isFalse);
  });

  test('withRemainingCount вычитает прошедшие и не опускается ниже 1', () {
    const rule = RecurrenceModel(period: RecurrencePeriod.day, end: RecurrenceEnd.afterCount(10));

    expect(EditChanges.withRemainingCount(rule, past: 3)?.end, const RecurrenceEnd.afterCount(7));
    expect(EditChanges.withRemainingCount(rule, past: 20)?.end, const RecurrenceEnd.afterCount(1));
  });
}
