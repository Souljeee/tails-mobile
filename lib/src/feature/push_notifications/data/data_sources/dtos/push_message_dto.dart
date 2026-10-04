/// Сообщение FCM в виде, не зависящем от SDK.
class PushMessageDto {
  const PushMessageDto({this.messageId, this.title, this.body, this.data = const {}});

  final String? messageId;
  final String? title;
  final String? body;

  /// Данные сообщения: FCM передаёт только строки.
  final Map<String, String> data;
}
