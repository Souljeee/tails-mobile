import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/notifications_inbox_repository.dart';

part 'notifications_unread_event.dart';
part 'notifications_unread_state.dart';

/// Число непрочитанных уведомлений для бейджа на колокольчике.
class NotificationsUnreadBloc extends Bloc<NotificationsUnreadEvent, NotificationsUnreadState> {
  NotificationsUnreadBloc({required NotificationsInboxRepository inboxRepository})
    : _inboxRepository = inboxRepository,
      super(NotificationsUnreadState(count: inboxRepository.currentUnreadCount ?? 0)) {
    on<NotificationsUnreadEvent>(
      (event, emit) => event.map(
        refreshRequested: (event) => _onRefreshRequested(event, emit),
        countChanged: (event) => _onCountChanged(event, emit),
      ),
    );

    _subscription = inboxRepository.unreadCount.listen(
      (count) => add(NotificationsUnreadEvent.countChanged(count: count)),
    );
  }

  final NotificationsInboxRepository _inboxRepository;
  late final StreamSubscription<int> _subscription;

  Future<void> _onRefreshRequested(
    NotificationsUnreadEvent$RefreshRequested event,
    Emitter<NotificationsUnreadState> emit,
  ) async {
    try {
      final count = await _inboxRepository.refreshUnreadCount();

      emit(NotificationsUnreadState(count: count));
    } on Object catch (e, s) {
      // Бейдж — украшение: при сбое остаётся прежнее число.
      addError(e, s);
    }
  }

  Future<void> _onCountChanged(
    NotificationsUnreadEvent$CountChanged event,
    Emitter<NotificationsUnreadState> emit,
  ) async => emit(NotificationsUnreadState(count: event.count));

  @override
  Future<void> close() async {
    await _subscription.cancel();

    return super.close();
  }
}
