import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/domain/add_pet_bloc.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/add_pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/breed_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/edit_pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/pets_remote_data_source.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/edit_pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/delete_pet/domain/delete_pet_bloc.dart';
import 'package:tails_mobile/src/feature/pets/edit_pet/domain/edit_pet_bloc.dart';

import '../../../helpers/recording_analytics_sink.dart';

final class _FakeDataSource extends Fake implements PetsRemoteDataSource {
  List<PetDto> pets = [];
  Exception? error;

  @override
  Future<List<PetDto>> getPets() async => pets;

  @override
  Future<void> addPet({required AddPetDto dto, required String? imagePath}) async {
    if (error != null) throw error!;
  }

  @override
  Future<void> deletePet({required int id}) async {
    if (error != null) throw error!;
  }

  @override
  Future<void> editPet({
    required int id,
    required EditPetDto dto,
    required String? imagePath,
  }) async {
    if (error != null) throw error!;
  }
}

PetDto _pet(int id, PetTypeEnum type) => PetDto(
  id: id,
  petType: type,
  name: 'Барсик',
  breed: const BreedDto(id: 1, name: 'Метис или не знаю'),
  gender: 'M',
  birthday: DateTime(2020),
  color: 'рыжий',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 50));

AddPetEvent _add({bool mixed = false, File? image}) => AddPetEvent.addingRequested(
  name: 'Барсик',
  petType: PetTypeEnum.dog,
  breedId: 1,
  color: 'рыжий',
  weight: 5,
  gender: PetSexEnum.female,
  birthday: DateTime(2022, 6, 15),
  castration: true,
  image: image,
  isMixedBreed: mixed,
);

void main() {
  late RecordingAnalyticsSink sink;
  late _FakeDataSource dataSource;
  late PetRepository repository;

  setUp(() {
    sink = RecordingAnalyticsSink();
    TailsAnalytics.configure(sinks: [sink]);
    dataSource = _FakeDataSource();
    repository = PetRepository(petsRemoteDataSource: dataSource);
  });

  tearDown(TailsAnalytics.reset);

  test('getPets обновляет свойства пользователя', () async {
    dataSource.pets = [
      _pet(1, PetTypeEnum.dog),
      _pet(2, PetTypeEnum.dog),
      _pet(3, PetTypeEnum.cat),
    ];

    await repository.getPets();
    await _pump();

    expect(repository.knownPetsCount, 3);
    expect(sink.properties[TailsAnalyticsUserProperty.petsCount], 3);
    expect(sink.properties[TailsAnalyticsUserProperty.dogsCount], 2);
    expect(sink.properties[TailsAnalyticsUserProperty.catsCount], 1);
  });

  group('AddPetBloc', () {
    test('первый питомец: pet_created с бакетами и без личных данных', () async {
      dataSource.pets = [];
      await repository.getPets();
      final bloc = AddPetBloc(petRepository: repository);
      addTearDown(bloc.close);

      await withClock(Clock.fixed(DateTime(2026, 10, 6)), () async {
        bloc.add(_add(mixed: true));
        await _pump();
      });

      final event = sink.events.single;
      expect(event.name, 'pet_created');
      expect(event.parameters, {
        'pet_type': 'dog',
        'sex': 'female',
        'is_mixed': true,
        'has_photo': false,
        'is_castrated': true,
        'age_bucket': '4-7',
        'pets_count': '1',
        'is_first_pet': true,
      });
      expect('$event', isNot(contains('Барсик')));
      expect(repository.knownPetsCount, 1);
    });

    test('второй питомец: is_first_pet = false, счётчик в корзине 2-3', () async {
      dataSource.pets = [_pet(1, PetTypeEnum.cat)];
      await repository.getPets();
      final bloc = AddPetBloc(petRepository: repository);
      addTearDown(bloc.close);

      bloc.add(_add());
      await _pump();

      expect(sink.events.single.parameters['is_first_pet'], false);
      expect(sink.events.single.parameters['pets_count'], '2-3');
    });

    test('если список не загружали, счётчик и is_first_pet не передаются', () async {
      final bloc = AddPetBloc(petRepository: repository);
      addTearDown(bloc.close);

      bloc.add(_add());
      await _pump();

      expect(sink.events.single.parameters.containsKey('pets_count'), isFalse);
      expect(sink.events.single.parameters.containsKey('is_first_pet'), isFalse);
    });

    test('ошибка: pet_create_failed', () async {
      dataSource.error = Exception('x');
      final bloc = AddPetBloc(petRepository: repository);
      addTearDown(bloc.close);

      bloc.add(_add());
      await _pump();

      expect(sink.names, ['pet_create_failed']);
      expect(sink.events.single.parameters, {'reason': 'unknown'});
    });
  });

  group('EditPetBloc', () {
    test('pet_updated содержит список изменённых полей', () async {
      final bloc = EditPetBloc(petRepository: repository);
      addTearDown(bloc.close);

      bloc.add(
        const EditPetEvent.editingRequested(
          petId: 1,
          pet: EditPetModel(petType: PetTypeEnum.cat),
          image: null,
          changedFields: ['name', 'weight'],
        ),
      );
      await _pump();

      expect(sink.events.single.name, 'pet_updated');
      expect(sink.events.single.parameters, {'changed': 'name,weight', 'pet_type': 'cat'});
    });
  });

  group('DeletePetBloc', () {
    test('успех и ошибка', () async {
      final bloc = DeletePetBloc(petRepository: repository);
      addTearDown(bloc.close);

      bloc.add(const DeletePetEvent.deleteRequested(id: 1));
      await _pump();
      dataSource.error = Exception('x');
      bloc.add(const DeletePetEvent.deleteRequested(id: 1));
      await _pump();

      expect(sink.names, ['pet_deleted', 'pet_delete_failed']);
    });
  });
}
