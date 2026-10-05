import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/delete_pet/domain/delete_pet_bloc.dart';

enum DeletePetStatus { deleted, error }

class DeletePetBottomSheet extends StatefulWidget {
  final int petId;

  static Future<DeletePetStatus?> show({required BuildContext context, required int petId}) =>
      showUiBottomSheet<DeletePetStatus>(
        context: context,
        name: 'delete-pet',
        isDismissible: false,
        builder: (_) => DeletePetBottomSheet._(petId: petId),
      );

  const DeletePetBottomSheet._({required this.petId});

  @override
  State<DeletePetBottomSheet> createState() => _DeletePetBottomSheetState();
}

class _DeletePetBottomSheetState extends State<DeletePetBottomSheet> {
  late final DeletePetBloc _deletePetBloc = DeletePetBloc(
    petRepository: DependenciesScope.of(context).petRepository,
  );

  @override
  void dispose() {
    _deletePetBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Column(
      children: [
        UiIconBadge(
          icon: Icons.delete_outline,
          size: 64,
          iconSize: 28,
          foregroundColor: palette.danger,
          backgroundColor: palette.dangerTint,
        ),
        const SizedBox(height: UiSpacing.x5),
        Text(
          context.l10n.deletePetTitle,
          style: fonts.displayS.copyWith(color: palette.ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UiSpacing.x2),
        Text(
          context.l10n.deletePetSubtitle,
          style: fonts.body.copyWith(color: palette.ink2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UiSpacing.x6),
        BlocConsumer<DeletePetBloc, DeletePetState>(
          bloc: _deletePetBloc,
          listener: (context, state) {
            state.mapOrNull(
              success: (_) => Navigator.pop(context, DeletePetStatus.deleted),
              error: (_) => Navigator.pop(context, DeletePetStatus.error),
            );
          },
          builder: (context, state) {
            final isLoading = state.maybeMap(loading: (_) => true, orElse: () => false);

            return Row(
              children: [
                Expanded(
                  child: UiButton.secondary(
                    label: context.l10n.deletePetCancel,
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: UiSpacing.x3),
                Expanded(
                  child: UiButton.main(
                    label: context.l10n.deletePetDelete,
                    isLoading: isLoading,
                    staticFillColor: palette.danger,
                    onPressed: () =>
                        _deletePetBloc.add(DeletePetEvent.deleteRequested(id: widget.petId)),
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
