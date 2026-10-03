import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/constant/application_config.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';
import 'package:tails_mobile/src/feature/auth/data/repositories/auth_repository.dart';
import 'package:tails_mobile/src/feature/auth/domain/auth/auth_bloc.dart';
import 'package:tails_mobile/src/feature/auth/presentation/auth_scope.dart';
import 'package:tails_mobile/src/feature/initialization/model/dependencies_container.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';

import 'profile_fakes.dart';

/// Подмена `AuthRepository`: запоминает выход и очистку сессии, сеть не нужна.
class FakeAuthRepository extends Fake implements AuthRepository {
  final calls = <String>[];

  @override
  Stream<AuthorizationStatus> get authorizationStatus => const Stream.empty();

  @override
  Future<void> logout() async => calls.add('logout');

  @override
  Future<void> clearSession() async => calls.add('clearSession');
}

base class ProfileTestDependencies extends TestDependenciesContainer {
  const ProfileTestDependencies({
    required ProfileRepository profileRepository,
    required PetRepository petRepository,
  }) : _profileRepository = profileRepository,
       _petRepository = petRepository;

  final ProfileRepository _profileRepository;
  final PetRepository _petRepository;

  @override
  ProfileRepository get profileRepository => _profileRepository;

  @override
  PetRepository get petRepository => _petRepository;

  @override
  ApplicationConfig get config => const ApplicationConfig();
}

/// Окружение для экранов профиля: зависимости, авторизация и роутер с заглушками.
///
/// Экран под тестом открывается по `/screen` поверх заглушки `/home`, поэтому его можно
/// закрывать (`pop`) и переходить с него на соседние маршруты.
class ProfileScreenHarness {
  ProfileScreenHarness({
    required Widget Function(BuildContext context, GoRouterState state) screen,
    FakeProfileRepository? profile,
    FakePetRepository? pets,
    FakeAuthRepository? auth,
    this.stubPaths = const [],
    String screenPath = '/screen',
  }) : profile = profile ?? FakeProfileRepository(),
       pets = pets ?? FakePetRepository(),
       auth = auth ?? FakeAuthRepository(),
       _screenPath = screenPath {
    authBloc = AuthBloc(
      const AuthState.idle(status: AuthorizationStatus.authorized),
      authRepository: this.auth,
    );
    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('home stub')),
        ),
        GoRoute(path: _screenPath, builder: screen),
        for (final path in stubPaths)
          GoRoute(
            path: path,
            builder: (_, _) => Scaffold(body: Text('stub $path')),
          ),
      ],
    );
  }

  final FakeProfileRepository profile;
  final FakePetRepository pets;
  final FakeAuthRepository auth;
  final List<String> stubPaths;
  final String _screenPath;

  late final AuthBloc authBloc;
  late final GoRouter router;

  Future<void> pump(WidgetTester tester, {String? query}) async {
    await tester.pumpWidget(
      DependenciesScope(
        dependencies: ProfileTestDependencies(profileRepository: profile, petRepository: pets),
        child: AuthScope(
          authBloc: authBloc,
          child: MaterialApp.router(
            routerConfig: router,
            theme: UiThemeData.lightTheme,
            locale: const Locale('ru'),
            localizationsDelegates: Localization.localizationDelegates,
            supportedLocales: Localization.supportedLocales,
          ),
        ),
      ),
    );

    unawaited(router.push(query == null ? _screenPath : '$_screenPath?$query'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> dispose(WidgetTester tester) async {
    // Размонтируем дерево, чтобы остановить таймеры и подписки экранов.
    await tester.pumpWidget(const SizedBox());
    // `close` ждёт реальных асинхронных операций, которых нет в fake-async зоне теста.
    await tester.runAsync(authBloc.close);
  }
}
