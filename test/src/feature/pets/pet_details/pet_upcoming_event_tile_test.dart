import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tails_mobile/src/feature/initialization/model/dependencies_container.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/pet_details/presentation/widgets/pet_upcoming_event_tile.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';

import '../../../../helpers/ui_test_app.dart';

class _FakeDataSource implements ScheduleRemoteDataSource {
  final calls = <String>[];

  @override
  Future<ScheduleEventDto> cancelOccurrence({
    required String eventId,
    required DateTime date,
    required OccurrenceScope scope,
    String? time,
  }) async {
    calls.add('cancel:$eventId:${scope.apiValue}');

    return ScheduleEventDto(
      id: eventId,
      petId: 1,
      title: 'Прививка',
      type: ScheduleEventTypeEnum.vetVisit,
      done: false,
      cancelled: true,
      date: date,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

base class _Dependencies extends TestDependenciesContainer {
  const _Dependencies(this._repository);

  final ScheduleRepository _repository;

  @override
  ScheduleRepository get scheduleRepository => _repository;
}

void main() {
  setUpAll(() => initializeDateFormatting('ru'));

  late _FakeDataSource dataSource;

  final event = ScheduleEventModel(
    id: 'e1',
    petId: 1,
    title: 'Прививка',
    type: ScheduleEventTypeEnum.vetVisit,
    done: false,
    date: DateTime.now().add(const Duration(days: 3)),
    time: '10:00:00',
  );

  Future<void> pump(WidgetTester tester) async {
    dataSource = _FakeDataSource();

    await tester.pumpWidget(
      DependenciesScope(
        dependencies: _Dependencies(ScheduleRepository(scheduleRemoteDataSource: dataSource)),
        child: uiTestApp(
          PetUpcomingEventTile(
            event: event,
            petImage: null,
            petType: PetTypeEnum.cat,
            petColor: Colors.green,
            pet: PetModel(
              id: 1,
              petType: PetTypeEnum.cat,
              name: 'Мурка',
              breed: const BreedModel(id: 1, name: 'Британская'),
              gender: 'F',
              birthday: DateTime(2020),
              color: 'green',
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> cancelViaSheet(WidgetTester tester) async {
    await tester.tap(find.text('Прививка'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отменить событие…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отменить событие'));
    await tester.pumpAndSettle();
  }

  testWidgets('тап по карточке открывает детали с именем питомца', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Прививка'));
    await tester.pumpAndSettle();

    expect(find.text('Запланировано'), findsOneWidget);
    expect(find.textContaining('Мурка'), findsOneWidget);
  });

  testWidgets('отмена скрывает карточку, а запрос уходит после снекбара', (tester) async {
    await pump(tester);

    await cancelViaSheet(tester);

    expect(find.text('Событие отменено'), findsOneWidget);
    expect(find.text('Прививка'), findsNothing);
    expect(dataSource.calls, isEmpty);

    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();

    expect(dataSource.calls, ['cancel:e1:one']);
  });

  testWidgets('«Вернуть» возвращает карточку и ничего не отправляет', (tester) async {
    await pump(tester);

    await cancelViaSheet(tester);
    await tester.tap(find.text('Вернуть'));
    await tester.pumpAndSettle();

    expect(find.text('Прививка'), findsOneWidget);

    await tester.pump(const Duration(seconds: 7));

    expect(dataSource.calls, isEmpty);
  });
}
