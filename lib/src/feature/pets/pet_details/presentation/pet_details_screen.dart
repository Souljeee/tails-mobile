import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_errors/ui_fetching_error.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_button/ui_icon_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/delete_pet/presentation/delete_pet_bottom_sheet.dart';
import 'package:tails_mobile/src/feature/pets/pet_details/domain/pet_details_bloc.dart';
import 'package:tails_mobile/src/feature/pets/pet_details/presentation/widgets/pet_details_content.dart';

class PetDetailsScreen extends StatefulWidget {
  final int id;

  const PetDetailsScreen({required this.id, super.key});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  late final PetDetailsBloc _petDetailsBloc = PetDetailsBloc(
    petRepository: DependenciesScope.of(context).petRepository,
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
    petId: widget.id,
  );

  @override
  void initState() {
    super.initState();
    _petDetailsBloc.add(PetDetailsEvent.fetchRequested(id: widget.id));
  }

  @override
  void dispose() {
    _petDetailsBloc.close();
    super.dispose();
  }

  /// Pull-to-refresh: тихо обновляет карточку и завершается, когда загрузка закончилась.
  Future<void> _refresh() {
    final completer = Completer<void>();

    _petDetailsBloc.add(
      PetDetailsEvent.fetchRequested(id: widget.id, silent: true, completer: completer),
    );

    return completer.future;
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      const PetsRoute().go(context);
    }
  }

  Future<void> _delete() async {
    final result = await DeletePetBottomSheet.show(context: context, petId: widget.id);

    if (result == null || !mounted) {
      return;
    }

    switch (result) {
      case DeletePetStatus.deleted:
        _back();
      case DeletePetStatus.error:
        showUiSnackBar(context, message: context.l10n.tryLater);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Scaffold(
      backgroundColor: palette.canvas,
      body: BlocBuilder<PetDetailsBloc, PetDetailsState>(
        bloc: _petDetailsBloc,
        builder: (context, state) {
          final pet = state.mapOrNull(success: (state) => state.petData);

          return Stack(
            children: [
              state.map(
                loading: (_) => const _PetDetailsShimmer(),
                success: (state) => PetDetailsContent(
                  pet: state.petData,
                  upcomingEvents: state.upcomingEvents,
                  onRefresh: _refresh,
                ),
                error: (_) => SafeArea(
                  child: Center(
                    child: UiFetchingError(
                      onRetry: () =>
                          _petDetailsBloc.add(PetDetailsEvent.fetchRequested(id: widget.id)),
                    ),
                  ),
                ),
              ),
              _PetDetailsActions(pet: pet, onBack: _back, onDelete: _delete),
            ],
          );
        },
      ),
    );
  }
}

/// Круглые кнопки поверх фото: назад, изменить, меню.
class _PetDetailsActions extends StatelessWidget {
  const _PetDetailsActions({required this.pet, required this.onBack, required this.onDelete});

  /// `null`, пока данные не загружены — тогда доступна только кнопка «назад».
  final PetDetailsModel? pet;
  final VoidCallback onBack;
  final VoidCallback onDelete;

  Future<void> _openMenu(BuildContext context) async {
    final button = context.findRenderObject()! as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
    final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(topLeft.dx, topLeft.dy, button.size.width, button.size.height),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<bool>(
      context: context,
      position: position,
      shape: const RoundedRectangleBorder(borderRadius: UiRadius.mdAll),
      items: [
        PopupMenuItem<bool>(
          value: true,
          child: Text(
            context.l10n.deletePetTitle,
            style: context.uiFonts.body.copyWith(color: context.uiPalette.danger),
          ),
        ),
      ],
    );

    if (selected ?? false) {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pet = this.pet;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4, vertical: UiSpacing.x2),
        child: Row(
          children: [
            UiIconButton(
              icon: Icons.arrow_back,
              semanticLabel: l10n.navBack,
              variant: UiIconButtonVariant.overlay,
              onPressed: onBack,
            ),
            const Spacer(),
            if (pet != null) ...[
              UiIconButton(
                icon: Icons.edit_outlined,
                semanticLabel: l10n.editPetTitle,
                variant: UiIconButtonVariant.overlay,
                onPressed: () => EditPetRoute($extra: pet).push<void>(context),
              ),
              const SizedBox(width: UiSpacing.x2),
              Builder(
                builder: (context) => UiIconButton(
                  icon: Icons.more_horiz,
                  semanticLabel: l10n.petDetailsMenu,
                  variant: UiIconButtonVariant.overlay,
                  onPressed: () => _openMenu(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PetDetailsShimmer extends StatelessWidget {
  const _PetDetailsShimmer();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return UiKitShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiKitShimmerLoading(height: width * 0.95, borderRadius: BorderRadius.zero),
            const Padding(
              padding: EdgeInsets.all(UiSpacing.x5),
              child: Column(
                children: [
                  UiKitShimmerLoading(height: 96, borderRadius: UiRadius.mdAll),
                  SizedBox(height: UiSpacing.x4),
                  UiKitShimmerLoading(height: 160, borderRadius: UiRadius.mdAll),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
