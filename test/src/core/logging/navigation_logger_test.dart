import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/logging/integrations/navigation_logger.dart';
import 'package:tails_mobile/src/core/logging/tails_log_context.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

import '../../../helpers/recording_log_sink.dart';

void main() {
  late RecordingLogSink sink;

  setUp(() {
    sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
  });

  tearDown(() {
    TailsLogger.reset();
    TailsLogContext.reset();
  });

  GoRouter createRouter() => GoRouter(
    initialLocation: '/pets',
    observers: [NavigationObserver()],
    routes: [
      GoRoute(
        path: '/pets',
        name: 'pets',
        builder: (_, _) => const _Screen('pets'),
        routes: [
          GoRoute(
            path: ':id',
            name: 'pet-details',
            builder: (_, state) => _Screen('pet ${state.pathParameters['id']}'),
          ),
        ],
      ),
      GoRoute(
        path: '/enter-code',
        name: 'enter-code',
        builder: (_, _) => const _Screen('enter-code'),
      ),
      GoRoute(path: '/edit', name: 'edit', builder: (_, state) => _Screen('edit ${state.extra}')),
    ],
  );

  Future<GoRouter> pumpRouter(WidgetTester tester) async {
    final router = createRouter();
    NavigationLogger(router).start();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    return router;
  }

  List<TailsLogEvent> navigation() =>
      sink.events.where((event) => event.category == TailsLogCategory.navigation).toList();

  group('NavigationLogger', () {
    testWidgets('пишет первый экран и сохраняет его в контексте', (tester) async {
      await pumpRouter(tester);

      final events = navigation();
      expect(events, hasLength(1));
      expect(events.single.message, '(start) → pets');
      expect(events.single.data['path'], '/pets');
      expect(events.single.level, TailsLogLevel.info);
      expect(TailsLogContext.screen, 'pets');
    });

    testWidgets('пишет переход с шаблоном пути и параметрами', (tester) async {
      final router = await pumpRouter(tester);

      router.go('/pets/123');
      await tester.pumpAndSettle();

      final event = navigation().last;
      expect(event.message, 'pets → pet-details');
      expect(event.data['path'], '/pets/:id');
      expect(event.data['params'], {'id': '123'});
      expect(TailsLogContext.screen, 'pet-details');
    });

    testWidgets('пишет возврат назад', (tester) async {
      final router = await pumpRouter(tester);

      unawaited(router.push('/pets/1'));
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();

      expect(navigation().map((event) => event.message), [
        '(start) → pets',
        'pets → pet-details',
        'pet-details → pets',
      ]);
    });

    testWidgets('маскирует телефон в параметрах и не пишет готовый адрес', (tester) async {
      final router = await pumpRouter(tester);

      router.go('/enter-code?phoneNumber=%2B79001112233');
      await tester.pumpAndSettle();

      final event = navigation().last;
      expect(event.data['query'], {'phoneNumber': '+7***2233'});
      expect('${event.data}', isNot(contains('79001112233')));
      expect(event.data.containsKey('uri'), isFalse);
    });

    testWidgets(r'$extra описывается только типом', (tester) async {
      final router = await pumpRouter(tester);

      router.go('/edit', extra: const _SecretModel('+79001112233'));
      await tester.pumpAndSettle();

      final event = navigation().last;
      expect(event.data['extra'], '_SecretModel');
      expect('${event.data}', isNot(contains('79001112233')));
    });

    testWidgets('повторная перерисовка того же маршрута не пишется заново', (tester) async {
      final router = await pumpRouter(tester);

      router.go('/pets');
      await tester.pumpAndSettle();
      router.go('/pets');
      await tester.pumpAndSettle();

      expect(navigation(), hasLength(1));
    });

    testWidgets('тот же маршрут с другим параметром пишется', (tester) async {
      final router = await pumpRouter(tester);

      router.go('/pets/1');
      await tester.pumpAndSettle();
      router.go('/pets/2');
      await tester.pumpAndSettle();

      expect(navigation().map((event) => event.message).skip(1), [
        'pets → pet-details',
        'pet-details → pet-details',
      ]);
    });

    testWidgets('неизвестный адрес пишется как warning', (tester) async {
      final router = await pumpRouter(tester);

      router.go('/nowhere');
      await tester.pumpAndSettle();

      final event = navigation().last;
      expect(event.level, TailsLogLevel.warning);
      expect(event.message, 'Маршрут не найден');
      expect(event.data['path'], '/nowhere');
    });

    testWidgets('после dispose переходы не пишутся', (tester) async {
      final router = createRouter();
      final logger = NavigationLogger(router)..start();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      logger.dispose();
      router.go('/pets/5');
      await tester.pumpAndSettle();

      expect(navigation(), hasLength(1));
    });
  });

  group('NavigationObserver', () {
    testWidgets('пишет открытие и закрытие шторки с именем и экраном', (tester) async {
      final router = await pumpRouter(tester);
      final context = tester.element(find.byType(_Screen));

      final future = showModalBottomSheet<void>(
        context: context,
        routeSettings: const RouteSettings(name: 'confirm'),
        builder: (_) => const SizedBox(height: 100),
      );
      await tester.pumpAndSettle();
      Navigator.of(context).pop();
      await future;
      await tester.pumpAndSettle();

      final modal = sink.events.where((event) => event.source == 'Navigator').toList();
      expect(modal.map((event) => event.message), ['открыто confirm', 'закрыто confirm']);
      expect(modal.first.data['screen'], 'pets');
      expect(router, isNotNull);
    });

    testWidgets('без имени берёт тип маршрута', (tester) async {
      await pumpRouter(tester);
      final context = tester.element(find.byType(_Screen));

      final future = showDialog<void>(context: context, builder: (_) => const AlertDialog());
      await tester.pumpAndSettle();
      Navigator.of(context).pop();
      await future;
      await tester.pumpAndSettle();

      final modal = sink.events.where((event) => event.source == 'Navigator').toList();
      expect(modal.first.message, startsWith('открыто '));
      expect(modal.first.message, isNot(contains('<')));
    });

    testWidgets('страницы маршрутов не дублируются', (tester) async {
      final router = await pumpRouter(tester);

      unawaited(router.push('/pets/1'));
      await tester.pumpAndSettle();

      expect(sink.events.where((event) => event.source == 'Navigator'), isEmpty);
    });
  });
}

final class _Screen extends StatelessWidget {
  const _Screen(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text(title));
}

final class _SecretModel {
  const _SecretModel(this.phone);

  final String phone;

  @override
  String toString() => 'Model($phone)';
}
