import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/create_schedule_event_bottom_sheet.dart';

/// Открывает форму редактирования вхождения и сообщает пользователю итог снекбаром.
///
/// Возвращает `true`, если изменения сохранены и список событий нужно перезагрузить
/// (у серии при «и все следующие» идентификаторы будущих вхождений поменялись).
Future<bool> editEventWithSheet({
  required BuildContext context,
  required ScheduleEventModel occurrence,
  required List<PetModel> pets,
}) async {
  final result = await showUiBottomSheet<CreateScheduleEventResult>(
    context: context,
    name: 'edit-event',
    // Закрытие свайпом обходит UiDiscardGuard.
    enableDrag: false,
    fullBleed: true,
    builder: (_) => CreateScheduleEventBottomSheet(
      date: occurrence.date,
      pets: pets,
      selectedPetId: occurrence.petId,
      editing: occurrence,
    ),
  );

  if (!context.mounted) {
    return result == CreateScheduleEventResult.success;
  }

  switch (result) {
    case CreateScheduleEventResult.success:
      showUiSnackBar(context, message: context.l10n.eventEditSaved, kind: UiSnackBarKind.success);

      return true;
    case CreateScheduleEventResult.error:
      showUiSnackBar(context, message: context.l10n.eventEditFailed);

      return false;
    case null:
      return false;
  }
}
