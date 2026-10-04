import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_errors/ui_fetching_error.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_inbox_item/ui_inbox_item.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';
import 'package:tails_mobile/src/feature/initialization/model/dependencies_container.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/notifications_inbox_repository.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/presentation/notifications_screen.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';

import '../../../../helpers/inbox_fakes.dart';
import '../../../../helpers/profile_fakes.dart';

class _ProfileRepository extends FakeProfileRepository {
  int settingsOpened = 0;

  @override
  Future<void> openSystemSettings() async => settingsOpened++;
}

base class _Dependencies extends TestDependenciesContainer {
  const _Dependencies({required this.inbox, required this.pets, required this.profile});

  final FakeNotificationsInboxRepository inbox;
  final FakePetRepository pets;
  final _ProfileRepository profile;

  @override
  NotificationsInboxRepository get notificationsInboxRepository => inbox;

  @override
  PetRepository get petRepository => pets;

  @override
  ProfileRepository get profileRepository => profile;
}

/// 4 октября 2026, 15:00 — «сейчас» во всех тестах экрана.
final _now = DateTime(2026, 10, 4, 15);

void main() {
  late FakeNotificationsInboxRepository inbox;
  late FakePetRepository pets;
  late _ProfileRepository profile;
  late GoRouter router;

  setUp(() {
    inbox = FakeNotificationsInboxRepository();
    pets = FakePetRepository()..pets = [fakePet(1, 'Сексик'), fakePet(2, 'Мистерио')];
    profile = _ProfileRepository();
    router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('home stub')),
        ),
        GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
        GoRoute(
          path: '/schedule',
          builder: (_, _) => const Scaffold(body: Text('schedule stub')),
        ),
        GoRoute(
          path: '/notifications-settings',
          builder: (_, _) => const Scaffold(body: Text('settings stub')),
        ),
      ],
    );
  });

  tearDown(() => inbox.dispose());

  /// Открывает экран поверх заглушки `/home`, как это делает колокольчик.
  Future<void> open(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(800, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      DependenciesScope(
        dependencies: _Dependencies(inbox: inbox, pets: pets, profile: profile),
        child: MaterialApp.router(
          routerConfig: router,
          theme: UiThemeData.lightTheme,
          locale: const Locale('ru'),
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
        ),
      ),
    );

    router.push('/notifications').ignore();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> close(WidgetTester tester) async {
    // Размонтируем дерево, чтобы остановить подписки и анимации экрана.
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(pumpEventQueue);
  }

  /// Выполняет тест при фиксированных «сейчас» для подписей времени.
  Future<void> inClock(Future<void> Function() body) => withClock(Clock.fixed(_now), body);

  group('список', () {
    testWidgets('группирует по дням и показывает счётчик и «Прочитать все»', (tester) async {
      await inClock(() async {
        inbox.items = [
          fakeInboxItem(
            'n1',
            petId: 1,
            body: 'Сексику нужно дать таблетку',
            createdAt: _now.subtract(const Duration(minutes: 5)),
          ),
          fakeInboxItem(
            'n2',
            petId: 2,
            title: 'Время кормления',
            body: 'Пора покормить Мистерио',
            isRead: true,
            createdAt: _now.subtract(const Duration(hours: 3)),
          ),
          fakeInboxItem('n3', title: 'Скоро прививка', createdAt: DateTime(2026, 10, 3, 18, 40)),
          fakeInboxItem('n4', title: 'Взвешивание', createdAt: DateTime(2026, 9, 28, 10)),
        ];

        await open(tester);

        expect(find.text('Уведомления'), findsOneWidget);
        expect(find.text('СЕГОДНЯ'), findsOneWidget);
        expect(find.text('ВЧЕРА'), findsOneWidget);
        expect(find.text('РАНЕЕ'), findsOneWidget);
        expect(find.text('Пора дать лекарство'), findsOneWidget);
        expect(find.text('5 мин'), findsOneWidget);
        expect(find.text('3 ч'), findsOneWidget);
        expect(find.text('18:40'), findsOneWidget);
        expect(find.text('28 сент.'), findsOneWidget);
        expect(find.text('Все'), findsOneWidget);
        expect(find.text('Непрочитанные · 3'), findsOneWidget);
        expect(find.text('Прочитать все'), findsOneWidget);

        await close(tester);
      });
    });

    testWidgets('нажатие на строку отмечает её прочитанной и открывает расписание', (tester) async {
      await inClock(() async {
        inbox.items = [fakeInboxItem('n1', petId: 1, createdAt: _now)];

        await open(tester);
        await tester.tap(find.byType(UiInboxItem));
        await tester.pumpAndSettle();

        expect(inbox.calls, contains('markRead(n1)'));
        expect(find.text('schedule stub'), findsOneWidget);

        await close(tester);
      });
    });

    testWidgets('«Прочитать все» помечает всё и прячет ссылку', (tester) async {
      await inClock(() async {
        inbox.items = [fakeInboxItem('n1', createdAt: _now), fakeInboxItem('n2', createdAt: _now)];

        await open(tester);
        await tester.tap(find.text('Прочитать все'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(inbox.calls, contains('markAllRead'));
        expect(find.text('Прочитать все'), findsNothing);
        expect(find.text('Непрочитанные'), findsOneWidget);

        await close(tester);
      });
    });
  });

  group('фильтры', () {
    testWidgets('«Непрочитанные» показывают только новые', (tester) async {
      await inClock(() async {
        inbox.items = [
          fakeInboxItem('n1', title: 'Новое', createdAt: _now),
          fakeInboxItem('n2', title: 'Старое', isRead: true, createdAt: _now),
        ];

        await open(tester);

        expect(find.text('Старое'), findsOneWidget);

        await tester.tap(find.text('Непрочитанные · 1'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Новое'), findsOneWidget);
        expect(find.text('Старое'), findsNothing);
        expect(tester.widgetList<UiChip>(find.byType(UiChip)).map((chip) => chip.selected), [
          false,
          true,
        ]);

        await close(tester);
      });
    });

    testWidgets('когда всё прочитано, во вкладке «Непрочитанные» — «Всё прочитано»', (
      tester,
    ) async {
      await inClock(() async {
        inbox.items = [fakeInboxItem('n1', isRead: true, createdAt: _now)];

        await open(tester);
        await tester.tap(find.text('Непрочитанные'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Всё прочитано'), findsOneWidget);
        expect(find.textContaining('Вся история — во вкладке «Все»'), findsOneWidget);
        // Фильтры остаются, «Прочитать все» нет: непрочитанных нет.
        expect(find.byType(UiChip), findsNWidgets(2));
        expect(find.text('Прочитать все'), findsNothing);

        await close(tester);
      });
    });
  });

  group('пустые состояния и ошибки', () {
    testWidgets('нет уведомлений совсем: подсказка без фильтров и ссылка на настройки', (
      tester,
    ) async {
      await open(tester);

      expect(find.text('Пока нет уведомлений'), findsOneWidget);
      expect(find.byType(UiChip), findsNothing);
      expect(find.text('Прочитать все'), findsNothing);

      await tester.tap(find.text('Настроить уведомления'));
      await tester.pumpAndSettle();

      expect(find.text('settings stub'), findsOneWidget);

      await close(tester);
    });

    testWidgets('ошибка загрузки с повтором', (tester) async {
      inbox.getPageError = Exception('offline');

      await open(tester);

      expect(find.byType(UiFetchingError), findsOneWidget);

      inbox.getPageError = null;
      inbox.items = [fakeInboxItem('n1', title: 'Вернулось', createdAt: DateTime.now())];

      await tester.tap(find.text('Повторить'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Вернулось'), findsOneWidget);

      await close(tester);
    });
  });

  group('уведомления отключены в системе', () {
    testWidgets('баннер над списком и открытие настроек телефона', (tester) async {
      await inClock(() async {
        profile.blocked = true;
        inbox.items = [fakeInboxItem('n1', createdAt: _now)];

        await open(tester);

        expect(find.text('Уведомления отключены в настройках устройства'), findsOneWidget);
        expect(find.text('Пора дать лекарство'), findsOneWidget);

        await tester.tap(find.text('Открыть настройки'));
        await tester.pump();

        expect(profile.settingsOpened, 1);

        await close(tester);
      });
    });

    testWidgets('баннер и в пустом состоянии', (tester) async {
      profile.blocked = true;

      await open(tester);

      expect(find.text('Уведомления отключены в настройках устройства'), findsOneWidget);
      expect(find.text('Пока нет уведомлений'), findsOneWidget);

      await close(tester);
    });

    testWidgets('без запрета баннера нет', (tester) async {
      await open(tester);

      expect(find.text('Уведомления отключены в настройках устройства'), findsNothing);

      await close(tester);
    });
  });

  group('обновление', () {
    testWidgets('push в открытом приложении добавляет уведомление в список', (tester) async {
      await inClock(() async {
        inbox.items = [fakeInboxItem('n1', title: 'Старое', createdAt: _now)];

        await open(tester);

        inbox.items = [fakeInboxItem('n0', title: 'Свежее', createdAt: _now), ...inbox.items];
        inbox.incomingController.add(null);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Свежее'), findsOneWidget);
        expect(find.text('Старое'), findsOneWidget);

        await close(tester);
      });
    });
  });
}
