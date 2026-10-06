import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_photo/ui_pet_photo.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_tag/ui_pet_tag.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/event_day_label.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_age.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_labels.dart';
import 'package:tails_mobile/src/feature/pets/pets_overview/domain/models/pets_overview.dart';

/// Карточка питомца: фото, тег вида, имя, краткая строка данных и ближайшее событие.
class PetOverviewCard extends StatelessWidget {
  const PetOverviewCard({
    required this.overview,
    required this.petColor,
    required this.onTap,
    super.key,
  });

  /// Соотношение сторон фото.
  static const double _photoAspectRatio = 16 / 10;

  final PetOverview overview;

  /// Цвет питомца для точки в теге.
  final Color petColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final pet = overview.pet;

    final metaParts = [
      pet.breed.name,
      formatPetAgeShort(l10n, PetAge.fromBirthday(pet.birthday)),
      if (pet.weight != null) formatPetWeightLabel(l10n, pet.weight!),
    ];

    return UiCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: UiRadius.lgTop),
                child: AspectRatio(
                  aspectRatio: _photoAspectRatio,
                  child: UiPetPhoto(
                    imageUrl: pet.image,
                    placeholderAsset: pet.petType.emptyAvatarAsset,
                  ),
                ),
              ),
              Positioned(
                left: UiSpacing.x3,
                bottom: UiSpacing.x3,
                child: UiPetTag(label: pet.petType.getLocalizedName(l10n), color: petColor),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(UiSpacing.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: fonts.displayS.copyWith(color: palette.ink),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: palette.ink3),
                  ],
                ),
                const SizedBox(height: UiSpacing.x1),
                Text(metaParts.join(' · '), style: fonts.monoMeta.copyWith(color: palette.ink2)),
                if (overview.nextEvent != null) ...[
                  const SizedBox(height: UiSpacing.x3),
                  Divider(height: 1, thickness: 1, color: palette.line),
                  const SizedBox(height: UiSpacing.x3),
                  _NextEventRow(nextEvent: overview.nextEvent!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextEventRow extends StatelessWidget {
  const _NextEventRow({required this.nextEvent});

  final PetNextEvent nextEvent;

  String _eyebrow(BuildContext context) => formatEventDayLabel(
    l10n: context.l10n,
    locale: Localizations.localeOf(context).toString(),
    date: nextEvent.date,
    now: DateTime.now(),
    isAllDay: nextEvent.event.time == null,
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final event = nextEvent.event;
    final time = event.time;
    final line = time == null ? event.title : '${time.substring(0, 5)} · ${event.title}';

    return Row(
      children: [
        UiIconBadge(icon: event.type.icon),
        const SizedBox(width: UiSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _eyebrow(context).toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: fonts.monoEyebrow.copyWith(color: palette.ink3),
              ),
              Text(
                line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: fonts.bodyBold.copyWith(color: palette.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
