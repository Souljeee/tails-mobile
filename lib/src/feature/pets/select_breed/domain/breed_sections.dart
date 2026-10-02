import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';

/// Секция списка пород: буква и породы на неё.
class BreedSection {
  const BreedSection({required this.letter, required this.breeds});

  final String letter;
  final List<BreedModel> breeds;
}

/// Результат группировки: закреплённая «Метис или не знаю» и алфавитные секции.
class BreedsListing {
  const BreedsListing({required this.mixed, required this.sections});

  /// Порода «Метис или не знаю» (закрепляется над списком); `null`, если её нет
  /// в ответе или она не подходит под поиск.
  final BreedModel? mixed;
  final List<BreedSection> sections;

  List<String> get letters => [for (final section in sections) section.letter];

  bool get isEmpty => mixed == null && sections.isEmpty;
}

/// Фильтрует породы по [query] и группирует по первой букве названия.
BreedsListing buildBreedsListing(List<BreedModel> breeds, {String query = ''}) {
  final normalized = query.toLowerCase().trim();
  final matching = normalized.isEmpty
      ? breeds
      : breeds.where((breed) => breed.name.toLowerCase().contains(normalized)).toList();

  final mixed = matching.where((breed) => breed.isMixed).firstOrNull;
  final regular = matching.where((breed) => !breed.isMixed).toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  final grouped = <String, List<BreedModel>>{};

  for (final breed in regular) {
    final trimmed = breed.name.trim();
    final letter = trimmed.isEmpty ? '#' : trimmed[0].toUpperCase();

    grouped.putIfAbsent(letter, () => []).add(breed);
  }

  return BreedsListing(
    mixed: mixed,
    sections: [
      for (final entry in grouped.entries) BreedSection(letter: entry.key, breeds: entry.value),
    ],
  );
}
