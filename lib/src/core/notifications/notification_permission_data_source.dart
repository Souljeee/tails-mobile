import 'package:permission_handler/permission_handler.dart';

/// Системное разрешение на уведомления.
class NotificationPermissionDataSource {
  const NotificationPermissionDataSource();

  /// `true`, если пользователь запретил уведомления в настройках устройства.
  ///
  /// «Ещё не спрашивали» запретом не считается: на iOS и в Android до первого запроса
  /// `permission_handler` возвращает `denied`. Разрешение приложение запрашивает после входа
  /// в аккаунт (см. `PushNotificationsRepository`).
  Future<bool> isBlockedBySystem() async {
    final status = await Permission.notification.status;

    return status.isPermanentlyDenied || status.isRestricted;
  }

  Future<bool> openSettings() => openAppSettings();

  /// «Включить»: если разрешение ещё можно запросить — системный запрос, иначе настройки.
  ///
  /// Возвращает `true`, если уведомления разрешены сразу после системного запроса.
  Future<bool> enable() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final requested = await Permission.notification.request();

      return requested.isGranted || requested.isProvisional;
    }

    await openAppSettings();

    return false;
  }
}
