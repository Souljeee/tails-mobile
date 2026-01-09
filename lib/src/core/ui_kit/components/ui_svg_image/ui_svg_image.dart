import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UiSvgImage extends StatelessWidget {
  final String svgPath;

  final Color? color;

  final double height;

  final double width;

  const UiSvgImage({
    required this.svgPath,
    super.key,
    this.color,
    this.height = 24,
    this.width = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgPath,
      height: height,
      width: width,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
