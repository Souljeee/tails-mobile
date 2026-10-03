import 'package:permission_handler/permission_handler.dart';

/// Системное разрешение на уведомления.
class NotificationPermissionDataSource {
  const NotificationPermissionDataSource();

  /// `true`, если пользователь запретил уведомления в настройках устройства.
  ///
  /// «Ещё не спрашивали» запретом не считается: на iOS и в Android до первого запроса
  /// `permission_handler` тоже возвращает `denied`, а приложение разрешение пока не запрашивает.
  Future<bool> isBlockedBySystem() async {
    final status = await Permission.notification.status;

    return status.isPermanentlyDenied || status.isRestricted;
  }

  Future<bool> openSettings() => openAppSettings();
}
