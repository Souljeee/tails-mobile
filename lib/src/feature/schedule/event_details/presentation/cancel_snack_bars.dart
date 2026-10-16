import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/event_actions_bloc.dart';

/// Время показа снекбара «Вернуть»: совпадает с задержкой отправки отмены в [EventActionsBloc].
const Duration kCancelUndoDuration = Duration(seconds: 6);

/// Показывает снекбар «Событие отменено» с кнопкой «Вернуть».
///
/// «Вернуть» откатывает отмену без запроса. Если снекбар закрылся сам, его смахнули или показан
/// другой, а отмена всё ещё ждёт отправки, запрос уходит сразу.
void showCancelUndoSnackBar(
  BuildContext context, {
  required EventActionsBloc bloc,
  required EventActionEffect$CancelApplied effect,
}) {
  final l10n = context.l10n;
  final controller = showUiSnackBar(
    context,
    message: effect.scope == OccurrenceScope.future
        ? l10n.eventsCancelledSnack
        : l10n.eventCancelledSnack,
    kind: UiSnackBarKind.info,
    actionLabel: l10n.eventCancelUndo,
    duration: kCancelUndoDuration,
    onAction: () => bloc.add(const EventActionsEvent.undoRequested()),
  );

  unawaited(
    controller.closed.then((reason) {
      final pending = bloc.state.pending;

      // Если на место снекбара пришла следующая отмена, ожидает уже другое вхождение:
      // первое к этому моменту отправлено блоком, второе не трогаем.
      if (!bloc.isClosed &&
          reason != SnackBarClosedReason.action &&
          pending != null &&
          pending.occurrence == effect.occurrence &&
          pending.scope == effect.scope) {
        bloc.add(const EventActionsEvent.flushRequested());
      }
    }),
  );
}

/// Снекбар «Не удалось отменить. Повторить».
void showCancelFailedSnackBar(
  BuildContext context, {
  required EventActionsBloc bloc,
  required EventActionEffect$CancelFailed effect,
}) {
  final l10n = context.l10n;

  showUiSnackBar(
    context,
    message: l10n.eventCancelFailed,
    actionLabel: l10n.eventActionRetry,
    onAction: () => bloc.add(
      EventActionsEvent.cancelRequested(occurrence: effect.occurrence, scope: effect.scope),
    ),
  );
}
