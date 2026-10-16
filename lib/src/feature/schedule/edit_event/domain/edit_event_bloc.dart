import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/edit_occurrence_result.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/schedule/edit_event/domain/edit_changes.dart';

part 'edit_event_event.dart';
part 'edit_event_state.dart';

/// Сохранение изменений вхождения: «только эта дата» (переопределение полей) или «эта дата и все
/// следующие» (разделение серии либо обычное обновление одиночного события).
class EditEventBloc extends Bloc<EditEventEvent, EditEventState> {
  EditEventBloc({required ScheduleRepository scheduleRepository})
    : _scheduleRepository = scheduleRepository,
      super(const EditEventState.idle()) {
    on<EditEventEvent>(
      (event, emit) => event.map(saveRequested: (event) => _onSaveRequested(event, emit)),
    );
  }

  static const String _logSource = 'EditEventBloc';

  final ScheduleRepository _scheduleRepository;

  Future<void> _onSaveRequested(
    EditEventEvent$SaveRequested event,
    Emitter<EditEventState> emit,
  ) async {
    emit(const EditEventState.loading());

    try {
      final occurrence = event.occurrence;
      final model = event.model;

      final result = switch (event.scope) {
        OccurrenceScope.one => await _scheduleRepository.editOccurrenceFields(
          occurrence.ref,
          title: event.changes.fields.contains(EditedField.title) ? model.title.trim() : null,
          description: event.changes.fields.contains(EditedField.description)
              ? (model.description ?? '').trim()
              : null,
          type: event.changes.fields.contains(EditedField.type) ? model.type : null,
          time: event.changes.fields.contains(EditedField.time) ? model.time : null,
          reminder: event.changes.fields.contains(EditedField.reminder)
              ? CopyWithWrapper.value(model.reminder)
              : null,
        ),
        OccurrenceScope.future => await _scheduleRepository.editOccurrenceAndFollowing(
          occurrence.ref,
          model,
        ),
      };

      TailsAnalytics.log(TailsAnalyticsEvents.eventEdited(scope: event.scope.apiValue));
      TailsLogger.info(
        'Событие изменено',
        source: _logSource,
        data: {'scope': event.scope.apiValue, 'split': result.isSplit},
      );

      emit(EditEventState.success(result));
    } catch (e, s) {
      addError(e, s);

      emit(const EditEventState.error());
    }
  }
}
