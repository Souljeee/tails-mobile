/// К каким вхождениям применяется действие (отмена, изменение).
enum OccurrenceScope {
  /// Только выбранная дата.
  one('one'),

  /// Выбранная дата и все следующие.
  future('future');

  const OccurrenceScope(this.apiValue);

  final String apiValue;
}
