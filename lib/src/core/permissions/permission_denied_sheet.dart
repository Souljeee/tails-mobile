import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_sheets/ui_confirm_sheet.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

/// Системные разрешения, без которых не работает часть приложения.
enum AppPermission { camera, photos }

/// Сообщает, что доступа к [permission] нет, и предлагает открыть настройки приложения
/// в настройках телефона, где доступ можно разрешить.
Future<void> showPermissionDeniedSheet(BuildContext context, AppPermission permission) async {
  final l10n = context.l10n;
  final (title, message) = switch (permission) {
    AppPermission.camera => (l10n.permissionCameraDeniedTitle, l10n.permissionCameraDeniedText),
    AppPermission.photos => (l10n.permissionPhotosDeniedTitle, l10n.permissionPhotosDeniedText),
  };

  final openSettings = await showUiConfirmSheet(
    context: context,
    title: title,
    message: message,
    confirmLabel: l10n.permissionOpenSettings,
    cancelLabel: l10n.permissionNotNow,
  );

  if (openSettings) {
    await openSystemAppSettings();
  }
}

/// Открывает страницу приложения в настройках телефона.
///
/// Возвращает `false`, если открыть настройки не удалось.
Future<bool> openSystemAppSettings() async {
  try {
    final opened = await openAppSettings();

    if (!opened) {
      TailsLogger.warning(
        'Не удалось открыть настройки приложения',
        source: 'openSystemAppSettings',
      );
    }

    return opened;
  } on Object catch (e, s) {
    TailsLogger.warning(
      'Не удалось открыть настройки приложения',
      source: 'openSystemAppSettings',
      error: e,
      stackTrace: s,
    );

    return false;
  }
}
