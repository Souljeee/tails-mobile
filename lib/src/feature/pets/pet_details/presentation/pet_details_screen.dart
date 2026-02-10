import 'package:flutter/material.dart';

class PetDetailsScreen extends StatefulWidget {
  const PetDetailsScreen({super.key});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  static const _imageHeight = 320.0;
  static const _overlap = 28.0;

  double _scrollOffset = 0;

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
    final nameTopOnScreen =
        (_imageHeight - _overlap + cardTopPadding) - _scrollOffset;
    final appBarBottom = topPadding + kToolbarHeight;
    final showTitleInAppBar = nameTopOnScreen + nameApproxHeight < appBarBottom;

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
                  'https://images.unsplash.com/photo-1543852786-1cf6624b9987'
                  '?auto=format&fit=crop&w=1200&q=80',
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
                  SizedBox(height: _imageHeight - _overlap),

                  // Карточка с информацией.
                  // ClipRect обрезает тень снизу, оставляя только верхнюю.
                  ClipRect(
                    clipper: const _TopShadowClipper(shadowExtent: 22),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
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
                          const _Header(
                            name: 'Барсик',
                            status: 'Активен',
                            id: '482910',
                          ),
                          const SizedBox(height: 18),
                          const _InfoGrid(),
                          const SizedBox(height: 14),
                          const _PillRow(
                            icon: Icons.cake_outlined,
                            title: 'Дата рождения',
                            value: '12.05.2021 (3 года)',
                          ),
                          const SizedBox(height: 10),
                          const _PillRow(
                            icon: Icons.palette_outlined,
                            title: 'Окрас',
                            value: 'Рыжий мраморный',
                          ),
                          const SizedBox(height: 10),
                          const _PillRow(
                            icon: Icons.verified_user_outlined,
                            title: 'Статус',
                            value: 'Кастрирован',
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
                            'Барсик',
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
      -shadowExtent,  // чуть шире по бокам (для blur)
      -shadowExtent,  // выше — для тени сверху
      size.width + shadowExtent,
      size.height,    // ровно по нижнему краю — тень снизу обрезана
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
        decoration: const BoxDecoration(
          color: Color(0xE6FFFFFF),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: const Color(0xFF1A1A1A)),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String status;
  final String id;

  const _Header({
    required this.name,
    required this.status,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE7D1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                status,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFFDA8A3A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'ID: $id',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFF8A8A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.pets_outlined,
                title: 'Тип',
                value: 'Кошка',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                icon: Icons.badge_outlined,
                title: 'Порода',
                value: 'Мейн-кун',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.male,
                title: 'Пол',
                value: 'Кошка',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                icon: Icons.bar_chart_outlined,
                title: 'Вес',
                value: 'Мейн-кун',
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0EDE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFDA8A3A)),
          const SizedBox(height: 10),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF9A9A9A),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0EDE7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFDA8A3A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF9A9A9A),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
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

class _SwitchRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool initialValue;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.initialValue,
  });

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0EDE7)),
      ),
      child: Row(
        children: [
          Icon(widget.icon, color: const Color(0xFFDA8A3A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF9A9A9A),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
            activeColor: const Color(0xFFDA8A3A),
          ),
        ],
      ),
    );
  }
}
