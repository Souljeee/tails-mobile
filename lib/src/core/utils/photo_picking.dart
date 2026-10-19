import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_android/image_picker_android.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

/// Максимальная сторона выбранного фото: аватарке не нужен оригинал в полном размере.
const double _maxPhotoSide = 1600;
const int _photoQuality = 85;

/// Коды ошибок `image_picker`, когда пользователь запретил доступ к камере или фото.
const Set<String> _accessDeniedCodes = {'camera_access_denied', 'photo_access_denied'};

/// Пользователь запретил приложению доступ к камере или фото в настройках телефона.
final class PhotoAccessDeniedException implements Exception {
  const PhotoAccessDeniedException(this.source);

  final ImageSource source;

  @override
  String toString() => 'PhotoAccessDeniedException(${source.name})';
}

/// Выполняет системный выбор фото [pick] и превращает отказ в доступе в
/// [PhotoAccessDeniedException].
Future<T> guardPhotoAccess<T>(ImageSource source, Future<T> Function() pick) async {
  try {
    return await pick();
  } on PlatformException catch (e) {
    if (!_accessDeniedCodes.contains(e.code)) {
      rethrow;
    }

    TailsLogger.info(
      'Нет доступа к камере или фото',
      source: 'pickPhoto',
      data: {'source': source.name, 'code': e.code},
    );

    throw PhotoAccessDeniedException(source);
  }
}

/// Выбирает фото из [source]. Возвращает `null`, если пользователь отказался.
///
/// Throws [PhotoAccessDeniedException], если доступ к камере или фото запрещён, и другие
/// исключения, если системный выбор фото не удался.
Future<File?> pickPhoto(ImageSource source) => guardPhotoAccess(source, () => _pickPhoto(source));

Future<File?> _pickPhoto(ImageSource source) async {
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
