import 'dart:io';

import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_android/image_picker_android.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// Максимальная сторона выбранного фото: аватарке не нужен оригинал в полном размере.
const double _maxPhotoSide = 1600;
const int _photoQuality = 85;

/// Выбирает фото из [source]. Возвращает `null`, если пользователь отказался.
///
/// Throws, если системный выбор фото не удался (нет доступа к камере и т.п.).
Future<File?> pickPhoto(ImageSource source) async {
  final XFile? picked;

  if (Platform.isAndroid) {
    final ImagePickerPlatform platform = ImagePickerPlatform.instance;

    if (platform is ImagePickerAndroid) {
      platform.useAndroidPhotoPicker = true;
    }

    picked = await platform.getImageFromSource(
      source: source,
      options: const ImagePickerOptions(
        maxWidth: _maxPhotoSide,
        maxHeight: _maxPhotoSide,
        imageQuality: _photoQuality,
      ),
    );
  } else {
    picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: _maxPhotoSide,
      maxHeight: _maxPhotoSide,
      imageQuality: _photoQuality,
    );
  }

  return picked == null ? null : File(picked.path);
}
