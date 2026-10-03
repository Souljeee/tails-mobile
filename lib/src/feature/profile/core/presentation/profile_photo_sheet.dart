import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_sheets/ui_action_sheet.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

/// Что выбрал пользователь в шторке «Фото профиля».
enum ProfilePhotoAction { camera, gallery, delete }

/// Шторка «Фото профиля». «Удалить фото» показывается, только если фото уже есть.
Future<ProfilePhotoAction?> showProfilePhotoSheet(BuildContext context, {required bool hasPhoto}) {
  final l10n = context.l10n;

  return showUiActionSheet<ProfilePhotoAction>(
    context: context,
    title: l10n.profilePhotoSheetTitle,
    cancelLabel: l10n.cancel,
    groups: [
      [
        UiActionSheetItem(
          value: ProfilePhotoAction.camera,
          icon: Icons.photo_camera_outlined,
          label: l10n.profilePhotoCamera,
        ),
        UiActionSheetItem(
          value: ProfilePhotoAction.gallery,
          icon: Icons.image_outlined,
          label: l10n.profilePhotoGallery,
        ),
      ],
      if (hasPhoto)
        [
          UiActionSheetItem(
            value: ProfilePhotoAction.delete,
            icon: Icons.delete_outline,
            label: l10n.profilePhotoDelete,
            tone: UiNavRowTone.danger,
          ),
        ],
    ],
  );
}
