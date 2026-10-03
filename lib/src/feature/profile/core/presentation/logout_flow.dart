import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_sheets/ui_confirm_sheet.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/phone_format.dart';
import 'package:tails_mobile/src/feature/auth/presentation/auth_scope.dart';

/// Спрашивает подтверждение и выходит из аккаунта. [phoneNumber] — номер так, как его хранит
/// сервер: он показывается в пояснении, чтобы было понятно, по какому номеру войти снова.
Future<void> confirmAndLogout(BuildContext context, {required String phoneNumber}) async {
  final l10n = context.l10n;
  final phone = formatPhoneForDisplay(phoneNumber);

  final confirmed = await showUiConfirmSheet(
    context: context,
    title: l10n.profileLogoutTitle,
    message: l10n.profileLogoutMessage(phone),
    highlight: phone,
    confirmLabel: l10n.profileLogoutConfirm,
    cancelLabel: l10n.cancel,
  );

  if (confirmed && context.mounted) {
    AuthScope.of(context, listen: false).logout();
  }
}
