import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/string_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/pet_details/domain/pet_details_bloc.dart';

class PetDetailsScreen extends StatefulWidget {
  final int id;

  const PetDetailsScreen({
    required this.id,
    super.key,
  });

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  static const _imageHeight = 320.0;
  static const _overlap = 28.0;

  double _scrollOffset = 0;

  late final PetDetailsBloc _petDetailsBloc =
      PetDetailsBloc(petRepository: DependenciesScope.of(context).petRepository);

  @override
  void initState() {
    super.initState();
    _petDetailsBloc.add(PetDetailsEvent.fetchRequested(id: widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final theme = Theme.of(context);

    // Высота фото с учётом overscroll (растягивается при тяге вниз).
    final extraStretch = _scrollOffset < 0 ? -_scrollOffset : 0.0;
    final currentImageHeight = _imageHeight + extraStretch;

    // Прогресс схлопывания (1 = фото видно, 0 = фото скрыто).
    final collapseMax = _imageHeight - topPadding - kToolbarHeight;
    final t = (1 - _scrollOffset / collapseMax).clamp(0.0, 1.0);

    // Позиция имени на экране:
    // верх карточки = (_imageHeight - _overlap) - _scrollOffset
    // + padding сверху в карточке (18)
    // Имя "ушло" под аппбар, когда эта позиция < topPadding + kToolbarHeight.
    const cardTopPadding = 18.0;
    const nameApproxHeight = 36.0; // примерная высота текста имени
    final nameTopOnScreen = (_imageHeight - _overlap + cardTopPadding) - _scrollOffset;
    final appBarBottom = topPadding + kToolbarHeight;
    final showTitleInAppBar = nameTopOnScreen + nameApproxHeight < appBarBottom;

    return BlocBuilder<PetDetailsBloc, PetDetailsState>(
      bloc: _petDetailsBloc,
      builder: (context, state) {
        return state.map(
          loading: (_) => const SizedBox.shrink(),
          success: (state) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  // ── 1. Фоновое изображение ──
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: currentImageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          state.petData.image,
                          fit: BoxFit.cover,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x66000000),
                                Color(0x00000000),
                                Color(0x00000000),
                                Color(0x99000000),
                              ],
                              stops: [0, 0.25, 0.7, 1],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── 2. Скроллируемый контент ──
                  NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      setState(() => _scrollOffset = n.metrics.pixels);
                      return false;
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      child: Column(
                        children: [
                          // Прозрачный отступ — равен высоте фото минус overlap.
                          const SizedBox(height: _imageHeight - _overlap),

                          // Карточка с информацией.
                          // ClipRect обрезает тень снизу, оставляя только верхнюю.
                          ClipRect(
                            clipper: const _TopShadowClipper(shadowExtent: 22),
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: 20,
                                    offset: Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.petData.name.toFirstLetterUpperCase(),
                                      style: context.uiFonts.header28Semibold.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _InfoGrid(
                                      petTypeEnum: state.petData.petType,
                                      breedModel: state.petData.breed,
                                      petSexEnum: state.petData.gender,
                                      weight: state.petData.weight,
                                    ),
                                    const SizedBox(height: 14),
                                    _PillRow(
                                      icon: Icons.cake_outlined,
                                      title: context.l10n.birthday,
                                      value: _getFormattedBirthDate(state.petData.birthday),
                                    ),
                                    const SizedBox(height: 10),
                                    _PillRow(
                                      icon: Icons.palette_outlined,
                                      title: context.l10n.color,
                                      value: state.petData.color,
                                    ),
                                    const SizedBox(height: 10),
                                    _PillRow(
                                      icon: Icons.verified_user_outlined,
                                      title: context.l10n.status,
                                      value: context.l10n.sterilized,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 3. Верхняя панель (back + edit + title), всегда поверх ──
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      color: t < 0.05 ? Colors.white : Colors.transparent,
                      child: SafeArea(
                        bottom: false,
                        child: SizedBox(
                          height: kToolbarHeight,
                          child: Row(
                            children: [
                              const SizedBox(width: 4),
                              _CircleIconButton(
                                icon: Icons.arrow_back,
                                onPressed: () => Navigator.maybePop(context),
                              ),
                              Expanded(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: showTitleInAppBar ? 1.0 : 0.0,
                                  child: Text(
                                    state.petData.name.toFirstLetterUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111111),
                                    ),
                                  ),
                                ),
                              ),
                              _CircleIconButton(
                                icon: Icons.delete_outline,
                                onPressed: () {},
                              ),
                              _CircleIconButton(
                                icon: Icons.edit,
                                onPressed: () {},
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          error: (_) => const SizedBox.shrink(),
        );
      },
    );
  }

  String _getFormattedBirthDate(DateTime birthday) {
    final String date = DateFormat('dd.MM.yyyy').format(birthday);

    final buffer = StringBuffer(date);

    final age = DateTime.now().difference(birthday).inDays;

    final years = age ~/ 365;
    final months = (age % 365) ~/ 30;

    if (years > 0) {
      buffer.write(' (${context.l10n.petAgeYearsAndMonths(years, months)})');
    } else {
      buffer.write(' (${context.l10n.petAgeMonths(months)})');
    }

    return buffer.toString();
  }
}

// ── Вспомогательные виджеты ──

/// Обрезает область отрисовки так, что тень видна только сверху.
/// [shadowExtent] — насколько выше виджета нужно оставить место для тени.
class _TopShadowClipper extends CustomClipper<Rect> {
  final double shadowExtent;

  const _TopShadowClipper({required this.shadowExtent});

  @override
  Rect getClip(Size size) {
    // Расширяем прямоугольник вверх на shadowExtent, но не вниз.
    return Rect.fromLTRB(
      -shadowExtent, // чуть шире по бокам (для blur)
      -shadowExtent, // выше — для тени сверху
      size.width + shadowExtent,
      size.height, // ровно по нижнему краю — тень снизу обрезана
    );
  }

  @override
  bool shouldReclip(covariant _TopShadowClipper oldClipper) =>
      shadowExtent != oldClipper.shadowExtent;
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: DecoratedBox(
        decoration: BoxDecoration(
          color: context.uiColors.black5,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: context.uiColors.black100,
          ),
        ),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final PetTypeEnum petTypeEnum;
  final BreedModel breedModel;
  final PetSexEnum petSexEnum;
  final double weight;

  const _InfoGrid({
    required this.petTypeEnum,
    required this.breedModel,
    required this.petSexEnum,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.pets_outlined,
                title: context.l10n.type,
                value: petTypeEnum.getLocalizedName(context.l10n),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                icon: Icons.badge_outlined,
                title: context.l10n.breed,
                value: breedModel.name,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.male,
                title: context.l10n.gender,
                value: petSexEnum.fullName,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                icon: Icons.bar_chart_outlined,
                title: context.l10n.weight,
                value: '$weight кг',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.uiColors.black5,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.uiColors.black20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.uiColors.orangePrimary),
          const SizedBox(height: 10),
          Text(
            title.toUpperCase(),
            style: context.uiFonts.text12Regular.copyWith(
              color: context.uiColors.black50,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.uiFonts.text16Semibold.copyWith(
              color: context.uiColors.black100,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _PillRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.uiColors.black5,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.uiColors.black20),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.uiColors.orangePrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: context.uiFonts.text12Regular.copyWith(
                    color: context.uiColors.black50,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.uiFonts.text16Semibold.copyWith(
                    color: context.uiColors.black100,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
