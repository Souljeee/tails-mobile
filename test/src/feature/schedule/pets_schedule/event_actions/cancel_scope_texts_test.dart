import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations_ru.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/series_stats.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/cancel_scope_texts.dart';

void main() {
  setUpAll(() => initializeDateFormatting('ru'));

  final l10n = AppLocalizationsRu();
  final date = DateTime(2026, 10, 16);

  CancelScopeTexts texts({int? remaining, int past = 0, bool openEnded = false}) =>
      CancelScopeTexts(
        l10n,
        date: date,
        stats: SeriesStats(
          remaining: remaining,
          past: past,
          seriesEnd: null,
          isOpenEnded: openEnded,
          cancelledDates: const [],
        ),
      );

  test('подписи областей содержат дату', () {
    final t = texts(remaining: 335);

    expect(t.oneLabel, 'Только 16 октября');
    expect(t.futureLabel, '16 октября и все следующие');
    expect(t.confirmOne, 'Отменить событие');
  });

  test('кнопка области «все следующие» склоняет «событие»', () {
    expect(texts(remaining: 1).confirmFuture, 'Отменить 1 событие');
    expect(texts(remaining: 2).confirmFuture, 'Отменить 2 события');
    expect(texts(remaining: 5).confirmFuture, 'Отменить 5 событий');
    expect(texts(remaining: 11).confirmFuture, 'Отменить 11 событий');
    expect(texts(remaining: 21).confirmFuture, 'Отменить 21 событие');
    expect(texts(remaining: 335).confirmFuture, 'Отменить 335 событий');
  });

  test('бессрочная серия: число не называется', () {
    final t = texts(openEnded: true);

    expect(t.confirmFuture, 'Отменить это и все следующие');
    expect(t.futureHint, 'Серия закончится на этой дате');
    expect(t.isSingleChoice, isFalse);
  });

  test('пояснение про прошедшие события склоняется и пропадает без них', () {
    expect(texts(remaining: 5, past: 30).futureHint, 'Сохранятся 30 прошедших событий');
    expect(texts(remaining: 5, past: 2).futureHint, 'Сохранятся 2 прошедших события');
    expect(texts(remaining: 5, past: 1).futureHint, 'Сохранится 1 прошедшее событие');
    expect(texts(remaining: 5).futureHint, isNull);
  });

  test('последнее событие серии выглядит как одиночное', () {
    final t = texts(remaining: 1, past: 4);

    expect(t.isSingleChoice, isTrue);
    expect(t.lastInSeriesHint, isNotNull);
    expect(texts(remaining: 3).lastInSeriesHint, isNull);
  });
}
