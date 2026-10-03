import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/auth/presentation/auth_scope.dart';

/// Шаг 3: аккаунт удалён. Назад вернуться нельзя — остаётся только перейти ко входу.
class AccountDeletedScreen extends StatefulWidget {
  const AccountDeletedScreen({super.key});

  @override
  State<AccountDeletedScreen> createState() => _AccountDeletedScreenState();
}

class _AccountDeletedScreenState extends State<AccountDeletedScreen> {
  @override
  void initState() {
    super.initState();

    // Сервер уже закрыл все сессии. Забываем токены, когда экран показан: пока он
    // открыт, навигация не уводит пользователя на вход (см. охрану маршрутов).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AuthScope.of(context, listen: false).accountDeleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: palette.canvas,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(UiSpacing.x5),
            child: Column(
              children: [
                const Spacer(),
                UiIconBadge(
                  icon: Icons.check_rounded,
                  size: 80,
                  iconSize: 40,
                  foregroundColor: palette.pine,
                  backgroundColor: palette.pineTint,
                ),
                const SizedBox(height: UiSpacing.x5),
                Text(
                  l10n.accountDeletedTitle,
                  textAlign: TextAlign.center,
                  style: fonts.displayS.copyWith(color: palette.ink),
                ),
                const SizedBox(height: UiSpacing.x2),
                Text(
                  l10n.accountDeletedMessage,
                  textAlign: TextAlign.center,
                  style: fonts.body.copyWith(color: palette.ink2),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: UiButton.main(
                    label: l10n.accountDeletedButton,
                    onPressed: () => const AuthRoute().go(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
