import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/feature/initialization/model/dependencies_container.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/edit_occurrence_result.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_occurrence_ref.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/series_stats.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/create_schedule_event_bottom_sheet.dart';

class _FakeScheduleRepository extends Fake implements ScheduleRepository {
  final calls = <String>[];

  @override
  Future<SeriesStats> getSeriesStats(EventOccurrenceRef ref) async => const SeriesStats(
    remaining: 10,
    past: 2,
    seriesEnd: null,
    isOpenEnded: true,
    cancelledDates: [],
  );

  @override
  Future<EditOccurrenceResult> editOccurrenceFields(
    EventOccurrenceRef ref, {
    String? title,
    String? description,
    ScheduleEventTypeEnum? type,
    String? time,
    CopyWithWrapper<EventReminder?>? reminder,
  }) async {
    calls.add('one:${title ?? '-'}');

    return EditOccurrenceResult(event: _occurrence(recurring: true));
  }

  @override
  Future<EditOccurrenceResult> editOccurrenceAndFollowing(
    EventOccurrenceRef ref,
    CreateEventModel model,
  ) async {
    calls.add('future:${model.title}');

    return EditOccurrenceResult(event: _occurrence(recurring: false));
  }
}

base class _Dependencies extends TestDependenciesContainer {
  const _Dependencies(this._repository);

  final ScheduleRepository _repository;

  @override
  ScheduleRepository get scheduleRepository => _repository;
}

ScheduleEventModel _occurrence({required bool recurring}) => ScheduleEventModel(
  id: 'e1',
  petId: 1,
  title: 'Таблетки',
  description: 'После еды',
  type: ScheduleEventTypeEnum.dailyPills,
  done: false,
  date: DateTime(2026, 10, 20),
  time: '17:05:00',
  recurrence: recurring ? const RecurrenceModel(period: RecurrencePeriod.day) : null,
);

void main() {
  setUpAll(() => initializeDateFormatting('ru'));

  final pet = PetModel(
    id: 1,
    petType: PetTypeEnum.cat,
    name: 'Мурка',
    breed: const BreedModel(id: 1, name: 'Метис'),
    gender: 'F',
    birthday: DateTime(2020),
    color: 'gray',
    createdAt: DateTime(2020),
    updatedAt: DateTime(2020),
  );

  late _FakeScheduleRepository repository;

  Future<void> pumpSheet(WidgetTester tester, {required bool recurring}) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      DependenciesScope(
        dependencies: _Dependencies(repository),
        child: MaterialApp(
          theme: UiThemeData.lightTheme,
          locale: const Locale('ru'),
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          home: Scaffold(
            body: CreateScheduleEventBottomSheet(
              date: DateTime(2026, 10, 20),
              pets: [pet],
              editing: _occurrence(recurring: recurring),
            ),
          ),
        ),
      ),
    );
  }

  VoidCallback? submit(WidgetTester tester) =>
      tester.widget<UiButton>(find.byType(UiButton)).onPressed;

  Future<void> editTitle(WidgetTester tester) async {
    await tester.enterText(find.byType(EditableText).first, 'Новые таблетки');
    await tester.pump();
  }

  setUp(() => repository = _FakeScheduleRepository());

  testWidgets('форма открывается заполненной значениями события', (tester) async {
    await pumpSheet(tester, recurring: false);

    expect(find.text('Редактирование'), findsOneWidget);
    expect(find.text('Сохранить изменения'), findsOneWidget);
    expect(find.text('Таблетки'), findsWidgets);
    expect(find.text('После еды'), findsOneWidget);
  });

  testWidgets('одиночное событие сохраняется сразу, без выбора области', (tester) async {
    await pumpSheet(tester, recurring: false);
    await editTitle(tester);

    submit(tester)!.call();
    await tester.pumpAndSettle();

    expect(repository.calls, ['future:Новые таблетки']);
    expect(find.text('К каким событиям применить изменения?'), findsNothing);
  });

  testWidgets('серия: выбор области, «Только эта дата» отправляет изменённые поля', (tester) async {
    await pumpSheet(tester, recurring: true);
    await editTitle(tester);

    submit(tester)!.call();
    await tester.pumpAndSettle();

    expect(find.text('К каким событиям применить изменения?'), findsOneWidget);
    expect(find.text('Только 20 октября'), findsOneWidget);
    expect(find.text('20 октября и все следующие'), findsOneWidget);

    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(repository.calls, ['one:Новые таблетки']);
  });

  testWidgets('серия: «и все следующие» отправляет форму целиком', (tester) async {
    await pumpSheet(tester, recurring: true);
    await editTitle(tester);

    submit(tester)!.call();
    await tester.pumpAndSettle();
    await tester.tap(find.text('20 октября и все следующие'));
    await tester.pump();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(repository.calls, ['future:Новые таблетки']);
  });
}
