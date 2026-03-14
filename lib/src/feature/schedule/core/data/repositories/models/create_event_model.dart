import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';

class CreateEventModel extends Equatable {
  final String title;
  final String? description;
  final String? time;
  final DateTime date;
  final int petId;
  final int type;
  final bool isRecurring;
  final RecurrenceModel? recurrence;

  const CreateEventModel({
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.petId,
    required this.type,
    required this.isRecurring,
    this.recurrence,
  });

  @override
  List<Object?> get props => [title, description, time, date, petId, type, isRecurring, recurrence];
}