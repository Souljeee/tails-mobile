/// Тема обращения в «Помощь и обратная связь».
///
/// [apiValue] — значение поля `topic` в `POST /feedback/`.
enum FeedbackTopic {
  problem('problem'),
  idea('idea'),
  question('question');

  const FeedbackTopic(this.apiValue);

  final String apiValue;

  /// Тема по значению параметра маршрута; неизвестное значение считается проблемой.
  static FeedbackTopic fromName(String? name) =>
      values.firstWhere((topic) => topic.name == name, orElse: () => FeedbackTopic.problem);
}
