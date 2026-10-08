import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/notification_settings_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';

part 'notifications_settings_event.dart';
part 'notifications_settings_state.dart';

class NotificationsSettingsBloc
    extends Bloc<NotificationsSettingsEvent, NotificationsSettingsState> {
  NotificationsSettingsBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const NotificationsSettingsState()) {
    on<NotificationsSettingsEvent>(
      (event, emit) => event.map(
        started: (event) => _onStarted(event, emit),
        systemStatusChecked: (event) => _onSystemStatusChecked(event, emit),
        toggled: (event) => _onToggled(event, emit),
        openSettingsRequested: (event) => _onOpenSettingsRequested(event, emit),
      ),
    );
  }

  final ProfileRepository _profileRepository;

  Future<void> _onStarted(
    NotificationsSettingsEvent$Started event,
    Emitter<NotificationsSettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(status: NotificationsSettingsStatus.loading));

      final blockedFuture = _loadBlockedBySystem();
      final settings = await _profileRepository.getNotificationSettings();

      emit(
        state.copyWith(
          status: NotificationsSettingsStatus.ready,
          settings: settings,
          isBlockedBySystem: await blockedFuture,
        ),
      );
    } catch (e, s) {
      addError(e, s);

      emit(state.copyWith(status: NotificationsSettingsStatus.failure));
    }
  }

  Future<void> _onSystemStatusChecked(
    NotificationsSettingsEvent$SystemStatusChecked event,
    Emitter<NotificationsSettingsState> emit,
  ) async {
    final blocked = await _loadBlockedBySystem();

    if (blocked != state.isBlockedBySystem) {
      emit(state.copyWith(isBlockedBySystem: blocked));
    }
  }

  Future<void> _onToggled(
    NotificationsSettingsEvent$Toggled event,
    Emitter<NotificationsSettingsState> emit,
  ) async {
    final current = state.settings;
    final category = event.category;

    if (current == null || state.savingCategories.contains(category)) {
      return;
    }

    // Переключатель реагирует сразу; если сервер откажет, вернём прежнее значение.
    emit(
      state.copyWith(
        settings: current.copyWith(category: category, value: event.enabled),
        savingCategories: {...state.savingCategories, category},
      ),
    );

    try {
      final confirmed = await _profileRepository.setNotificationEnabled(
        category: category,
        enabled: event.enabled,
      );

      TailsAnalytics.log(
        TailsAnalyticsEvents.notificationSettingChanged(
          setting: category.apiKey,
          enabled: event.enabled,
        ),
      );

      emit(
        state.copyWith(
          // Остальные категории могли измениться параллельно: берём ответ сервера целиком,
          // но не затираем переключатели, которые ещё сохраняются.
          settings: _mergeConfirmed(confirmed, category),
          savingCategories: {...state.savingCategories}..remove(category),
        ),
      );
    } catch (e, s) {
      addError(e, s);

      emit(
        state.copyWith(
          settings: state.settings?.copyWith(
            category: category,
            value: current.isEnabled(category),
          ),
          savingCategories: {...state.savingCategories}..remove(category),
          saveFailures: state.saveFailures + 1,
        ),
      );
    }
  }

  Future<void> _onOpenSettingsRequested(
    NotificationsSettingsEvent$OpenSettingsRequested event,
    Emitter<NotificationsSettingsState> emit,
  ) async {
    TailsAnalytics.log(TailsAnalyticsEvents.notificationsOpenSystemSettings);

    try {
      await _profileRepository.openSystemSettings();
    } catch (e, s) {
      addError(e, s);
    }
  }

  NotificationSettingsModel _mergeConfirmed(
    NotificationSettingsModel confirmed,
    NotificationCategory category,
  ) {
    var merged = confirmed;
    final visible = state.settings;

    if (visible == null) {
      return merged;
    }

    for (final other in state.savingCategories) {
      if (other != category) {
        merged = merged.copyWith(category: other, value: visible.isEnabled(other));
      }
    }

    return merged;
  }

  /// Не удалось узнать состояние разрешения — считаем, что уведомления не заблокированы.
  Future<bool> _loadBlockedBySystem() async {
    try {
      return await _profileRepository.isNotificationBlockedBySystem();
    } catch (e, s) {
      addError(e, s);

      return false;
    }
  }
}
