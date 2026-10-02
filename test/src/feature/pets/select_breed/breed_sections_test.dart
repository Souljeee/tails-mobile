import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/select_breed/domain/breed_sections.dart';

void main() {
  const breeds = [
    BreedModel(id: 3, name: 'Бигль'),
    BreedModel(id: 1, name: 'Метис или не знаю'),
    BreedModel(id: 2, name: 'Алабай'),
    BreedModel(id: 4, name: 'акита-ину'),
    BreedModel(id: 5, name: 'Боксер'),
  ];

  test('«Метис или не знаю» определяется по названию', () {
    expect(const BreedModel(id: 9, name: 'Метис или не знаю').isMixed, isTrue);
    expect(const BreedModel(id: 9, name: 'Метис или не знаю ').isMixed, isTrue);
    expect(const BreedModel(id: 9, name: 'Алабай').isMixed, isFalse);
  });

  test('метис закрепляется отдельно, остальные группируются по буквам по алфавиту', () {
    final listing = buildBreedsListing(breeds);

    expect(listing.mixed?.id, 1);
    expect(listing.letters, ['А', 'Б']);
    expect(listing.sections[0].breeds.map((b) => b.name), ['акита-ину', 'Алабай']);
    expect(listing.sections[1].breeds.map((b) => b.name), ['Бигль', 'Боксер']);
  });

  test('поиск фильтрует породы без учёта регистра и скрывает метиса, если он не подходит', () {
    final listing = buildBreedsListing(breeds, query: ' БИГ ');

    expect(listing.mixed, isNull);
    expect(listing.letters, ['Б']);
    expect(listing.sections.single.breeds.single.name, 'Бигль');
  });

  test('поиск «метис» оставляет только закреплённую породу', () {
    final listing = buildBreedsListing(breeds, query: 'метис');

    expect(listing.mixed?.id, 1);
    expect(listing.sections, isEmpty);
    expect(listing.isEmpty, isFalse);
  });

  test('ничего не найдено', () {
    expect(buildBreedsListing(breeds, query: 'zzz').isEmpty, isTrue);
  });
}
