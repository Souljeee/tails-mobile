import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Показывает bottom sheet Design 2.0: фон `canvas`, верхние углы xl, ручка сверху.
///
/// Содержимое прокручивается и поднимается над клавиатурой.
///
/// [enableDrag] = `false` нужен листам с `UiDiscardGuard`: закрытие свайпом обходит защиту.
///
/// По умолчанию открывается в корневом навигаторе, то есть поверх нижней панели навигации.
/// Содержимое не должно зависеть от InheritedWidget'ов, которые находятся ниже корня
/// (например, от `ShellScope`).
Future<T?> showUiBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    backgroundColor: context.uiPalette.canvas,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: UiRadius.xlTop)),
    builder: (sheetContext) => _UiSheetBody(child: builder(sheetContext)),
  );
}

class _UiSheetBody extends StatelessWidget {
  const _UiSheetBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DragHandle(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(UiSpacing.x5, 0, UiSpacing.x5, UiSpacing.x4),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UiSpacing.x2),
      child: DecoratedBox(
        decoration: BoxDecoration(color: context.uiPalette.line, borderRadius: UiRadius.fullAll),
        child: const SizedBox(width: 36, height: 5),
      ),
    );
  }
}

/// Шапка sheet: слева «Отмена» (или стрелка «назад»), по центру заголовок.
class UiSheetHeader extends StatelessWidget {
  const UiSheetHeader({
    required this.title,
    required String this.cancelLabel,
    this.onCancel,
    super.key,
  }) : backLabel = null;

  /// Шапка второй страницы шторки: слева стрелка «назад».
  const UiSheetHeader.back({
    required this.title,
    required String this.backLabel,
    required VoidCallback this.onCancel,
    super.key,
  }) : cancelLabel = null;

  final String title;

  /// Подпись кнопки отмены (локализованная); `null` у варианта со стрелкой.
  final String? cancelLabel;

  /// Подпись стрелки «назад» для скринридера; `null` у варианта с «Отмена».
  final String? backLabel;

  /// По умолчанию закрывает текущий маршрут.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final onTap = onCancel ?? () => Navigator.of(context).maybePop();

    return SizedBox(
      height: UiSizes.minTapTarget,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Semantics(
                button: true,
                label: backLabel ?? cancelLabel,
                excludeSemantics: true,
                child: InkWell(
                  onTap: onTap,
                  splashFactory: NoSplash.splashFactory,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: UiSizes.minTapTarget),
                    child: Align(
                      widthFactor: 1,
                      child: backLabel != null
                          ? Icon(Icons.chevron_left_rounded, size: 28, color: palette.ink)
                          : Text(cancelLabel!, style: fonts.body.copyWith(color: palette.accent)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text(title, style: fonts.bodySemibold.copyWith(color: palette.ink)),
          const Spacer(),
        ],
      ),
    );
  }
}
