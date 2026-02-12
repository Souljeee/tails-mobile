import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_popup/ui_popup.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/delete_pet/domain/delete_pet_bloc.dart';

enum DeletePetStatus {
  deleted,
  error,
}

class DeletePetBottomSheet extends StatefulWidget {
  final int petId;

  static Future<DeletePetStatus?> show({
    required BuildContext context,
    required int petId,
  }) =>
      showUiPopup<DeletePetStatus>(
        context: context,
        isDismissible: false,
        child: DeletePetBottomSheet._(petId: petId),
      );

  const DeletePetBottomSheet._({required this.petId});

  @override
  State<DeletePetBottomSheet> createState() => _DeletePetBottomSheetState();
}

class _DeletePetBottomSheetState extends State<DeletePetBottomSheet> {
  late final DeletePetBloc _deletePetBloc = DeletePetBloc(petRepository: DependenciesScope.of(context).petRepository);

  @override
  void dispose() {
    _deletePetBloc.close();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UiSvgImage(
          svgPath: context.uiIcons.alert.path,
          height: 64,
          width: 64,
          color: context.uiColors.orangePrimary,
        ),
        const SizedBox(height: 28),
        Text(
          context.l10n.deletePetTitle,
          style: context.uiFonts.header32Semibold,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.deletePetSubtitle,
          style: context.uiFonts.text16Regular,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        BlocConsumer<DeletePetBloc, DeletePetState>(
          bloc: _deletePetBloc,
          listener: (context, state) {
            state.mapOrNull(
              success: (_) => Navigator.pop(context, DeletePetStatus.deleted),
              error: (_) => Navigator.pop(context, DeletePetStatus.error),
            );
          },
          builder: (context, state) {
            return Row(
              children: [
                Expanded(
                  child: UiButton.secondary(
                    label: context.l10n.deletePetCancel,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UiButton.main(
                    label: context.l10n.deletePetDelete,
                    isLoading: state.maybeMap(
                      loading: (_) => true,
                      orElse: () => false,
                    ),
                    onPressed: () {
                      _deletePetBloc.add(DeletePetEvent.deleteRequested(id: widget.petId));
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
