import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_discard_guard/ui_discard_guard.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_phone_field/ui_phone_field.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_photo_picker/ui_photo_picker.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/phone_format.dart';
import 'package:tails_mobile/src/core/utils/photo_picking.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/profile_model.dart';
import 'package:tails_mobile/src/feature/profile/core/presentation/profile_photo_sheet.dart';
import 'package:tails_mobile/src/feature/profile/edit_profile/domain/edit_profile_bloc.dart';

/// Максимальная длина имени совпадает с ограничением на сервере.
const int _maxNameLength = 50;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({required this.profile, super.key});

  final ProfileModel profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final EditProfileBloc _bloc = EditProfileBloc(
    profileRepository: DependenciesScope.of(context).profileRepository,
  );

  late final UiTextFieldController _nameController = UiTextFieldController(
    text: widget.profile.name,
  );
  late final UiTextFieldController _phoneController = UiTextFieldController(
    text: _phoneDigits(widget.profile.phoneNumber),
  );

  /// Номер без кода страны для поля с маской: `79991234567` → `999 123-45-67`.
  static String _phoneDigits(String phoneNumber) {
    final formatted = formatPhoneForDisplay(phoneNumber);

    return formatted.startsWith('+7 ') ? formatted.substring(3) : formatted;
  }

  /// Новое фото, ещё не отправленное на сервер.
  File? _newAvatar;

  /// Пользователь удалил текущее фото и не выбрал новое.
  bool _removeAvatar = false;

  bool get _hasPhoto => _newAvatar != null || (!_removeAvatar && widget.profile.hasAvatar);

  bool get _nameChanged => _nameController.text.trim() != widget.profile.name;

  bool get _hasChanges => _nameChanged || _newAvatar != null || _removeAvatar;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bloc.close();
    _nameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final action = await showProfilePhotoSheet(context, hasPhoto: _hasPhoto);

    switch (action) {
      case ProfilePhotoAction.camera:
        await _pick(ImageSource.camera);
      case ProfilePhotoAction.gallery:
        await _pick(ImageSource.gallery);
      case ProfilePhotoAction.delete:
        setState(() {
          _newAvatar = null;
          _removeAvatar = true;
        });
      case null:
        break;
    }
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await pickPhoto(source);

      if (file != null && mounted) {
        setState(() {
          _newAvatar = file;
          _removeAvatar = false;
        });
      }
    } catch (_) {
      if (mounted) {
        showUiSnackBar(context, message: context.l10n.photoPickError);
      }
    }
  }

  void _save() {
    FocusScope.of(context).unfocus();

    _bloc.add(
      EditProfileEvent.saveRequested(
        name: _nameChanged ? _nameController.text.trim() : null,
        avatar: _newAvatar,
        removeAvatar: _removeAvatar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;

    return UiDiscardGuard(
      hasChanges: _hasChanges,
      child: Scaffold(
        backgroundColor: palette.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
                child: UiSheetHeader(title: l10n.editProfileTitle, cancelLabel: l10n.cancel),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(UiSpacing.x5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: UiPhotoPicker(
                          size: 112,
                          hasPhoto: _hasPhoto,
                          label: _hasPhoto ? l10n.editProfilePhotoChange : l10n.editProfilePhotoAdd,
                          onTap: _choosePhoto,
                          image: _avatarImage(),
                        ),
                      ),
                      const SizedBox(height: UiSpacing.x6),
                      UiTextField(
                        controller: _nameController,
                        labelText: l10n.editProfileNameLabel,
                        placeholderText: l10n.editProfileNamePlaceholder,
                        capitalization: TextCapitalization.words,
                        maxLength: _maxNameLength,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: UiSpacing.x4),
                      UiPhoneField(
                        controller: _phoneController,
                        labelText: l10n.editProfilePhoneLabel,
                        helperText: l10n.editProfilePhoneHint,
                        enabled: false,
                        countryFlag: UiSvgImage(
                          svgPath: context.uiIcons.russiaFlag.path,
                          height: 16,
                        ),
                      ),
                      const SizedBox(height: UiSpacing.x6),
                      UiSectionHeader(title: l10n.editProfileAccountSection),
                      const SizedBox(height: UiSpacing.x2),
                      UiGroupedList(
                        dividerIndent: UiNavRow.leadingWidth,
                        children: [
                          UiNavRow(
                            icon: Icons.delete_outline,
                            tone: UiNavRowTone.danger,
                            title: l10n.editProfileDeleteAccount,
                            subtitle: l10n.editProfileDeleteAccountHint,
                            onTap: () => unawaited(
                              DeleteAccountRoute(
                                phoneNumber: widget.profile.phoneNumber,
                              ).push<void>(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  UiSpacing.x5,
                  UiSpacing.x2,
                  UiSpacing.x5,
                  UiSpacing.x4,
                ),
                child: BlocConsumer<EditProfileBloc, EditProfileState>(
                  bloc: _bloc,
                  listener: (context, state) {
                    state.mapOrNull(
                      success: (_) => Navigator.of(context).pop(),
                      error: (state) => showUiSnackBar(
                        context,
                        message: state.isValidation ? l10n.editProfileInvalid : l10n.tryLater,
                      ),
                    );
                  },
                  builder: (context, state) {
                    final isLoading = state.mapOrNull(loading: (_) => true) ?? false;

                    return UiButton.main(
                      label: l10n.editProfileSave,
                      isLoading: isLoading,
                      onPressed: _hasChanges && !isLoading ? _save : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _avatarImage() {
    final newAvatar = _newAvatar;

    if (newAvatar != null) {
      return Image.file(newAvatar, fit: BoxFit.cover);
    }

    if (!_removeAvatar && widget.profile.hasAvatar) {
      return CachedNetworkImage(imageUrl: widget.profile.avatarUrl!, fit: BoxFit.cover);
    }

    return null;
  }
}
