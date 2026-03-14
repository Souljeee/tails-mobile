import 'package:equatable/equatable.dart';

class RecurrenceModel extends Equatable {
  final String frequency;
  final int interval;
  final List<int>? weekDays;
  final List<int>? monthDays;
  final String? endType;
  final String? endDate;
  final int? endCount;

  const RecurrenceModel({
    required this.frequency,
    required this.interval,
    required this.endType,
    this.weekDays,
    this.monthDays,
    this.endDate,
    this.endCount,
  });

  @override
  List<Object?> get props => [frequency, interval, weekDays, monthDays, endType, endDate, endCount];
}