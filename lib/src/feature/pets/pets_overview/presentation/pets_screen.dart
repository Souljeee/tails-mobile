import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/navigation/shell_actions.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_empty_state/ui_empty_state.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_errors/ui_fetching_error.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_button/ui_icon_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/pets_overview/domain/models/pets_overview.dart';
import 'package:tails_mobile/src/feature/pets/pets_overview/domain/pets_overview_bloc.dart';
import 'package:tails_mobile/src/feature/pets/pets_overview/presentation/widgets/pet_overview_card.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> with ShellActionMixin<PetsScreen> {
  late final PetsOverviewBloc _petsOverviewBloc = PetsOverviewBloc(
    petRepository: DependenciesScope.of(context).petRepository,
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
  );

  bool? _wasTabActive;

  @override
  ShellTab get shellTab => ShellTab.pets;

  @override
  void onShellAction() {
    const AddPetRoute().push<void>(context);
  }

  @override
  void initState() {
    super.initState();

    _petsOverviewBloc.add(const PetsOverviewEvent.fetchRequested());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ветки оболочки живут одновременно. Когда вкладка снова становится активной,
    // тихо обновляем данные: события могли измениться в календаре.
    final isActive = TickerMode.of(context);

    if (_wasTabActive == false && isActive) {
      _petsOverviewBloc.add(const PetsOverviewEvent.fetchRequested(silent: true));
    }

    _wasTabActive = isActive;
  }

  @override
  void dispose() {
    _petsOverviewBloc.close();

    super.dispose();
  }

  void _reload() => _petsOverviewBloc.add(const PetsOverviewEvent.fetchRequested());

  /// Pull-to-refresh: тихо обновляет данные и завершается, когда загрузка закончилась.
  Future<void> _refresh() {
    final completer = Completer<void>();

    _petsOverviewBloc.add(PetsOverviewEvent.fetchRequested(silent: true, completer: completer));

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.uiPalette.canvas,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<PetsOverviewBloc, PetsOverviewState>(
          bloc: _petsOverviewBloc,
          builder: (context, state) {
            return RefreshIndicator.adaptive(
              onRefresh: _refresh,
              color: context.uiPalette.accent,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: UiLargeTitleHeader(
                      title: context.l10n.petsOverviewTitle,
                      subtitle: state.mapOrNull(
                        success: (state) => _subtitle(context, state.overview),
                      ),
                      trailing: UiIconButton(
                        icon: Icons.notifications_none,
                        semanticLabel: context.l10n.notificationsLabel,
                        // TODO: открыть страницу уведомлений, когда она появится.
                        onPressed: () {},
                      ),
                    ),
                  ),
                  state.map(
                    loading: (_) => const SliverToBoxAdapter(child: _PetsShimmer()),
                    error: (_) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: UiFetchingError(onRetry: _reload),
                    ),
                    success: (state) => state.overview.pets.isEmpty
                        ? const SliverFillRemaining(hasScrollBody: false, child: _PetsEmpty())
                        : _PetsSliver(overview: state.overview),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _subtitle(BuildContext context, PetsOverview overview) {
    final l10n = context.l10n;
    final count = l10n.petsCount(overview.pets.length);
    final today = overview.todayEventsCount;

    return today == null ? count : '$count · ${l10n.petsTodayEvents(today)}';
  }
}

class _PetsSliver extends StatelessWidget {
  const _PetsSliver({required this.overview});

  final PetsOverview overview;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        UiSpacing.x5,
        UiSpacing.x2,
        UiSpacing.x5,
        ShellScope.bottomInsetOf(context),
      ),
      sliver: SliverList.separated(
        itemCount: overview.pets.length,
        separatorBuilder: (context, index) => const SizedBox(height: UiSpacing.x4),
        itemBuilder: (context, index) {
          final item = overview.pets[index];

          return PetOverviewCard(
            key: ValueKey(item.pet.id),
            overview: item,
            petColor: palette.petColor(index),
            onTap: () {
              PetDetailsRoute(id: item.pet.id).push<void>(context);
            },
          );
        },
      ),
    );
  }
}

class _PetsEmpty extends StatelessWidget {
  const _PetsEmpty();

  @override
  Widget build(BuildContext context) {
    return UiEmptyState(
      illustration: SvgPicture.asset(context.uiIcons.emptyDogHouse.keyName),
      title: context.l10n.petsEmptyTitle,
      message: context.l10n.petsEmptyMessage,
    );
  }
}

class _PetsShimmer extends StatelessWidget {
  const _PetsShimmer();

  @override
  Widget build(BuildContext context) {
    return UiKitShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5, vertical: UiSpacing.x2),
        child: Column(
          children: List.generate(
            2,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: UiSpacing.x4),
              child: UiKitShimmerLoading(height: 320, borderRadius: UiRadius.lgAll),
            ),
          ),
        ),
      ),
    );
  }
}
