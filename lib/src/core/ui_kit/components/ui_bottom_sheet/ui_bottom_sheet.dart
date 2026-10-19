import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Показывает bottom sheet Design 2.0: фон `canvas`, верхние углы xl, ручка сверху.
///
/// Содержимое прокручивается и поднимается над клавиатурой.
///
/// Шторка закрывается свайпом вниз. При [enableDrag] = `true` тянуть можно за любое место,
/// при `false` — только за ручку, и закрытие идёт через `Navigator.maybePop`: так его
/// перехватывает `UiDiscardGuard`. Листам с `UiDiscardGuard` нужен именно `false`, потому что
/// системный свайп по всему листу закрывает его в обход защиты.
///
/// [fullBleed] = `true` убирает у шторки боковые и нижние отступы и нижнюю безопасную зону:
/// содержимое само задаёт поля и может занять всю ширину (например, нижняя панель барабана,
/// доходящая до края экрана). Нижнюю безопасную зону такое содержимое учитывает само.
///
/// По умолчанию открывается в корневом навигаторе, то есть поверх нижней панели навигации.
/// Содержимое не должно зависеть от InheritedWidget'ов, которые находятся ниже корня
/// (например, от `ShellScope`).
///
/// [name] — имя шторки в журнале навигации (например, `confirm`); на внешний вид не влияет.
Future<T?> showUiBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
  bool fullBleed = false,
  String? name,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    routeSettings: name == null ? null : RouteSettings(name: name),
    // Фон рисует сам лист, чтобы он сдвигался вместе с содержимым при свайпе за ручку.
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (sheetContext) =>
        _UiSheetBody(fullBleed: fullBleed, dragToPop: !enableDrag, child: builder(sheetContext)),
  );
}

class _UiSheetBody extends StatefulWidget {
  const _UiSheetBody({required this.child, required this.fullBleed, required this.dragToPop});

  final Widget child;
  final bool fullBleed;

  /// Ручка сама обрабатывает свайп и закрывает лист через `Navigator.maybePop`.
  final bool dragToPop;

  @override
  State<_UiSheetBody> createState() => _UiSheetBodyState();
}

class _UiSheetBodyState extends State<_UiSheetBody> with SingleTickerProviderStateMixin {
  /// Как у системной шторки: быстрый свайп вниз закрывает лист с любого места.
  static const double _minFlingVelocity = 700;

  /// Доля высоты листа, после которой отпущенный лист закрывается.
  static const double _closeThreshold = 0.5;

  /// Смещение листа вниз при свайпе за ручку, в логических пикселях.
  late final AnimationController _dragOffset = AnimationController.unbounded(vsync: this);

  @override
  void dispose() {
    _dragOffset.dispose();

    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final offset = _dragOffset.value + details.primaryDelta!;
    _dragOffset.value = offset < 0 ? 0 : offset;
  }

  void _onDragEnd(DragEndDetails details) {
    final height = context.size?.height ?? 0;
    final shouldClose =
        details.velocity.pixelsPerSecond.dy > _minFlingVelocity ||
        (height > 0 && _dragOffset.value > height * _closeThreshold);

    if (!shouldClose) {
      _settleBack();

      return;
    }

    if (ModalRoute.of(context)?.popDisposition == RoutePopDisposition.doNotPop) {
      // Закрытие перехватит PopScope (например, UiDiscardGuard): лист возвращается на место.
      _settleBack();
      Navigator.of(context).maybePop();

      return;
    }

    // Лист уезжает вниз с того места, куда его дотянули.
    Navigator.of(context).pop();
  }

  void _settleBack() => _dragOffset.animateTo(0, duration: UiMotion.base, curve: UiMotion.curve);

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DragHandle(
          onDragUpdate: widget.dragToPop ? _onDragUpdate : null,
          onDragEnd: widget.dragToPop ? _onDragEnd : null,
          onDragCancel: widget.dragToPop ? _settleBack : null,
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: widget.fullBleed
                ? EdgeInsets.zero
                : const EdgeInsets.fromLTRB(UiSpacing.x5, 0, UiSpacing.x5, UiSpacing.x4),
            child: widget.child,
          ),
        ),
      ],
    );

    return AnimatedBuilder(
      animation: _dragOffset,
      builder: (context, child) =>
          Transform.translate(offset: Offset(0, _dragOffset.value), child: child),
      child: Material(
        color: context.uiPalette.canvas,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: UiRadius.xlTop),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: widget.fullBleed ? content : SafeArea(top: false, child: content),
        ),
      ),
    );
  }
}

/// Ручка листа. Область касания — вся ширина листа; если заданы обработчики свайпа, ручка
/// перехватывает вертикальный свайп сама.
class _DragHandle extends StatelessWidget {
  const _DragHandle({this.onDragUpdate, this.onDragEnd, this.onDragCancel});

  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;
  final GestureDragCancelCallback? onDragCancel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: onDragEnd,
      onVerticalDragCancel: onDragCancel,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: UiSpacing.x2),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.uiPalette.line,
              borderRadius: UiRadius.fullAll,
            ),
            child: const SizedBox(width: 36, height: 5),
          ),
        ),
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

  /// Резерв под кнопку слева и симметрично справа: длинный заголовок обрезается, а не переполняет.
  static const double _titleInset = UiSpacing.x12 + UiSpacing.x6;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final onTap = onCancel ?? () => Navigator.of(context).maybePop();

    // Шапка всегда во всю ширину: в Column без stretch Stack иначе сжимается до ширины
    // заголовка, и «Отмена» оказывается рядом с ним, а не у левого края.
    return SizedBox(
      width: double.infinity,
      height: UiSizes.minTapTarget,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _titleInset),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: fonts.bodySemibold.copyWith(color: palette.ink),
            ),
          ),
        ],
      ),
    );
  }
}
