import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/navigation/shell_actions.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_tag/ui_pet_tag.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stat_strip/ui_stat_strip.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/string_extension.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_age.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_labels.dart';
import 'package:tails_mobile/src/feature/pets/pet_details/presentation/widgets/pet_upcoming_event_tile.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';

/// Содержимое карточки питомца: фото на всю ширину и «лист» с данными поверх него.
///
/// Фото закреплено за экраном: при прокрутке уезжает вверх вместе с листом, а при
/// оттягивании вниз (overscroll) растягивается, не открывая фон над собой.
class PetDetailsContent extends StatefulWidget {
  const PetDetailsContent({
    required this.pet,
    required this.upcomingEvents,
    required this.onRefresh,
    super.key,
  });

  /// Доля ширины экрана, которую занимает высота фото.
  static const double _photoHeightFactor = 0.95;

  /// Насколько «лист» заходит на фото.
  static const double _sheetOverlap = UiSpacing.x6;

  /// Сколько ближайших событий показываем в карточке.
  static const int _maxEvents = 5;

  final PetDetailsModel pet;
  final List<ScheduleEventModel> upcomingEvents;

  /// Pull-to-refresh; индикатор показывается ниже кнопок поверх фото.
  final Future<void> Function() onRefresh;

  @override
  State<PetDetailsContent> createState() => _PetDetailsContentState();
}

class _PetDetailsContentState extends State<PetDetailsContent> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final photoHeight = MediaQuery.sizeOf(context).width * PetDetailsContent._photoHeightFactor;

    return Stack(
      children: [
        ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            final offset = _controller.hasClients ? _controller.offset : 0.0;
            final stretch = offset < 0 ? -offset : 0.0;
            final shift = offset > 0 ? offset : 0.0;

            return Positioned(
              top: -shift,
              left: 0,
              right: 0,
              height: photoHeight + stretch,
              child: child!,
            );
          },
          child: CachedNetworkImage(
            imageUrl: widget.pet.image,
            fit: BoxFit.cover,
            placeholder: (context, url) => ColoredBox(color: palette.sunken),
            errorWidget: (context, url, error) => ColoredBox(
              color: palette.sunken,
              child: Icon(Icons.pets, size: 64, color: palette.ink3),
            ),
          ),
        ),
        RefreshIndicator.adaptive(
          onRefresh: widget.onRefresh,
          color: palette.accent,
          edgeOffset: MediaQuery.paddingOf(context).top + UiSizes.minTapTarget + UiSpacing.x4,
          child: SingleChildScrollView(
            controller: _controller,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: photoHeight - PetDetailsContent._sheetOverlap),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.canvas,
                    borderRadius: const BorderRadius.vertical(top: UiRadius.xlTop),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      UiSpacing.x5,
                      UiSpacing.x6,
                      UiSpacing.x5,
                      ShellScope.bottomInsetOf(context),
                    ),
                    child: _PetDetailsSheet(
                      pet: widget.pet,
                      upcomingEvents: widget.upcomingEvents
                          .take(PetDetailsContent._maxEvents)
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PetDetailsSheet extends StatelessWidget {
  const _PetDetailsSheet({required this.pet, required this.upcomingEvents});

  final PetDetailsModel pet;
  final List<ScheduleEventModel> upcomingEvents;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final isMale = pet.gender == PetSexEnum.male;
    final color = pet.color.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(pet.name.toFirstLetterUpperCase(), style: fonts.displayM.copyWith(color: palette.ink)),
        const SizedBox(height: UiSpacing.x2),
        Align(
          alignment: Alignment.centerLeft,
          child: UiPetTag(
            label: '${pet.petType.getLocalizedName(l10n)} · ${pet.breed.name}',
            color: palette.petColor(pet.colorIndex),
          ),
        ),
        const SizedBox(height: UiSpacing.x5),
        UiStatStrip(
          items: [
            UiStatItem(
              label: l10n.petDetailsAge,
              value: formatPetAgeShort(l10n, PetAge.fromBirthday(pet.birthday)),
            ),
            UiStatItem(label: l10n.weight, value: formatPetWeightLabel(l10n, pet.weight)),
            UiStatItem(label: l10n.gender, value: isMale ? l10n.petSexMale : l10n.petSexFemale),
          ],
        ),
        const SizedBox(height: UiSpacing.x6),
        UiSectionHeader(
          title: l10n.petFormMain,
          actionLabel: l10n.petDetailsEdit,
          onActionTap: () => EditPetRoute($extra: pet).push<void>(context),
        ),
        const SizedBox(height: UiSpacing.x3),
        UiGroupedList(
          children: [
            UiInfoRow(
              icon: Icons.cake_outlined,
              label: l10n.birthday,
              value: DateFormat('dd.MM.yyyy').format(pet.birthday),
            ),
            UiInfoRow(icon: Icons.badge_outlined, label: l10n.breed, value: pet.breed.name),
            if (color.isNotEmpty)
              UiInfoRow(icon: Icons.palette_outlined, label: l10n.color, value: color),
            if (pet.hasCastration)
              UiInfoRow(
                icon: Icons.verified_user_outlined,
                label: l10n.status,
                value: isMale ? l10n.petCastratedMale : l10n.petCastratedFemale,
              ),
          ],
        ),
        const SizedBox(height: UiSpacing.x6),
        UiSectionHeader(
          title: l10n.petDetailsUpcoming,
          actionLabel: l10n.all,
          onActionTap: () {
            // Календарь откроется с фильтром по этому питомцу.
            ShellScope.maybeOf(context)?.controller.requestScheduleFilter(pet.id);
            const ScheduleRoute().go(context);
          },
        ),
        const SizedBox(height: UiSpacing.x3),
        if (upcomingEvents.isEmpty)
          Text(l10n.petDetailsNoEvents, style: fonts.body.copyWith(color: palette.ink2))
        else
          for (final event in upcomingEvents) ...[
            PetUpcomingEventTile(
              // Слоты «несколько раз в день» — записи с одним id и датой, различаются временем.
              key: ValueKey('${event.id}_${event.date}_${event.time}'),
              event: event,
              petImage: pet.image,
              petColor: palette.petColor(pet.colorIndex),
            ),
            const SizedBox(height: UiSpacing.x3),
          ],
      ],
    );
  }
}
