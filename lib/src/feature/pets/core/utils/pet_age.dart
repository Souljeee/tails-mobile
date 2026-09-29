import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';

/// Возраст питомца в полных годах и месяцах.
///
/// Считается по календарю, а не по количеству дней, поэтому дата рождения 15.01.2024
/// на 26.09.2026 даёт ровно 2 года 8 месяцев.
final class PetAge extends Equatable {
  const PetAge({required this.years, required this.months});

  /// Возраст на текущий момент по [clock] (или на [now], если он передан).
  factory PetAge.fromBirthday(DateTime birthday, {DateTime? now}) {
    final current = now ?? clock.now();

    var years = current.year - birthday.year;
    var months = current.month - birthday.month;

    if (current.day < birthday.day) {
      months--;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    // Дата рождения в будущем не должна давать отрицательный возраст.
    if (years < 0) {
      return const PetAge(years: 0, months: 0);
    }

    return PetAge(years: years, months: months);
  }

  /// Полных лет.
  final int years;

  /// Полных месяцев сверх [years], от 0 до 11.
  final int months;

  @override
  List<Object> get props => [years, months];
}
