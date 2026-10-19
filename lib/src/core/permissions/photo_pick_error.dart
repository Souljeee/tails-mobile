import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/permissions/permission_denied_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/photo_picking.dart';

/// Показывает пользователю, почему не удалось выбрать фото: если нет доступа к камере или фото,
/// предлагает открыть настройки, иначе показывает снекбар об ошибке.
Future<void> showPhotoPickError(BuildContext context, Object error, StackTrace stackTrace) async {
  if (error is PhotoAccessDeniedException) {
    await showPermissionDeniedSheet(
      context,
      error.source == ImageSource.camera ? AppPermission.camera : AppPermission.photos,
    );

    return;
  }

  TailsLogger.warning(
    'Не удалось выбрать фото',
    source: 'showPhotoPickError',
    error: error,
    stackTrace: stackTrace,
  );
  showUiSnackBar(context, message: context.l10n.photoPickError);
}
