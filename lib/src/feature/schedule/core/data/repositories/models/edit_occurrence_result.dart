import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';

/// Итог изменения вхождения.
///
/// [createdEvent] есть, когда серия разделилась: старая закончилась накануне, с выбранной даты
/// начало жить новое событие (идентификаторы будущих вхождений поменялись — окно перезагружают).
class EditOccurrenceResult extends Equatable {
  const EditOccurrenceResult({required this.event, this.createdEvent});

  final ScheduleEventModel event;
  final ScheduleEventModel? createdEvent;

  bool get isSplit => createdEvent != null;

  @override
  List<Object?> get props => [event, createdEvent];
}
