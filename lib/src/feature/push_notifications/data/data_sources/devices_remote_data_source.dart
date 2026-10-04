import 'package:rest_client/rest_client.dart';

/// Привязка устройства к аккаунту для push-уведомлений.
class DevicesRemoteDataSource {
  const DevicesRemoteDataSource({required RestClient restClient}) : _restClient = restClient;

  final RestClient _restClient;

  /// Привязывает FCM-токен к текущему пользователю. Токен, ранее принадлежавший другому
  /// пользователю этого телефона, сервер перепривязывает сам.
  Future<void> register({required String token, String? platform}) async {
    await _restClient.post(
      '/devices/register/',
      body: {'fcm_token': token, if (platform != null) 'platform': platform},
    );
  }

  /// Отвязывает токен; идемпотентно, нужен действующий JWT.
  Future<void> unregister({required String token}) async {
    await _restClient.post('/devices/unregister/', body: {'fcm_token': token});
  }
}
