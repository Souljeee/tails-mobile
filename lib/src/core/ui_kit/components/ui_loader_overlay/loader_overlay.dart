import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class _BaseLoader extends StatelessWidget {
  const _BaseLoader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: context.uiColors.white.withValues(alpha: 0.5),
          ),
        ),
        Center(
          child: SizedBox.square(
            dimension: 80,
            child: CircularProgressIndicator(color: context.uiColors.orangePrimary),
          ),
        ),
      ],
    );
  }
}

abstract class LoaderController {
  void showLoader();
  void hideLoader();
}

class LoaderOverlay extends StatefulWidget {
  final Widget child;

  const LoaderOverlay({
    required this.child,
    super.key,
  });

  static LoaderController of(BuildContext context) {
    final loaderOverlay = context.dependOnInheritedWidgetOfExactType<_InheritedLoaderOverlay>();

    assert(loaderOverlay != null, 'No LoaderOverlay found in context');

    return loaderOverlay!.loaderController;
  }

  @override
  State<LoaderOverlay> createState() => _LoaderOverlayState();
}

class _LoaderOverlayState extends State<LoaderOverlay> implements LoaderController {
  OverlayEntry? _loaderOverlay;

  @override
  void showLoader() {
    final overlay = Overlay.of(context);

    if (_loaderOverlay != null) {
      return;
    }

    _loaderOverlay = OverlayEntry(builder: (context) => const _BaseLoader());

    overlay.insert(_loaderOverlay!);
  }

  @override
  void hideLoader() {
    if (_loaderOverlay == null) {
      return;
    }

    _loaderOverlay?.remove();
    _loaderOverlay?.dispose();
    _loaderOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedLoaderOverlay(
      loaderController: this,
      loaderOverlay: _loaderOverlay,
      child: widget.child,
    );
  }
}

class _InheritedLoaderOverlay extends InheritedWidget {
  final LoaderController loaderController;
  final OverlayEntry? loaderOverlay;

  const _InheritedLoaderOverlay({
    required this.loaderController,
    required this.loaderOverlay,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedLoaderOverlay oldWidget) =>
      loaderController != oldWidget.loaderController || loaderOverlay != oldWidget.loaderOverlay;
}
