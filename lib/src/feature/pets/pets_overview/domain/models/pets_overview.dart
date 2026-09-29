import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';

/// Ближайшее невыполненное событие питомца.
class PetNextEvent extends Equatable {
  const PetNextEvent({required this.event, required this.date});

  final ScheduleEventModel event;

  /// День события (без времени).
  final DateTime date;

  @override
  List<Object?> get props => [event, date];
}

/// Питомец и данные для его карточки на экране обзора.
class PetOverview extends Equatable {
  const PetOverview({required this.pet, this.nextEvent});

  final PetModel pet;

  /// `null`, если событий нет или расписание не удалось загрузить.
  final PetNextEvent? nextEvent;

  @override
  List<Object?> get props => [pet, nextEvent];
}

/// Все данные экрана «Мои питомцы» одним объектом.
class PetsOverview extends Equatable {
  const PetsOverview({required this.pets, this.todayEventsCount});

  final List<PetOverview> pets;

  /// Число событий на сегодня; `null`, если расписание не удалось загрузить.
  final int? todayEventsCount;

  @override
  List<Object?> get props => [pets, todayEventsCount];
}
