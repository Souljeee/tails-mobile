import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/models/inbox_item.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/notifications_inbox_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';

part 'notifications_inbox_event.dart';
part 'notifications_inbox_state.dart';

/// Экран «Уведомления»: список с фильтром, подгрузкой страниц и отметкой «прочитано».
class NotificationsInboxBloc extends Bloc<NotificationsInboxEvent, NotificationsInboxState> {
  NotificationsInboxBloc({
    required NotificationsInboxRepository inboxRepository,
    required PetRepository petRepository,
    required ProfileRepository profileRepository,
  }) : _inboxRepository = inboxRepository,
       _petRepository = petRepository,
       _profileRepository = profileRepository,
       super(const NotificationsInboxState()) {
    on<NotificationsInboxEvent>(
      (event, emit) => event.map(
        started: (event) => _onStarted(event, emit),
        refreshRequested: (event) => _onRefreshRequested(event, emit),
        filterChanged: (event) => _onFilterChanged(event, emit),
        loadMoreRequested: (event) => _onLoadMoreRequested(event, emit),
        itemOpened: (event) => _onItemOpened(event, emit),
        readAllRequested: (event) => _onReadAllRequested(event, emit),
        systemStatusChecked: (event) => _onSystemStatusChecked(event, emit),
        openSettingsRequested: (event) => _onOpenSettingsRequested(event, emit),
        unreadCountChanged: (event) => _onUnreadCountChanged(event, emit),
      ),
    );

    _subscriptions
      ..add(
        inboxRepository.unreadCount.listen(
          (count) => add(NotificationsInboxEvent.unreadCountChanged(count: count)),
        ),
      )
      ..add(
        inboxRepository.incoming.listen(
          (_) => add(const NotificationsInboxEvent.refreshRequested()),
        ),
      );
  }

  final NotificationsInboxRepository _inboxRepository;
  final PetRepository _petRepository;
  final ProfileRepository _profileRepository;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  /// Номер последней загрузки списка: ответ устаревшей загрузки (после смены фильтра
  /// или нового обновления) отбрасывается.
  int _loadId = 0;

