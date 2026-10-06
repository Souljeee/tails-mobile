import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

/// Защищает форму от случайного закрытия.
///
/// Пока [hasChanges] равно `true`, любая попытка закрыть экран (кнопка «Отмена»,
/// системный «назад», жест «назад» на iOS, тап по затемнению) сначала показывает вопрос
/// «Закрыть без сохранения?». Программное `Navigator.pop` (например, после успешного
/// сохранения) вопрос не вызывает.
class UiDiscardGuard extends StatelessWidget {
  const UiDiscardGuard({
    required this.hasChanges,
    required this.child,
    this.onDiscarded,
    super.key,
  });

  final bool hasChanges;
  final Widget child;

  /// Вызывается, когда пользователь подтвердил закрытие без сохранения (для аналитики).
  final VoidCallback? onDiscarded;

  Future<void> _onPopBlocked(BuildContext context) async {
    final discard = await showUiDiscardSheet(context);

    if (discard && context.mounted) {
      onDiscarded?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onPopBlocked(context);
        }
      },
      child: child,
    );
  }
}

/// Показывает вопрос «Закрыть без сохранения?». Возвращает `true`, если пользователь
/// подтвердил закрытие.
Future<bool> showUiDiscardSheet(BuildContext context) async {
  final result = await showUiBottomSheet<bool>(
    context: context,
    name: 'discard-changes',
    builder: (_) => const _DiscardSheet(),
  );

  return result ?? false;
}

class _DiscardSheet extends StatelessWidget {
  const _DiscardSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Column(
      children: [
        UiIconBadge(
          icon: Icons.edit_off_outlined,
          size: 64,
          iconSize: 28,
          foregroundColor: palette.danger,
          backgroundColor: palette.dangerTint,
        ),
        const SizedBox(height: UiSpacing.x5),
        Text(
          l10n.discardTitle,
          style: fonts.displayS.copyWith(color: palette.ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UiSpacing.x2),
        Text(
          l10n.discardMessage,
          style: fonts.body.copyWith(color: palette.ink2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UiSpacing.x6),
        Row(
          children: [
            Expanded(
              child: UiButton.secondary(
                label: l10n.discardKeepEditing,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: UiSpacing.x3),
            Expanded(
              child: UiButton.main(
                label: l10n.discardConfirm,
                staticFillColor: palette.danger,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
