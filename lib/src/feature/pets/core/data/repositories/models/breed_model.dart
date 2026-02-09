import 'package:equatable/equatable.dart';

class BreedModel extends Equatable {
  final int id;
  final String name;

  const BreedModel({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}