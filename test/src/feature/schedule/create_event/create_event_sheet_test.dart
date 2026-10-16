import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';
import 'package:tails_mobile/src/feature/initialization/model/dependencies_container.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/create_schedule_event_bottom_sheet.dart';

class _FakeScheduleRepository extends Fake implements ScheduleRepository {
  final created = <CreateEventModel>[];

  @override
  Future<void> createEvent({required CreateEventModel model}) async => created.add(model);
}

base class _Dependencies extends TestDependenciesContainer {
  const _Dependencies(this._repository);

  final ScheduleRepository _repository;

  @override
  ScheduleRepository get scheduleRepository => _repository;
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

  Future<void> pumpSheet(WidgetTester tester) async {
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
              date: DateTime(2026, 10, 5),
              pets: [pet],
              selectedPetId: pet.id,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickType(WidgetTester tester, String title) async {
    await tester.tap(
      find.text('Выберите тип').evaluate().isNotEmpty
          ? find.text('Выберите тип')
          : find.byIcon(Icons.chevron_right_rounded).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(title));
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  VoidCallback? submit(WidgetTester tester) =>
      tester.widget<UiButton>(find.byType(UiButton)).onPressed;

  String titleText(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText).first).controller.text;

  setUp(() => repository = _FakeScheduleRepository());

  testWidgets('тип не выбран: «Выберите тип», кнопка «Создать» неактивна', (tester) async {
    await pumpSheet(tester);

    expect(find.text('Тип события'), findsOneWidget);
    expect(find.text('Выберите тип'), findsOneWidget);
    expect(submit(tester), isNull);
  });

  testWidgets('выбор типа открывает список по группам и сразу возвращает к форме', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Выберите тип'));
    await tester.pumpAndSettle();

    expect(find.text('ЗДОРОВЬЕ'), findsOneWidget);
    expect(find.text('Визит к ветеринару'), findsOneWidget);
    expect(find.text('Осмотр, анализы, процедуры'), findsOneWidget);
    expect(find.text('Приём лекарств'), findsOneWidget);
    expect(find.text('УХОД'), findsOneWidget);

    await tester.tap(find.text('Купание'));
    await tester.pumpAndSettle();

    expect(find.text('Новое событие'), findsOneWidget);
    expect(find.text('Выберите тип'), findsNothing);
    expect(titleText(tester), 'Купание');
    expect(find.text('Подставлено из типа · можно изменить'), findsOneWidget);
    expect(submit(tester), isNotNull);
  });

  testWidgets('выход из списка без выбора ничего не меняет', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Выберите тип'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Выберите тип'), findsOneWidget);
    expect(titleText(tester), isEmpty);
    expect(submit(tester), isNull);
  });

  testWidgets('смена типа заменяет подставленное название', (tester) async {
    await pumpSheet(tester);

    await pickType(tester, 'Купание');
    await pickType(tester, 'Прогулка');

    expect(titleText(tester), 'Прогулка');
  });

  testWidgets('своё название при смене типа сохраняется, «Заменить» подставляет новое', (
    tester,
  ) async {
    await pumpSheet(tester);

    await pickType(tester, 'Купание');
    await tester.enterText(find.byType(EditableText).first, 'Мытьё лап');
    await tester.pump();
    await pickType(tester, 'Прогулка');

    expect(titleText(tester), 'Мытьё лап');
    expect(find.text('Тип изменён. Назвать «Прогулка»?'), findsOneWidget);

    await tester.tap(find.text('Заменить'));
    await tester.pumpAndSettle();

    expect(titleText(tester), 'Прогулка');
    expect(find.text('Заменить'), findsNothing);
  });

  testWidgets('«Другое» очищает подставленное название и делает его обязательным', (tester) async {
    await pumpSheet(tester);

    await pickType(tester, 'Купание');
    await pickType(tester, 'Другое');

    expect(titleText(tester), isEmpty);
    expect(find.text('Для типа «Другое» название обязательно'), findsOneWidget);

    await tester.tap(find.byType(UiButton));
    await tester.pumpAndSettle();

    expect(find.text('Введите название'), findsOneWidget);
    expect(repository.created, isEmpty);
  });

  testWidgets('лекарства подставляют «Каждый день» и уходят как dailyPills', (tester) async {
    await pumpSheet(tester);

    await pickType(tester, 'Приём лекарств');

    expect(find.text('Каждый день'), findsOneWidget);
    expect(find.text('Подставлено по типу'), findsOneWidget);

    await tester.tap(find.byType(UiButton));
    await tester.pumpAndSettle();

    final model = repository.created.single;
    expect(model.type, ScheduleEventTypeEnum.dailyPills);
    expect(model.recurrence?.period, RecurrencePeriod.day);
  });

  testWidgets('плановая вакцинация подставляет повторение раз в год', (tester) async {
    await pumpSheet(tester);

    await pickType(tester, 'Плановая вакцинация');

    expect(find.text('5 октября каждого года'), findsOneWidget);
    expect(find.text('Подставлено по типу'), findsOneWidget);

    await tester.tap(find.byType(UiButton));
    await tester.pumpAndSettle();

    final model = repository.created.single;
    expect(model.type, ScheduleEventTypeEnum.yearlyVaccination);
    expect(model.recurrence?.period, RecurrencePeriod.year);
  });

  testWidgets('подстановка снимается при смене типа, если повторение не настраивали', (
    tester,
  ) async {
    await pumpSheet(tester);

    await pickType(tester, 'Приём лекарств');
    await pickType(tester, 'Прогулка');

    expect(find.text('Не повторять'), findsOneWidget);
    expect(find.text('Подставлено по типу'), findsNothing);

    await tester.tap(find.byType(UiButton));
    await tester.pumpAndSettle();

    expect(repository.created.single.type, ScheduleEventTypeEnum.walking);
    expect(repository.created.single.recurrence, isNull);
  });
}
