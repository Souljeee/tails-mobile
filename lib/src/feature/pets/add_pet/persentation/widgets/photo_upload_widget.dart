import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_photo_picker/ui_photo_picker.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

/// Виджет для загрузки фото питомца
class PhotoUploadWidget extends StatefulWidget {
  const PhotoUploadWidget({required this.onImageSelected, this.initialImageUrl, super.key});

  /// Callback, вызываемый при выборе изображения
  final void Function(File image) onImageSelected;

  /// Начальное изображение питомца (например, с сервера).
  /// Если пользователь выберет фото с устройства, оно будет показано вместо этого изображения.
  final String? initialImageUrl;

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool get _hasInitialImageUrl => widget.initialImageUrl?.trim().isNotEmpty ?? false;

  bool get _hasImage => _selectedImage != null || _hasInitialImageUrl;

  Future<void> _showImageSourceBottomSheet() async {
    final l10n = context.l10n;

    await showUiBottomSheet<void>(
      context: context,
      name: 'photo-source',
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          UiSheetHeader(title: l10n.photoSourceTitle, cancelLabel: l10n.cancel),
          _SourceTile(
            icon: Icons.photo_library_outlined,
            label: l10n.photoSourceGallery,
            onTap: () {
              Navigator.pop(sheetContext);
              _pickImage(ImageSource.gallery);
            },
          ),
          _SourceTile(
            icon: Icons.photo_camera_outlined,
            label: l10n.photoSourceCamera,
            onTap: () {
              Navigator.pop(sheetContext);
              _pickImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      late XFile? pickedFile;

      if (Platform.isAndroid) {
        final ImagePickerPlatform imagePickerImplementation = ImagePickerPlatform.instance;

        if (imagePickerImplementation is ImagePickerAndroid) {
          imagePickerImplementation.useAndroidPhotoPicker = true;
        }

        pickedFile = await imagePickerImplementation.getImageFromSource(source: source);
      } else {
        pickedFile = await _picker.pickImage(source: source);
      }

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        setState(() {
          _selectedImage = file;
        });

        widget.onImageSelected(file);
      }
    } catch (e) {
      if (mounted) {
        showUiSnackBar(context, message: context.l10n.photoPickError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;

    return UiPhotoPicker(
      hasPhoto: _hasImage,
      label: _hasImage ? l10n.petPhotoChange : l10n.petPhotoAdd,
      hint: l10n.petPhotoHint,
      onTap: _showImageSourceBottomSheet,
      image: _selectedImage != null
          ? Image.file(_selectedImage!, fit: BoxFit.cover)
          : _hasInitialImageUrl
          ? CachedNetworkImage(
              imageUrl: widget.initialImageUrl!,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Icon(Icons.pets, size: 48, color: palette.ink3),
            )
          : null,
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: palette.accent),
      title: Text(label, style: context.uiFonts.body.copyWith(color: palette.ink)),
      onTap: onTap,
    );
  }
}
