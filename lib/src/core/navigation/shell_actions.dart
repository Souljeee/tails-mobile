import 'package:flutter/material.dart';

/// Вкладки корневой оболочки; порядок совпадает с порядком веток в `HomeShellRoute`.
enum ShellTab { pets, schedule, profile }

/// Просьба открыть календарь, отфильтрованный по питомцу.
class ScheduleFilterRequest {
  const ScheduleFilterRequest({required this.petId});

  final int petId;
}

/// Хранит действия кнопки «+» для вкладок оболочки.
///
/// Экран вкладки регистрирует своё действие, а оболочка вызывает его при нажатии на «+».
/// Ветки `StatefulShellRoute` живут одновременно, поэтому действия хранятся по вкладкам.
class ShellActionsController {
  final Map<ShellTab, VoidCallback> _actions = {};

  /// Регистрирует [action] для [tab]; возвращает функцию отмены регистрации.
  VoidCallback register(ShellTab tab, VoidCallback action) {
    _actions[tab] = action;

    return () {
      if (_actions[tab] == action) {
        _actions.remove(tab);
      }
    };
  }

  /// Действие вкладки [tab], если экран его зарегистрировал.
  VoidCallback? actionFor(ShellTab tab) => _actions[tab];

  /// Ожидающая просьба отфильтровать календарь по питомцу.
  ///
  /// Хранится, пока календарь её не заберёт: ветка календаря может быть ещё не создана,
  /// если пользователь на ней не был.
  final ValueNotifier<ScheduleFilterRequest?> scheduleFilterRequest = ValueNotifier(null);

  /// Просит календарь показать события только питомца [petId].
  void requestScheduleFilter(int petId) {
    scheduleFilterRequest.value = ScheduleFilterRequest(petId: petId);
  }

  /// Забирает ожидающую просьбу (после этого её нет).
  ScheduleFilterRequest? takeScheduleFilterRequest() {
    final request = scheduleFilterRequest.value;

    if (request != null) {
      scheduleFilterRequest.value = null;
    }

    return request;
  }
}

/// Предоставляет [ShellActionsController] и нижний отступ под плавающую навигацию.
class ShellScope extends InheritedWidget {
  const ShellScope({
    required this.controller,
    required this.bottomInset,
    required super.child,
    super.key,
  });

  final ShellActionsController controller;

  /// Нижний отступ, который прокручиваемый контент оставляет под навигацией.
  final double bottomInset;

  static ShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellScope>();

  /// Нижний отступ под навигацию; `0`, если экран показан вне оболочки.
  static double bottomInsetOf(BuildContext context) => maybeOf(context)?.bottomInset ?? 0;

  @override
  bool updateShouldNotify(ShellScope oldWidget) =>
      bottomInset != oldWidget.bottomInset || controller != oldWidget.controller;
}

/// Регистрирует действие кнопки «+» вкладки на время жизни состояния.
mixin ShellActionMixin<T extends StatefulWidget> on State<T> {
  VoidCallback? _unregister;

  ShellTab get shellTab;

  /// Действие, выполняемое по нажатию на «+».
  void onShellAction();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _unregister?.call();
    _unregister = ShellScope.maybeOf(context)?.controller.register(shellTab, onShellAction);
  }

  @override
  void dispose() {
    _unregister?.call();

    super.dispose();
  }
}
