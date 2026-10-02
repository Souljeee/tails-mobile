import 'package:equatable/equatable.dart';

class BreedModel extends Equatable {
  final int id;
  final String name;

  const BreedModel({required this.id, required this.name});

  /// Название породы «Метис или не знаю» на backend.
  ///
  /// Backend хранит её как обычную породу без отдельного флага (для собак и кошек
  /// это две записи с разными `id` и одинаковым названием), поэтому признак —
  /// название. Если backend добавит флаг, достаточно поменять [isMixed].
  static const String mixedBreedName = 'Метис или не знаю';

  /// Это порода «Метис или не знаю».
  bool get isMixed => name.trim() == mixedBreedName;

  @override
  List<Object?> get props => [id, name];
}
