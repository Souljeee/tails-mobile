import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/navigation/guards/authorization_guards.dart';
import 'package:tails_mobile/src/core/navigation/guards/redirect_builder.dart';

/// Срабатывает ли охрана на [location] — так же, как это решает `RedirectBuilder`.
bool _runsOn(Guard guard, String location) =>
    (guard.matchPattern.matchAsPrefix(location) != null) != guard.invertRedirect;

void main() {
  group('RedirectIfNotAuthorizedGuard', () {
    final guard = RedirectIfNotAuthorizedGuard();

    test('уводит на вход с обычных экранов', () {
      expect(_runsOn(guard, '/pets'), isTrue);
      expect(_runsOn(guard, '/profile'), isTrue);
      expect(_runsOn(guard, '/delete-account/confirm'), isTrue);
    });

    test('не трогает экраны входа', () {
      expect(_runsOn(guard, '/auth'), isFalse);
      expect(_runsOn(guard, '/enter-code'), isFalse);
    });

    test('не уводит с экрана «Аккаунт удалён», пока пользователь на нём', () {
      expect(_runsOn(guard, '/account-deleted'), isFalse);
    });
  });

  group('RedirectIfAuthorizedGuard', () {
    final guard = RedirectIfAuthorizedGuard();

    test('уводит авторизованного пользователя с экранов входа', () {
      expect(_runsOn(guard, '/auth'), isTrue);
      expect(_runsOn(guard, '/enter-code'), isTrue);
    });

    test('не мешает экрану «Аккаунт удалён» сразу после удаления', () {
      // Сразу после удаления токены ещё на устройстве, пользователь считается авторизованным.
      expect(_runsOn(guard, '/account-deleted'), isFalse);
    });
  });
}
