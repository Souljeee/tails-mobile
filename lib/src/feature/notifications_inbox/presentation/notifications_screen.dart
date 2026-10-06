import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/analytics/integrations/analytics_impression.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_errors/ui_fetching_error.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_notice_banner/ui_notice_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/models/inbox_item.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/inbox_sections.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/notifications_inbox_bloc.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/presentation/widgets/inbox_empty_view.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/presentation/widgets/inbox_filter_bar.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/presentation/widgets/inbox_section_view.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/presentation/widgets/inbox_shimmer.dart';

/// Экран «Уведомления»: история напоминаний с фильтром «Все» / «Непрочитанные».
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with WidgetsBindingObserver {
  late final NotificationsInboxBloc _bloc = NotificationsInboxBloc(
    inboxRepository: DependenciesScope.of(context).notificationsInboxRepository,
    petRepository: DependenciesScope.of(context).petRepository,
    profileRepository: DependenciesScope.of(context).profileRepository,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _bloc.add(const NotificationsInboxEvent.started());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Пользователь мог разрешить уведомления в настройках телефона, а новые пришли в фоне.
    if (state == AppLifecycleState.resumed) {
      _bloc
        ..add(const NotificationsInboxEvent.systemStatusChecked())
        ..add(const NotificationsInboxEvent.refreshRequested());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.uiPalette.canvas,
      body: BlocProvider.value(
        value: _bloc,
        child: Column(
          children: [
            UiTopBar(
              title: l10n.inboxTitle,
              backLabel: l10n.enterCodeBack,
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: BlocConsumer<NotificationsInboxBloc, NotificationsInboxState>(
                listenWhen: (previous, current) => current.actionFailures > previous.actionFailures,
                listener: (context, state) => showUiSnackBar(context, message: l10n.tryLater),
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) => switch (state.status) {
                  NotificationsInboxStatus.loading => const InboxShimmer(),
                  NotificationsInboxStatus.failure => UiFetchingError(
                    onRetry: () => _bloc.add(const NotificationsInboxEvent.started()),
                  ),
                  NotificationsInboxStatus.ready => _InboxContent(state: state),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxContent extends StatefulWidget {
  const _InboxContent({required this.state});

  final NotificationsInboxState state;

  @override
  State<_InboxContent> createState() => _InboxContentState();
}

class _InboxContentState extends State<_InboxContent> {
  /// За сколько до конца списка начинается подгрузка следующей страницы.
  static const double _loadMoreThreshold = 400;

  final ScrollController _controller = ScrollController();

  NotificationsInboxBloc get _bloc => context.read<NotificationsInboxBloc>();

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  void _onScroll() {
    final position = _controller.position;

    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      _bloc.add(const NotificationsInboxEvent.loadMoreRequested());
    }
  }

  /// Pull-to-refresh: тихо обновляет список и завершается, когда загрузка закончилась.
  Future<void> _refresh() {
    final completer = Completer<void>();

    _bloc.add(NotificationsInboxEvent.refreshRequested(completer: completer));

    return completer.future;
  }

  void _openItem(InboxItem item) {
    _bloc.add(NotificationsInboxEvent.itemOpened(id: item.id));

    // Пока ведём в «Расписание», как и нажатие на push; переход к самому событию — позже.
    const ScheduleRoute().go(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l10n = context.l10n;
    final now = clock.now();
    final isCompletelyEmpty = state.isEmpty && state.filter == NotificationsInboxFilter.all;
    final sections = groupInboxItems(state.items, now);

    return RefreshIndicator.adaptive(
      onRefresh: _refresh,
      color: context.uiPalette.accent,
      child: CustomScrollView(
        controller: _controller,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          if (state.isBlockedBySystem)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  UiSpacing.x5,
                  UiSpacing.x2,
                  UiSpacing.x5,
                  UiSpacing.x2,
                ),
                child: AnalyticsImpression(
                  onShown: () {
                    TailsAnalytics.log(TailsAnalyticsEvents.notificationsDisabledBannerShown);
                    TailsAnalytics.setUserProperty(
                      TailsAnalyticsUserProperty.pushStatus,
                      'system_blocked',
                    );
                  },
                  child: UiNoticeBanner(
                    title: l10n.notificationsBlockedTitle,
                    text: l10n.notificationsBlockedText,
                    actionLabel: l10n.notificationsBlockedAction,
                    onAction: () =>
                        _bloc.add(const NotificationsInboxEvent.openSettingsRequested()),
                  ),
                ),
              ),
            ),
          // Когда уведомлений нет совсем, фильтровать нечего.
          if (!isCompletelyEmpty)
            SliverToBoxAdapter(
              child: InboxFilterBar(
                filter: state.filter,
                unreadCount: state.unreadCount,
                onFilterChanged: (filter) =>
                    _bloc.add(NotificationsInboxEvent.filterChanged(filter: filter)),
                onReadAll: () => _bloc.add(const NotificationsInboxEvent.readAllRequested()),
              ),
            ),
          if (isCompletelyEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: InboxEmptyView(
                onOpenSettings: () => const NotificationsSettingsRoute().push<void>(context),
              ),
            )
          else if (state.isEmpty)
            const SliverFillRemaining(hasScrollBody: false, child: InboxAllReadView())
          else
            SliverList.builder(
              itemCount: sections.length,
              itemBuilder: (context, index) => InboxSectionView(
                section: sections[index],
                pets: state.pets,
                now: now,
                onItemOpened: _openItem,
              ),
            ),
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(UiSpacing.x5),
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom + UiSpacing.x6),
          ),
        ],
      ),
    );
  }
}
