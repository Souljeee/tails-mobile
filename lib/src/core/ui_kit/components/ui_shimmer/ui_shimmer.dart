import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class UiKitShimmer extends StatefulWidget {
  static UiKitShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<UiKitShimmerState>();
  }

  const UiKitShimmer({super.key, this.child});

  final Widget? child;

  @override
  UiKitShimmerState createState() => UiKitShimmerState();
}

class UiKitShimmerState extends State<UiKitShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  LinearGradient get gradient => LinearGradient(
    colors: const [Color(0xFFEBEBF4), Color(0xFFF4F4F4), Color(0xFFEBEBF4)],
    stops: const [0.1, 0.3, 0.4],
    begin: const Alignment(-1.0, -0.3),
    end: const Alignment(1.0, 0.3),
    transform: _SlidingGradientTransform(
      slidePercent: _shimmerController.value,
    ),
  );

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;

  Size get size => (context.findRenderObject()! as RenderBox).size;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox?;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  Listenable get shimmerChanges => _shimmerController;

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox();
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class UiKitShimmerLoading extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadiusGeometry borderRadius;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;

  const UiKitShimmerLoading({
    required this.height,
    required this.borderRadius,
    this.width = double.infinity,
    this.alignment = AlignmentDirectional.centerStart,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  @override
  State<UiKitShimmerLoading> createState() => _UiKitShimmerLoadingState();
}

class _UiKitShimmerLoadingState extends State<UiKitShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shimmerChanges != null) {
      _shimmerChanges!.removeListener(_onShimmerChange);
    }
    _shimmerChanges = UiKitShimmer.of(context)?.shimmerChanges;
    if (_shimmerChanges != null) {
      _shimmerChanges!.addListener(_onShimmerChange);
    }
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    setState(() {
      // Update the shimmer painting.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Collect ancestor shimmer info.
    final shimmer = UiKitShimmer.of(context)!;
    if (!shimmer.isSized) {
      // The ancestor Shimmer widget has not laid
      // itself out yet. Return an empty box.
      return const SizedBox();
    }
    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    final offsetWithinShimmer = shimmer.getDescendantOffset(
      descendant: context.findRenderObject()! as RenderBox,
    );

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: Align(
        alignment: widget.alignment,
        child: Padding(
          padding: widget.padding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: context.uiColors.black5,
                  borderRadius: widget.borderRadius,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
