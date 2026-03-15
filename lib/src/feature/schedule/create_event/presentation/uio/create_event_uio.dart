import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';

class CreateEventUio extends Equatable {
  final String? title;
  final String? description;
  final String? time;
  final DateTime? date;
  final int? petId;
  final ScheduleEventTypeEnum? type;
  final bool? isRecurring;
  final RecurrenceModel? recurrence;

  const CreateEventUio({
    this.title,
    this.description,
    this.time,
    this.date,
    this.petId,
    this.type,
    this.isRecurring,
    this.recurrence,
  });

  bool get isValid => title != null && title!.isNotEmpty && date != null && petId != null;

  CreateEventUio copyWith({
    CopyWithWrapper<String?>? title,
    CopyWithWrapper<String?>? description,
    CopyWithWrapper<String?>? time,
    CopyWithWrapper<DateTime?>? date,
    CopyWithWrapper<int?>? petId,
    CopyWithWrapper<ScheduleEventTypeEnum?>? type,
    CopyWithWrapper<bool?>? isRecurring,
    CopyWithWrapper<RecurrenceModel?>? recurrence,
  }) => CreateEventUio(
    title: title?.value ?? this.title,
    description: description?.value ?? this.description,
    time: time?.value ?? this.time,
    date: date?.value ?? this.date,
    petId: petId?.value ?? this.petId,
    type: type?.value ?? this.type,
    isRecurring: isRecurring?.value ?? this.isRecurring,
    recurrence: recurrence?.value ?? this.recurrence,
  );

  @override
  List<Object?> get props => [title, description, time, date, petId, type, isRecurring, recurrence];
}
