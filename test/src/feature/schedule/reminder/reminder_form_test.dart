import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/notifications/notification_permission_data_source.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';
import 'package:tails_mobile/src/feature/initialization/model/dependencies_container.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/create_schedule_event_bottom_sheet.dart';

class _FakeScheduleRepository extends Fake implements ScheduleRepository {
  final created = <CreateEventModel>[];

  @override
  Future<void> createEvent({required CreateEventModel model}) async => created.add(model);
}

class _FakePermission implements NotificationPermissionDataSource {
  _FakePermission({this.blocked = false});

  bool blocked;
  int enableCalls = 0;

  @override
  Future<bool> isBlockedBySystem() async => blocked;

  @override
  Future<bool> openSettings() async => true;

  @override
  Future<bool> enable() async {
    enableCalls++;
    blocked = false;

    return true;
  }
}

base class _Dependencies extends TestDependenciesContainer {
  const _Dependencies(this._repository, this._permission);

  final ScheduleRepository _repository;
  final NotificationPermissionDataSource _permission;

  @override
  ScheduleRepository get scheduleRepository => _repository;

  @override
  NotificationPermissionDataSource get notificationPermissionDataSource => _permission;
}

void main() {
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
  late _FakePermission permission;

  setUp(() {
    repository = _FakeScheduleRepository();
    permission = _FakePermission();
  });

  Future<void> pumpSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      DependenciesScope(
        dependencies: _Dependencies(repository, permission),
        child: MaterialApp(
          theme: UiThemeData.lightTheme,
          locale: const Locale('ru'),
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: CreateScheduleEventBottomSheet(
                // Вторник, событие в будущем: время напоминания ещё не прошло.
                date: DateTime(2030, 10, 15),
                pets: [pet],
                selectedPetId: pet.id,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  Future<void> pickType(WidgetTester tester, String title) async {
    await tapText(tester, 'Выберите тип');
    await tapText(tester, title);
  }

  Future<void> back(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
  }

  testWidgets('без времени — «В день события в 09:00», после типа — «Подобрано по типу»', (
    tester,
  ) async {
    await pumpSheet(tester);

    expect(find.text('Напоминание'), findsOneWidget);
    expect(find.text('В день события в 09:00'), findsOneWidget);
    expect(find.text('Придёт в 09:00'), findsOneWidget);

    await pickType(tester, 'Визит к ветеринару');

    expect(find.text('Подобрано по типу · придёт в 09:00'), findsOneWidget);
  });

  testWidgets('выбор варианта сразу обновляет карточку, «Назад» — значение в форме', (
    tester,
  ) async {
    await pumpSheet(tester);
    await pickType(tester, 'Прогулка');

    await tapText(tester, 'В день события в 09:00');
    expect(find.text('Не напоминать'), findsOneWidget);
    expect(find.text('Своё время'), findsOneWidget);

    await tapText(tester, 'Накануне в 09:00');
    expect(find.text('пн, 14 окт. в 09:00'), findsWidgets);

    await back(tester);
    expect(find.text('Накануне в 09:00'), findsOneWidget);
    expect(find.text('Придёт в пн, 14 окт. в 09:00'), findsOneWidget);

    await tester.tap(find.byType(UiButton));
    await tester.pumpAndSettle();

    expect(repository.created.single.reminder, const EventReminder.before(1440));
  });

  testWidgets('выбранное вручную не меняется при смене типа', (tester) async {
    await pumpSheet(tester);
    await pickType(tester, 'Прогулка');

    await tapText(tester, 'В день события в 09:00');
    await tapText(tester, 'Не напоминать');
    await back(tester);
    expect(find.text('Уведомление об этом событии не придёт'), findsOneWidget);

    await tester.ensureVisible(find.text('Прогулка').first);
    await tester.tap(find.text('Прогулка').first);
    await tester.pumpAndSettle();
    await tapText(tester, 'Купание');

    expect(find.text('Не напоминать'), findsOneWidget);
  });

  testWidgets('своё время: «Готово» возвращает в список с выбранным значением', (tester) async {
    await pumpSheet(tester);
    await pickType(tester, 'Прогулка');

    await tapText(tester, 'В день события в 09:00');
    await tapText(tester, 'Своё время');

    expect(find.text('Напомнить за'), findsOneWidget);
    expect(find.text('За 3 дня'), findsOneWidget);
    expect(find.text('Минуты'), findsNothing);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(find.text('За 4 дня'), findsOneWidget);

    await tapText(tester, 'Готово');
    expect(find.text('Не напоминать'), findsOneWidget);
    expect(find.text('За 4 дня'), findsOneWidget);

    await back(tester);
    expect(find.text('За 4 дня'), findsOneWidget);

    await tester.tap(find.byType(UiButton));
    await tester.pumpAndSettle();
    expect(repository.created.single.reminder, const EventReminder.before(4 * 1440));
  });

  testWidgets('«Выбрать из готовых вариантов» не сохраняет своё значение', (tester) async {
    await pumpSheet(tester);

    await tapText(tester, 'В день события в 09:00');
    await tapText(tester, 'Своё время');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tapText(tester, 'Выбрать из готовых вариантов');

    expect(find.text('Своё время'), findsOneWidget);
    expect(find.text('Например, за 3 часа или за 3 дня'), findsOneWidget);
  });

  testWidgets('уведомления выключены: подсказка с «Включить», после включения — обычная строка', (
    tester,
  ) async {
    permission.blocked = true;
    await pumpSheet(tester);

    expect(
      find.text('Уведомления выключены в настройках телефона — напоминание не придёт.'),
      findsOneWidget,
    );

    await tapText(tester, 'Включить');

    expect(permission.enableCalls, 1);
    expect(find.text('Придёт в 09:00'), findsOneWidget);
  });

  testWidgets('«Не напоминать» убирает предупреждение о выключенных уведомлениях', (tester) async {
    permission.blocked = true;
    await pumpSheet(tester);

    await tapText(tester, 'В день события в 09:00');
    await tapText(tester, 'Не напоминать');
    await back(tester);

    expect(find.text('Включить'), findsNothing);
    expect(find.text('Уведомление об этом событии не придёт'), findsOneWidget);
  });
}
