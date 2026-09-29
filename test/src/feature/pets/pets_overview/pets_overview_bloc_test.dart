import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/breed_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/pets_remote_data_source.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/pets_overview/domain/pets_overview_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';

class _FakePetsDataSource implements PetsRemoteDataSource {
  @override
  Future<List<PetDto>> getPets() async => [
    PetDto(
      id: 1,
      petType: PetTypeEnum.dog,
      name: 'Чарли',
      breed: const BreedDto(id: 1, name: 'Корги'),
      gender: 'male',
      birthday: DateTime(2024),
      color: 'рыжий',
      image: 'https://example.com/1.jpg',
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
      weight: 14.9,
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeScheduleDataSource implements ScheduleRemoteDataSource {
  _FakeScheduleDataSource({this.fail = false});

  final bool fail;

  @override
  Future<ScheduleEventDtoList> getScheduleEvents({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
  }) async {
    if (fail) {
      throw Exception('schedule is down');
    }

    return {
      startDate: [
        ScheduleEventDto(
          id: 'e1',
          petId: 1,
          title: 'Прогулка в парке',
          type: ScheduleEventTypeEnum.walking,
          done: false,
          date: startDate,
        ),
      ],
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PetsOverviewBloc _bloc({bool scheduleFails = false}) => PetsOverviewBloc(
  petRepository: PetRepository(petsRemoteDataSource: _FakePetsDataSource()),
  scheduleRepository: ScheduleRepository(
    scheduleRemoteDataSource: _FakeScheduleDataSource(fail: scheduleFails),
  ),
);

void main() {
  test('собирает питомцев, число дел сегодня и ближайшее событие в одном объекте', () async {
    final bloc = _bloc()..add(const PetsOverviewEvent.fetchRequested());

    final state = await bloc.stream.firstWhere((state) => state is PetsOverviewState$Success);
    final overview = (state as PetsOverviewState$Success).overview;

    expect(overview.pets.single.pet.name, 'Чарли');
    expect(overview.pets.single.pet.weight, 14.9);
    expect(overview.todayEventsCount, 1);
    expect(overview.pets.single.nextEvent?.event.title, 'Прогулка в парке');

    await bloc.close();
  });

  test('ошибка расписания не ломает список питомцев', () async {
    final bloc = _bloc(scheduleFails: true)..add(const PetsOverviewEvent.fetchRequested());

    final state = await bloc.stream.firstWhere((state) => state is! PetsOverviewState$Loading);

    expect(state, isA<PetsOverviewState$Success>());

    final overview = (state as PetsOverviewState$Success).overview;

    expect(overview.pets, hasLength(1));
    expect(overview.todayEventsCount, isNull);
    expect(overview.pets.single.nextEvent, isNull);

    await bloc.close();
  });
}
