import 'package:equatable/equatable.dart';

/// Сводка по серии относительно даты вхождения (`series_stats` на сервере).
///
/// Каждое время в день считается отдельным событием, отменённые не учитываются.
class SeriesStats extends Equatable {
  const SeriesStats({
    required this.remaining,
    required this.past,
    required this.seriesEnd,
    required this.isOpenEnded,
    required this.cancelledDates,
  });

  /// Сколько событий осталось с выбранной даты включительно; `null` у бессрочной серии.
  final int? remaining;

  /// Сколько событий было до выбранной даты.
  final int past;

  /// Дата окончания серии; `null` у бессрочной.
  final DateTime? seriesEnd;
  final bool isOpenEnded;

  /// Даты не раньше выбранной, на которые отмены уже стоят (для подсказки о сбросе).
  final List<DateTime> cancelledDates;

  /// Остаток — последнее событие серии (отмена «и все следующие» равна отмене одного).
  bool get isLastOccurrence => remaining != null && remaining! <= 1;

  @override
  List<Object?> get props => [remaining, past, seriesEnd, isOpenEnded, cancelledDates];
}
