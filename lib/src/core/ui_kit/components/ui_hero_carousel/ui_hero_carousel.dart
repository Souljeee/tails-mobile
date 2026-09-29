import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Слайд карусели: фото, заголовок и пояснение.
class UiHeroSlide {
  const UiHeroSlide({required this.image, required this.title, required this.subtitle});

  final ImageProvider image;
  final String title;
  final String subtitle;
}

/// Фото-карусель с нижними скруглёнными углами и индикатором страниц (экран входа).
///
/// Занимает всё выделенное родителем пространство.
class UiHeroCarousel extends StatefulWidget {
  const UiHeroCarousel({required this.slides, super.key});

  final List<UiHeroSlide> slides;

  @override
  State<UiHeroCarousel> createState() => _UiHeroCarouselState();
}

class _UiHeroCarouselState extends State<UiHeroCarousel> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: UiRadius.xlTop),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            itemBuilder: (context, index) => _HeroSlide(slide: widget.slides[index]),
          ),
          Positioned(
            left: UiSpacing.x5,
            bottom: UiSpacing.x5,
            child: SmoothPageIndicator(
              controller: _controller,
              count: widget.slides.length,
              effect: ExpandingDotsEffect(
                dotWidth: 6,
                dotHeight: 6,
                activeDotColor: Colors.white,
                dotColor: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSlide extends StatelessWidget {
  const _HeroSlide({required this.slide});

  final UiHeroSlide slide;

  @override
  Widget build(BuildContext context) {
    final fonts = context.uiFonts;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image(image: slide.image, fit: BoxFit.cover),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x66000000), Color(0x00000000), Color(0x99000000)],
              stops: [0, 0.4, 1],
            ),
          ),
        ),
        Positioned(
          left: UiSpacing.x5,
          right: UiSpacing.x5,
          bottom: UiSpacing.x5 + UiSpacing.x6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(slide.title, style: fonts.displayS.copyWith(color: Colors.white)),
              const SizedBox(height: UiSpacing.x2),
              Text(slide.subtitle, style: fonts.body.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