  Future<void> _onStarted(
    NotificationsInboxEvent$Started event,
    Emitter<NotificationsInboxState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsInboxStatus.loading));

    // Питомцы и системное разрешение нужны только для оформления: сбой не мешает списку.
    final extras = _loadExtras();

    await _load(emit);

    final loaded = await extras;

    emit(state.copyWith(pets: loaded.pets, isBlockedBySystem: loaded.isBlocked));
  }

  Future<void> _onRefreshRequested(
    NotificationsInboxEvent$RefreshRequested event,
    Emitter<NotificationsInboxState> emit,
  ) async {
    try {
      final extras = _loadExtras();

      await _load(emit, silent: true);

      final loaded = await extras;

      emit(state.copyWith(pets: loaded.pets, isBlockedBySystem: loaded.isBlocked));
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onFilterChanged(
    NotificationsInboxEvent$FilterChanged event,
    Emitter<NotificationsInboxState> emit,
  ) async {
    if (event.filter == state.filter) {
      return;
    }

    emit(
      state.copyWith(
        filter: event.filter,
        status: NotificationsInboxStatus.loading,
        items: const [],
        nextCursor: const CopyWithWrapper.value(null),
        isLoadingMore: false,
      ),
    );

    await _load(emit);
  }

  Future<void> _onLoadMoreRequested(
    NotificationsInboxEvent$LoadMoreRequested event,
    Emitter<NotificationsInboxState> emit,
  ) async {
    final cursor = state.nextCursor;

    if (cursor == null || state.isLoadingMore || state.status != NotificationsInboxStatus.ready) {
      return;
    }

    final loadId = _loadId;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final page = await _inboxRepository.getPage(
        cursor: cursor,
        unreadOnly: state.filter == NotificationsInboxFilter.unread,
      );

      if (loadId != _loadId) {
        return;
      }

      final knownIds = {for (final item in state.items) item.id};

      emit(
        state.copyWith(
          items: [...state.items, ...page.items.where((item) => !knownIds.contains(item.id))],
          nextCursor: CopyWithWrapper.value(page.nextCursor),
          unreadCount: page.unreadCount,
          isLoadingMore: false,
        ),
      );
    } on Object catch (e, s) {
      addError(e, s);

      // Следующая прокрутка до конца списка повторит попытку.
      if (loadId == _loadId) {
        emit(state.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _onItemOpened(
    NotificationsInboxEvent$ItemOpened event,
    Emitter<NotificationsInboxState> emit,
  ) async {
    final index = state.items.indexWhereId(event.id);

    if (index < 0 || state.items[index].isRead) {
      return;
    }

    // Строка становится прочитанной сразу; если сервер откажет, вернём как было.
    emit(
      state.copyWith(
        items: _withItem(state.items, index, state.items[index].copyWith(isRead: true)),
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      ),
    );

    try {
      final unread = await _inboxRepository.markRead(event.id);

      emit(state.copyWith(unreadCount: unread));
    } on Object catch (e, s) {
      addError(e, s);

      final current = state.items.indexWhereId(event.id);

      emit(
        state.copyWith(
          items: current < 0
              ? state.items
              : _withItem(state.items, current, state.items[current].copyWith(isRead: false)),
          unreadCount: state.unreadCount + 1,
          actionFailures: state.actionFailures + 1,
        ),
      );
    }
  }

  Future<void> _onReadAllRequested(
    NotificationsInboxEvent$ReadAllRequested event,
    Emitter<NotificationsInboxState> emit,
  ) async {
    if (state.unreadCount == 0) {
      return;
    }

    final previous = state;
    final isUnreadFilter = state.filter == NotificationsInboxFilter.unread;

    emit(
      state.copyWith(
        items: isUnreadFilter
            ? const []
            : [for (final item in state.items) item.copyWith(isRead: true)],
        nextCursor: isUnreadFilter ? const CopyWithWrapper.value(null) : null,
        unreadCount: 0,
      ),
    );

    try {
      await _inboxRepository.markAllRead();
    } on Object catch (e, s) {
      addError(e, s);

      emit(
        state.copyWith(
          items: previous.items,
          nextCursor: CopyWithWrapper.value(previous.nextCursor),
          unreadCount: previous.unreadCount,
          actionFailures: state.actionFailures + 1,
        ),
      );
    }
  }

  Future<void> _onSystemStatusChecked(
    NotificationsInboxEvent$SystemStatusChecked event,
    Emitter<NotificationsInboxState> emit,
  ) async {
    final blocked = await _isBlockedBySystem();

    if (blocked != state.isBlockedBySystem) {
      emit(state.copyWith(isBlockedBySystem: blocked));
    }
  }

  Future<void> _onOpenSettingsRequested(
    NotificationsInboxEvent$OpenSettingsRequested event,
    Emitter<NotificationsInboxState> emit,
  ) => _profileRepository.openSystemSettings();

  Future<void> _onUnreadCountChanged(
    NotificationsInboxEvent$UnreadCountChanged event,
    Emitter<NotificationsInboxState> emit,
  ) async {
    if (event.count != state.unreadCount) {
      emit(state.copyWith(unreadCount: event.count));
    }
  }

  /// Загружает первую страницу выбранного фильтра. При [silent] показанный список остаётся
  /// на экране, пока не придёт ответ, а сбой его не заменяет.
  Future<void> _load(Emitter<NotificationsInboxState> emit, {bool silent = false}) async {
    final loadId = ++_loadId;

    try {
      final page = await _inboxRepository.getPage(
        unreadOnly: state.filter == NotificationsInboxFilter.unread,
      );

      if (loadId != _loadId) {
        return;
      }

      emit(
        state.copyWith(
          status: NotificationsInboxStatus.ready,
          items: page.items,
          nextCursor: CopyWithWrapper.value(page.nextCursor),
          unreadCount: page.unreadCount,
          isLoadingMore: false,
        ),
      );
    } on Object catch (e, s) {
      addError(e, s);

      if (loadId != _loadId) {
        return;
      }

      if (!silent || state.status != NotificationsInboxStatus.ready) {
        emit(state.copyWith(status: NotificationsInboxStatus.failure, isLoadingMore: false));
      }
    }
  }

  Future<({Map<int, PetModel> pets, bool isBlocked})> _loadExtras() async {
    final pets = _loadPets();
    final blocked = _isBlockedBySystem();

    return (pets: await pets, isBlocked: await blocked);
  }

  Future<Map<int, PetModel>> _loadPets() async {
    try {
      final pets = await _petRepository.getPets();

      return {for (final pet in pets) pet.id: pet};
    } on Object catch (e, s) {
      addError(e, s);

      return state.pets;
    }
  }

  Future<bool> _isBlockedBySystem() async {
    try {
      return await _profileRepository.isNotificationBlockedBySystem();
    } on Object catch (e, s) {
      addError(e, s);

      return state.isBlockedBySystem;
    }
  }

  List<InboxItem> _withItem(List<InboxItem> items, int index, InboxItem item) => [
    for (var i = 0; i < items.length; i++) i == index ? item : items[i],
  ];

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }

    return super.close();
  }
}

extension on List<InboxItem> {
  int indexWhereId(String id) => indexWhere((item) => item.id == id);
}
