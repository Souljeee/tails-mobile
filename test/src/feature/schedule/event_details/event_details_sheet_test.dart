import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/series_stats.dart';
import 'package:tails_mobile/src/feature/schedule/event_details/presentation/event_details_sheet.dart';

import '../../../../helpers/ui_test_app.dart';

ScheduleEventModel _event({
  bool done = false,
  bool cancelled = false,
  bool recurring = false,
  DateTime? doneAt,
}) => ScheduleEventModel(
  id: 'e1',
  petId: 1,
  title: 'Таблетки',
  description: 'После еды',
  type: ScheduleEventTypeEnum.dailyPills,
  done: done,
  cancelled: cancelled,
  doneAt: doneAt,
  date: DateTime(2026, 10, 20),
  time: '17:05:00',
  recurrence: recurring ? const RecurrenceModel(period: RecurrencePeriod.day) : null,
);

SeriesStats _stats({int? remaining = 335, int past = 30, bool openEnded = false}) => SeriesStats(
  remaining: remaining,
  past: past,
  seriesEnd: null,
  isOpenEnded: openEnded,
  cancelledDates: const [],
);

void main() {
  setUpAll(() => initializeDateFormatting('ru'));

  EventDetailsResult? result;

  Future<void> pump(
    WidgetTester tester,
    ScheduleEventModel event, {
    Future<SeriesStats> Function()? loadStats,
  }) async {
    result = null;

    await tester.pumpWidget(
      uiTestApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showEventDetailsSheet(
                context: context,
                occurrence: event,
                loadStats: loadStats ?? () async => _stats(),
                petName: 'Мистерио',
                now: DateTime(2026, 10, 16),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('запланированное: шапка, строки и кнопки «Изменить» и отмены', (tester) async {
    await pump(tester, _event());

    expect(find.text('Таблетки'), findsOneWidget);
    expect(find.text('Запланировано'), findsOneWidget);
    expect(find.text('Вт, 20 октября, 17:05'), findsOneWidget);
    expect(find.text('Не повторяется'), findsOneWidget);
    expect(find.text('Мистерио', findRichText: true), findsNothing);
    expect(find.textContaining('Мистерио'), findsOneWidget);
    expect(find.text('Отменить событие'), findsOneWidget);
    expect(find.text('Снять отметку'), findsNothing);
    expect(find.text('Изменить'), findsOneWidget);
  });

  testWidgets('«Изменить» закрывает шит с результатом Edit', (tester) async {
    await pump(tester, _event());

    await tester.tap(find.text('Изменить'));
    await tester.pumpAndSettle();

    expect(result, isA<EventDetailsResult$Edit>());
  });

  testWidgets('выполненное: время отметки, «Снять отметку», без отмены', (tester) async {
    await pump(tester, _event(done: true, doneAt: DateTime(2026, 10, 20, 9, 12)));

    expect(find.text('Выполнено в 09:12'), findsOneWidget);
    expect(find.text('Отменить событие'), findsNothing);

    await tester.tap(find.text('Снять отметку'));
    await tester.pumpAndSettle();

    expect(result, isA<EventDetailsResult$Unmark>());
  });

  testWidgets('отменённое одиночное событие можно вернуть', (tester) async {
    await pump(tester, _event(cancelled: true));

    expect(find.text('Отменено'), findsOneWidget);

    await tester.tap(find.text('Вернуть в расписание'));
    await tester.pumpAndSettle();

    expect(result, isA<EventDetailsResult$Restore>());
  });

  testWidgets('отменённое вхождение серии: действий нет', (tester) async {
    await pump(tester, _event(cancelled: true, recurring: true));

    expect(find.text('Вернуть в расписание'), findsNothing);
    expect(find.text('Отменить событие'), findsNothing);
  });

  testWidgets('одиночное событие: отмена в два шага', (tester) async {
    await pump(tester, _event());

    await tester.tap(find.text('Отменить событие'));
    await tester.pumpAndSettle();

    expect(find.text('Отменить событие?'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text('Отменить событие'));
    await tester.pumpAndSettle();

    expect((result! as EventDetailsResult$Cancel).scope, OccurrenceScope.one);
  });

  testWidgets('кнопка «Назад» возвращает к деталям', (tester) async {
    await pump(tester, _event());

    await tester.tap(find.text('Отменить событие'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Запланировано'), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('серия: выбор области, число событий на кнопке', (tester) async {
    await pump(tester, _event(recurring: true));

    await tester.tap(find.text('Отменить событие'));
    await tester.pumpAndSettle();

    expect(find.text('Только 20 октября'), findsOneWidget);
    expect(find.text('20 октября и все следующие'), findsOneWidget);
    expect(find.text('Отменить событие'), findsOneWidget);

    await tester.tap(find.text('20 октября и все следующие'));
    await tester.pumpAndSettle();

    expect(find.text('Отменить 335 событий'), findsOneWidget);
    expect(find.text('Сохранятся 30 прошедших событий'), findsOneWidget);

    await tester.tap(find.text('Отменить 335 событий'));
    await tester.pumpAndSettle();

    expect((result! as EventDetailsResult$Cancel).scope, OccurrenceScope.future);
  });

  testWidgets('бессрочная серия: число не показывается', (tester) async {
    await pump(
      tester,
      _event(recurring: true),
      loadStats: () async => _stats(remaining: null, openEnded: true),
    );

    await tester.tap(find.text('Отменить событие'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20 октября и все следующие'));
    await tester.pumpAndSettle();

    expect(find.text('Отменить это и все следующие'), findsOneWidget);
    expect(find.text('Серия закончится на этой дате'), findsOneWidget);
  });

  testWidgets('последнее событие серии: выбора области нет', (tester) async {
    await pump(
      tester,
      _event(recurring: true),
      loadStats: () async => _stats(remaining: 1, past: 5),
    );

    await tester.tap(find.text('Отменить событие'));
    await tester.pumpAndSettle();

    expect(find.text('Только 20 октября'), findsNothing);
    expect(find.textContaining('последнее событие серии'), findsOneWidget);

    await tester.tap(find.text('Отменить событие'));
    await tester.pumpAndSettle();

    expect((result! as EventDetailsResult$Cancel).scope, OccurrenceScope.one);
  });

  testWidgets('ошибка загрузки сводки: сообщение и повтор', (tester) async {
    var calls = 0;

    await pump(
      tester,
      _event(recurring: true),
      loadStats: () async {
        calls++;
        if (calls == 1) {
          throw Exception('down');
        }

        return _stats();
      },
    );

    await tester.tap(find.text('Отменить событие'));
    await tester.pumpAndSettle();

    expect(find.text('Не удалось узнать, сколько событий в серии'), findsOneWidget);

    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();

    expect(find.text('Только 20 октября'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('пока сводка грузится, виден индикатор', (tester) async {
    final completer = Completer<SeriesStats>();

    await pump(tester, _event(recurring: true), loadStats: () => completer.future);
    await tester.tap(find.text('Отменить событие'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
