import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

/// Виджет для загрузки фото питомца
class PhotoUploadWidget extends StatefulWidget {
  const PhotoUploadWidget({
    required this.onImageSelected,
    super.key,
  });

  /// Callback, вызываемый при выборе изображения
  final void Function(File image) onImageSelected;

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceBottomSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.uiColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Загрузить фото',
                  style: context.uiFonts.header24Semibold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: context.uiColors.orangePrimary,
                ),
                title: const Text('Галерея'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: context.uiColors.orangePrimary,
                ),
                title: const Text('Камера'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе изображения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _showImageSourceBottomSheet,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.uiColors.black20,
                  border: Border.all(
                    color: context.uiColors.black30,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.pets,
                          size: 64,
                          color: context.uiColors.black40,
                        ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.uiColors.orangePrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.uiColors.black60,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedImage == null) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _showImageSourceBottomSheet,
            child: Text(
              'Добавить фото',
              style: TextStyle(
                fontSize: 16,
                color: context.uiColors.brown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
