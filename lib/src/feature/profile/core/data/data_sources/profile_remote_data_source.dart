import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/dtos/notification_settings_dto.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/dtos/profile_dto.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';
import 'package:tails_mobile/src/feature/profile/core/exceptions/profile_exceptions.dart';

/// Ответ на отправку кода удаления аккаунта.
typedef DeletionCodeSent = ({int resendTimeoutSeconds});

/// Эндпоинты раздела «Профиль»: профиль, уведомления, удаление аккаунта, обратная связь.
class ProfileRemoteDataSource {
  const ProfileRemoteDataSource({required RestClient restClient}) : _restClient = restClient;

  final RestClient _restClient;

  /// Время до повторной отправки кода, если сервер его не прислал.
  static const int defaultResendTimeoutSeconds = 60;

  Future<ProfileDto> getProfile() async {
    final response = await _restClient.get('/profile/');

    return ProfileDto.fromJson(_asMap(response, 'profile'));
  }

  /// Обновляет имя и/или фото. Пустое [name] очищает имя; `null` оставляет как есть.
  Future<ProfileDto> updateProfile({String? name, String? avatarPath}) async {
    try {
      final response = await _restClient.multipart(
        '/profile/',
        method: 'PATCH',
        fields: {if (name != null) 'name': name},
        files: [
          if (avatarPath != null) RestClientMultipartFile.path(field: 'avatar', path: avatarPath),
        ],
      );

      return ProfileDto.fromJson(_asMap(response, 'profile'));
    } on RestClientException catch (e) {
      if (e.statusCode == 400) {
        throw ProfileValidationException(message: _detailOf(e));
      }

      rethrow;
    }
  }

  Future<void> deleteAvatar() => _restClient.delete('/profile/avatar/');

  Future<NotificationSettingsDto> getNotificationSettings() async {
    final response = await _restClient.get('/profile/notification-settings/');

    return NotificationSettingsDto.fromJson(_asMap(response, 'notification settings'));
  }

  /// Меняет одну категорию и возвращает полное состояние с сервера.
  Future<NotificationSettingsDto> updateNotificationSetting({
    required NotificationCategory category,
    required bool enabled,
  }) async {
    final response = await _restClient.patch(
      '/profile/notification-settings/',
      body: {category.apiKey: enabled},
    );

    return NotificationSettingsDto.fromJson(_asMap(response, 'notification settings'));
  }

  /// Просит сервер позвонить на номер пользователя с кодом для удаления аккаунта.
  ///
  /// Throws [DeletionCodeTooSoonException], если код уже отправляли меньше минуты назад.
  Future<DeletionCodeSent> sendDeletionCode() async {
    try {
      final response = await _restClient.post('/profile/delete/send-code/', body: const {});
      final timeout = response is Map ? response['resend_timeout'] : null;

      return (resendTimeoutSeconds: timeout is int ? timeout : defaultResendTimeoutSeconds);
    } on RestClientException catch (e) {
      if (e.statusCode == 429) {
        throw const DeletionCodeTooSoonException();
      }

      rethrow;
    }
  }

  /// Подтверждает код и удаляет аккаунт.
  ///
  /// Throws [InvalidDeletionCodeException], если код не подошёл.
  Future<void> deleteAccount({required String code}) async {
    try {
      await _restClient.post('/profile/delete/', body: {'code': code});
    } on RestClientException catch (e) {
      if (e.statusCode == 400) {
        throw InvalidDeletionCodeException(message: _detailOf(e) ?? '');
      }

      rethrow;
    }
  }

  Future<void> sendFeedback({
    required Map<String, String> fields,
    required String? screenshotPath,
    List<int>? logs,
  }) async {
    try {
      await _restClient.multipart(
        '/feedback/',
        fields: fields,
        files: [
          if (screenshotPath != null)
            RestClientMultipartFile.path(field: 'screenshot', path: screenshotPath),
          if (logs != null)
            RestClientMultipartFile.bytes(field: 'logs', bytes: logs, filename: 'logs.txt.gz'),
        ],
      );
    } on RestClientException catch (e) {
      if (e.statusCode == 429) {
        throw const FeedbackRateLimitException();
      }

      rethrow;
    }
  }

  Map<String, dynamic> _asMap(Object? response, String what) {
    if (response is! Map) {
      throw ClientException(
        message: 'Unexpected response for $what: ${response.runtimeType}',
        cause: response,
      );
    }

    return Map<String, dynamic>.from(response);
  }

  /// Текст `detail` из тела ответа с ошибкой, если он есть.
  String? _detailOf(RestClientException exception) {
    if (exception is BackendException) {
      final response = exception.response;

      if (response is Map && response['detail'] is String) {
        return response['detail'] as String;
      }
    }

    return null;
  }
}
