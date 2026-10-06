import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/navigation/shell_actions.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_errors/ui_fetching_error.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_avatar/ui_pet_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_profile_card/ui_profile_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_sheets/ui_action_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/phone_format.dart';
import 'package:tails_mobile/src/core/utils/photo_picking.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/notification_settings_model.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/feedback_topic.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';
import 'package:tails_mobile/src/feature/profile/core/presentation/logout_flow.dart';
import 'package:tails_mobile/src/feature/profile/core/presentation/profile_photo_sheet.dart';
import 'package:tails_mobile/src/feature/profile/profile_overview/domain/profile_overview.dart';
import 'package:tails_mobile/src/feature/profile/profile_overview/domain/profile_overview_bloc.dart';
import 'package:tails_mobile/src/feature/profile/profile_overview/presentation/profile_theme_row.dart';

/// Вкладка «Профиль».
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileOverviewBloc _bloc = ProfileOverviewBloc(
    profileRepository: DependenciesScope.of(context).profileRepository,
    petRepository: DependenciesScope.of(context).petRepository,
  );

  bool? _wasTabActive;

  @override
  void initState() {
    super.initState();

    _bloc.add(const ProfileOverviewEvent.fetchRequested());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ветки оболочки живут одновременно: при возврате на вкладку тихо обновляем данные.
    final isActive = TickerMode.of(context);

    if (_wasTabActive == false && isActive) {
      _bloc.add(const ProfileOverviewEvent.fetchRequested(silent: true));
    }

    _wasTabActive = isActive;
  }

  @override
  void dispose() {
    _bloc.close();

    super.dispose();
  }

  void _reload() => _bloc.add(const ProfileOverviewEvent.fetchRequested());

  Future<void> _refresh() {
    final completer = Completer<void>();

    _bloc.add(ProfileOverviewEvent.fetchRequested(silent: true, completer: completer));

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.uiPalette.canvas,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ProfileOverviewBloc, ProfileOverviewState>(
          bloc: _bloc,
          listenWhen: (previous, current) =>
              current is ProfileOverviewState$Success &&
              previous is ProfileOverviewState$Success &&
              current.overview.avatarUploadFailures > previous.overview.avatarUploadFailures,
          listener: (context, state) => showUiSnackBar(context, message: context.l10n.tryLater),
          builder: (context, state) {
            return RefreshIndicator.adaptive(
              onRefresh: _refresh,
              color: context.uiPalette.accent,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(child: UiLargeTitleHeader(title: context.l10n.profileTitle)),
                  state.map(
                    loading: (_) => const SliverToBoxAdapter(child: _ProfileShimmer()),
                    error: (_) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: UiFetchingError(onRetry: _reload),
                    ),
                    success: (state) => SliverToBoxAdapter(
                      child: _ProfileContent(
                        overview: state.overview,
                        onAvatarSelected: (file) =>
                            _bloc.add(ProfileOverviewEvent.avatarSelected(avatar: file)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.overview, required this.onAvatarSelected});

  final ProfileOverview overview;
  final ValueChanged<File> onAvatarSelected;

  Future<void> _openHelp(BuildContext context) async {
    final l10n = context.l10n;

    final topic = await showUiActionSheet<FeedbackTopic>(
      context: context,
      title: l10n.helpTitle,
      subtitle: l10n.helpSubtitle,
      cancelLabel: l10n.cancel,
      showChevron: true,
      groups: [
        [
          UiActionSheetItem(
            value: FeedbackTopic.problem,
            icon: Icons.warning_amber_rounded,
            tone: UiNavRowTone.amber,
            label: l10n.helpTopicProblem,
            subtitle: l10n.helpTopicProblemHint,
          ),
          UiActionSheetItem(
            value: FeedbackTopic.idea,
            icon: Icons.chat_bubble_outline,
            tone: UiNavRowTone.accent,
            label: l10n.helpTopicIdea,
            subtitle: l10n.helpTopicIdeaHint,
          ),
          UiActionSheetItem(
            value: FeedbackTopic.question,
            icon: Icons.help_outline,
            tone: UiNavRowTone.pine,
            label: l10n.helpTopicQuestion,
            subtitle: l10n.helpTopicQuestionHint,
          ),
        ],
      ],
    );

    if (topic != null && context.mounted) {
      unawaited(FeedbackRoute(topic: topic.name).push<void>(context));
    }
  }

  /// Нажатие на пустой круг в карточке сразу открывает выбор фото.
  Future<void> _addPhoto(BuildContext context) async {
    final action = await showProfilePhotoSheet(context, hasPhoto: false);

    if (action == null || action == ProfilePhotoAction.delete) {
      return;
    }

    try {
      final file = await pickPhoto(
        action == ProfilePhotoAction.camera ? ImageSource.camera : ImageSource.gallery,
      );

      if (file != null) {
        onAvatarSelected(file);
      }
    } catch (_) {
      if (context.mounted) {
        showUiSnackBar(context, message: context.l10n.photoPickError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = overview.profile;
    final petsCount = overview.petsCount;
    final repository = DependenciesScope.of(context).profileRepository;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        UiSpacing.x5,
        UiSpacing.x2,
        UiSpacing.x5,
        UiSpacing.x4 + ShellScope.bottomInsetOf(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiProfileCard(
            name: profile.name,
            namePlaceholder: l10n.profileNamePlaceholder,
            phone: formatPhoneForDisplay(profile.phoneNumber),
            caption: profile.hasAvatar ? l10n.profileEditCaption : l10n.profileAddPhotoCaption,
            imageUrl: profile.avatarUrl,
            isAvatarBusy: overview.isAvatarUploading,
            avatarSemanticLabel: l10n.profileAddPhotoCaption,
            onAvatarTap: profile.hasAvatar || overview.isAvatarUploading
                ? null
                : () => _addPhoto(context),
            onTap: () => EditProfileRoute($extra: profile).push<void>(context),
          ),
          const SizedBox(height: UiSpacing.x3),
          _PetsSummaryCard(
            pets: overview.pets,
            subtitle: petsCount == null ? null : l10n.petsCount(petsCount),
            onTap: () => const PetsRoute().go(context),
          ),
          const SizedBox(height: UiSpacing.x6),
          UiSectionHeader(title: l10n.profileSectionApp),
          const SizedBox(height: UiSpacing.x2),
          UiGroupedList(
            dividerIndent: UiNavRow.leadingWidth,
            children: [
              UiNavRow(
                icon: Icons.notifications_none,
                title: l10n.profileNotifications,
                value: overview.isNotificationsBlockedBySystem
                    ? l10n.profileNotificationsBlocked
                    : _notificationsSummary(context, profile.notificationSettings),
                onTap: () => const NotificationsSettingsRoute().push<void>(context),
              ),
              const ProfileThemeRow(),
            ],
          ),
          const SizedBox(height: UiSpacing.x6),
          UiSectionHeader(title: l10n.profileSectionSupport),
          const SizedBox(height: UiSpacing.x2),
          UiGroupedList(
            dividerIndent: UiNavRow.leadingWidth,
            children: [
              UiNavRow(
                icon: Icons.chat_bubble_outline,
                title: l10n.profileHelp,
                onTap: () => _openHelp(context),
              ),
              UiNavRow(
                icon: Icons.info_outline,
                title: l10n.profileAbout,
                value: repository.appVersion,
                onTap: () => const AboutRoute().push<void>(context),
              ),
            ],
          ),
          const SizedBox(height: UiSpacing.x4),
          _LogoutButton(
            label: l10n.profileLogout,
            onPressed: () => confirmAndLogout(context, phoneNumber: profile.phoneNumber),
          ),
        ],
      ),
    );
  }

  String _notificationsSummary(BuildContext context, NotificationSettingsModel settings) {
    final l10n = context.l10n;
    final total = NotificationCategory.values.length;
    final enabled = NotificationCategory.values.where(settings.isEnabled).length;

    if (enabled == total) {
      return l10n.profileNotificationsAllOn;
    }

    if (enabled == 0) {
      return l10n.profileNotificationsAllOff;
    }

    return l10n.profileNotificationsPartial(enabled, total);
  }
}

/// Карточка «Мои питомцы»: аватары питомцев внахлёст и их число.
class _PetsSummaryCard extends StatelessWidget {
  const _PetsSummaryCard({required this.pets, required this.subtitle, required this.onTap});

  static const int _maxAvatars = 3;
  static const double _avatarSize = 44;
  static const double _overlap = 14;

  final List<PetModel>? pets;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final shown = (pets ?? const <PetModel>[]).take(_maxAvatars).toList();

    return UiCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4, vertical: UiSpacing.x3),
      child: Row(
        children: [
          if (shown.isEmpty)
            const UiIconBadge(icon: Icons.pets, size: _avatarSize, iconSize: 22)
          else
            SizedBox(
              width: _avatarSize + (shown.length - 1) * (_avatarSize - _overlap),
              height: _avatarSize,
              child: Stack(
                children: [
                  for (var i = 0; i < shown.length; i++)
                    Positioned(
                      left: i * (_avatarSize - _overlap),
                      child: UiPetAvatar(
                        imageUrl: shown[i].image,
                        placeholderAsset: shown[i].petType.emptyAvatarAsset,
                        size: _avatarSize,
                        borderColor: palette.surface,
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(width: UiSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.profileMyPets,
                  style: fonts.bodySemibold.copyWith(color: palette.ink),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: fonts.monoMeta.copyWith(color: palette.ink2)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 22, color: palette.ink3),
        ],
      ),
    );
  }
}

/// «Выйти из аккаунта»: тихая текстовая кнопка отдельно от групп.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Center(
      child: Semantics(
        button: true,
        excludeSemantics: true,
        label: label,
        child: InkWell(
          onTap: onPressed,
          splashFactory: NoSplash.splashFactory,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: UiSizes.minTapTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, size: 20, color: palette.ink2),
                  const SizedBox(width: UiSpacing.x2),
                  Text(label, style: context.uiFonts.bodySemibold.copyWith(color: palette.ink)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return const UiKitShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: UiSpacing.x5, vertical: UiSpacing.x2),
        child: Column(
          children: [
            UiKitShimmerLoading(height: 96, borderRadius: UiRadius.lgAll),
            SizedBox(height: UiSpacing.x4),
            UiKitShimmerLoading(height: 64, borderRadius: UiRadius.lgAll),
            SizedBox(height: UiSpacing.x4),
            UiKitShimmerLoading(height: 192, borderRadius: UiRadius.lgAll),
          ],
        ),
      ),
    );
  }
}
