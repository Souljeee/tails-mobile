import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_errors/ui_fetching_error.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_segmented_control/ui_segmented_control.dart';
import 'package:tails_mobile/src/feature/profile/about/presentation/about_screen.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/notification_settings_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/profile_model.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/feedback_topic.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';
import 'package:tails_mobile/src/feature/profile/core/exceptions/profile_exceptions.dart';
import 'package:tails_mobile/src/feature/profile/delete_account/presentation/account_deleted_screen.dart';
import 'package:tails_mobile/src/feature/profile/delete_account/presentation/delete_account_confirm_screen.dart';
import 'package:tails_mobile/src/feature/profile/delete_account/presentation/delete_account_screen.dart';
import 'package:tails_mobile/src/feature/profile/feedback/presentation/feedback_screen.dart';
import 'package:tails_mobile/src/feature/profile/notifications_settings/presentation/notifications_settings_screen.dart';
import 'package:tails_mobile/src/feature/profile/profile_overview/presentation/profile_screen.dart';

import '../../../helpers/profile_fakes.dart';
import '../../../helpers/profile_screen_harness.dart';

ProfileModel _profile({String name = '', NotificationSettingsModel? settings}) => ProfileModel(
  id: 'u1',
  phoneNumber: '79990001122',
  name: name,
  notificationSettings: settings ?? NotificationSettingsModel.allEnabled(),
);

UiButton _button(WidgetTester tester, String label) =>
    tester.widget<UiButton>(find.widgetWithText(UiButton, label));

void main() {
  group('ProfileScreen', () {
    testWidgets('без имени показывает подсказку, число питомцев и итог по уведомлениям', (
      tester,
    ) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const ProfileScreen(),
        profile: FakeProfileRepository()..profile = _profile(),
        pets: FakePetRepository()..pets = [fakePet(1, 'Барсик'), fakePet(2, 'Мурка')],
      );

      await harness.pump(tester);

      expect(find.text('Ваше имя'), findsOneWidget);
      expect(find.text('Добавить фото'), findsOneWidget);
      expect(find.text('2 питомца'), findsOneWidget);
      expect(find.text('Включены'), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('показывает настоящее имя и частичный итог по уведомлениям', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const ProfileScreen(),
        profile: FakeProfileRepository()
          ..profile = _profile(
            name: 'Анна',
            settings: NotificationSettingsModel.allEnabled().copyWith(
              category: NotificationCategory.walks,
              value: false,
            ),
          ),
      );

      await harness.pump(tester);

      expect(find.text('Анна'), findsOneWidget);
      expect(find.text('Ваше имя'), findsNothing);
      expect(find.text('4 из 5'), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('ошибка профиля показывает экран ошибки с повтором', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const ProfileScreen(),
        profile: FakeProfileRepository()..profileError = Exception('offline'),
      );

      await harness.pump(tester);

      expect(find.byType(UiFetchingError), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('карточка профиля открывает редактирование', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const ProfileScreen(),
        profile: FakeProfileRepository()..profile = _profile(name: 'Анна'),
        stubPaths: const ['/edit-profile'],
      );

      await harness.pump(tester);
      await tester.tap(find.text('Добавить фото'));
      await tester.pumpAndSettle();

      expect(find.text('stub /edit-profile'), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('«Выйти» требует подтверждения и выходит из аккаунта', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const ProfileScreen(),
        profile: FakeProfileRepository()..profile = _profile(),
      );

      await harness.pump(tester);
      await tester.tap(find.text('Выйти из аккаунта'));
      await tester.pumpAndSettle();

      expect(find.text('Выйти из аккаунта?'), findsOneWidget);
      expect(harness.auth.calls, isEmpty);

      await tester.tap(find.widgetWithText(UiButton, 'Выйти'));
      await tester.pumpAndSettle();

      expect(harness.auth.calls, ['logout']);

      await harness.dispose(tester);
    });

    testWidgets('отмена в подтверждении не выходит из аккаунта', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const ProfileScreen(),
        profile: FakeProfileRepository()..profile = _profile(),
      );

      await harness.pump(tester);
      await tester.tap(find.text('Выйти из аккаунта'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(UiButton, 'Отмена'));
      await tester.pumpAndSettle();

      expect(harness.auth.calls, isEmpty);

      await harness.dispose(tester);
    });

    testWidgets('«Помощь и обратная связь» открывает выбор темы', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const ProfileScreen(),
        profile: FakeProfileRepository()..profile = _profile(),
        stubPaths: const ['/feedback'],
      );

      await harness.pump(tester);
      await tester.tap(find.text('Помощь и обратная связь'));
      await tester.pumpAndSettle();

      expect(find.text('Сообщить о проблеме'), findsOneWidget);
      expect(find.text('Предложить идею'), findsOneWidget);
      expect(find.text('Задать вопрос'), findsOneWidget);

      await tester.tap(find.text('Предложить идею'));
      await tester.pumpAndSettle();

      expect(find.text('stub /feedback'), findsOneWidget);

      await harness.dispose(tester);
    });
  });

  group('Выбор темы в профиле', () {
    ProfileScreenHarness harness() => ProfileScreenHarness(
      screen: (_, _) => const ProfileScreen(),
      profile: FakeProfileRepository()..profile = _profile(),
    );

    ThemeMode selectedMode(WidgetTester tester) => tester
        .widget<UiSegmentedControl<ThemeMode>>(find.byType(UiSegmentedControl<ThemeMode>))
        .selected;

    testWidgets('по умолчанию выбрано «Системное»', (tester) async {
      final h = harness();

      await h.pump(tester);

      expect(selectedMode(tester), ThemeMode.system);

      await h.dispose(tester);
    });

    testWidgets('выбор темы применяется и сохраняется', (tester) async {
      final h = harness();

      await h.pump(tester);
      await tester.ensureVisible(find.text('Тёмное'));
      await tester.tap(find.text('Тёмное'));
      await tester.pump();

      expect(selectedMode(tester), ThemeMode.dark);
      expect(h.settings.saved?.appTheme?.themeMode, ThemeMode.dark);

      await h.dispose(tester);
    });
  });

  group('NotificationsSettingsScreen', () {
    testWidgets('переключатель сохраняет настройку', (tester) async {
      final harness = ProfileScreenHarness(screen: (_, _) => const NotificationsSettingsScreen());

      await harness.pump(tester);
      expect(find.text('Кормление'), findsOneWidget);

      await tester.tap(find.text('Кормление'));
      await tester.pumpAndSettle();

      expect(harness.profile.calls, contains('set(feeding, false)'));
      expect(find.byType(Switch), findsNWidgets(5));

      await harness.dispose(tester);
    });

    testWidgets('при ошибке сервера переключатель возвращается и показывается сообщение', (
      tester,
    ) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const NotificationsSettingsScreen(),
        profile: FakeProfileRepository()..setNotificationError = Exception('offline'),
      );

      await harness.pump(tester);
      await tester.tap(find.text('Прогулки'));
      await tester.pumpAndSettle();

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches.every((s) => s.value), isTrue);
      expect(find.text('Произошла ошибка. Попробуйте позже.'), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('баннер появляется, только если уведомления запрещены в системе', (tester) async {
      final allowed = ProfileScreenHarness(screen: (_, _) => const NotificationsSettingsScreen());

      await allowed.pump(tester);
      expect(find.text('Открыть настройки'), findsNothing);
      await allowed.dispose(tester);

      final blocked = ProfileScreenHarness(
        screen: (_, _) => const NotificationsSettingsScreen(),
        profile: FakeProfileRepository()..blocked = true,
      );

      await blocked.pump(tester);
      expect(find.text('Уведомления отключены в настройках устройства'), findsOneWidget);
      expect(find.text('Открыть настройки'), findsOneWidget);
      await blocked.dispose(tester);
    });

    testWidgets('при ошибке загрузки можно повторить', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const NotificationsSettingsScreen(),
        profile: ThrowingSettingsRepository(),
      );

      await harness.pump(tester);

      expect(find.byType(UiFetchingError), findsOneWidget);

      await harness.dispose(tester);
    });
  });

  group('AboutScreen', () {
    testWidgets('показывает версию и сборку из приложения', (tester) async {
      final harness = ProfileScreenHarness(screen: (_, _) => const AboutScreen());

      await harness.pump(tester);

      expect(find.text('Версия 1.2.3 · сборка 45'), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('пока ссылки на документы не заданы, сообщает об этом', (tester) async {
      final harness = ProfileScreenHarness(screen: (_, _) => const AboutScreen());

      await harness.pump(tester);
      await tester.tap(find.text('Условия использования'));
      await tester.pump();

      expect(find.text('Документ скоро появится'), findsOneWidget);

      await tester.tap(find.text('Политика конфиденциальности'));
      await tester.pump();

      expect(find.text('Документ скоро появится'), findsOneWidget);

      await harness.dispose(tester);
    });
  });

  group('FeedbackScreen', () {
    testWidgets('заголовок зависит от темы, отправка включается после ввода текста', (
      tester,
    ) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const FeedbackScreen(topic: FeedbackTopic.idea),
      );

      await harness.pump(tester);

      expect(find.text('Обратная связь'), findsOneWidget);
      expect(_button(tester, 'Отправить').onPressed, isNull);

      await tester.enterText(find.byType(TextField), '  Привет  ');
      await tester.pump();

      expect(_button(tester, 'Отправить').onPressed, isNotNull);

      await tester.tap(find.widgetWithText(UiButton, 'Отправить'));
      await tester.pumpAndSettle();

      expect(harness.profile.calls, ['sendFeedback(idea, Привет)']);
      expect(find.text('home stub'), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('при ограничении частоты экран остаётся открытым с объяснением', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const FeedbackScreen(topic: FeedbackTopic.problem),
        profile: FakeProfileRepository()..feedbackError = const FeedbackRateLimitException(),
      );

      await harness.pump(tester);
      await tester.enterText(find.byType(TextField), 'Не работает');
      await tester.pump();
      await tester.tap(find.widgetWithText(UiButton, 'Отправить'));
      await tester.pumpAndSettle();

      expect(
        find.text('Вы отправляете обращения слишком часто. Попробуйте чуть позже.'),
        findsOneWidget,
      );
      expect(find.text('Обратная связь'), findsOneWidget);

      await harness.dispose(tester);
    });
  });

  group('Удаление аккаунта', () {
    testWidgets('шаг 1 показывает настоящих питомцев и не идёт дальше без подтверждения', (
      tester,
    ) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const DeleteAccountScreen(phoneNumber: '79990001122'),
        pets: FakePetRepository()..pets = [fakePet(1, 'Барсик'), fakePet(2, 'Мурка')],
        stubPaths: const ['/delete-account/confirm'],
      );

      await harness.pump(tester);

      expect(find.text('Барсик и Мурка: фото, вес, здоровье'), findsOneWidget);
      expect(_button(tester, 'Продолжить').onPressed, isNull);
      expect(harness.profile.calls, isEmpty);

      // На небольшом экране подтверждение под сгибом: до него нужно дотянуться прокруткой.
      await tester.ensureVisible(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(_button(tester, 'Продолжить').onPressed, isNotNull);

      await tester.tap(find.widgetWithText(UiButton, 'Продолжить'));
      await tester.pumpAndSettle();

      expect(harness.profile.calls, ['sendDeletionCode']);
      expect(find.text('stub /delete-account/confirm'), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('шаг 1 без питомцев не выдумывает имена', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const DeleteAccountScreen(phoneNumber: '79990001122'),
      );

      await harness.pump(tester);

      expect(find.textContaining('фото, вес'), findsNothing);
      expect(find.text('Имя, фото и номер +7 999 000-11-22'), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('шаг 1: ошибка отправки кода не уводит на следующий шаг', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const DeleteAccountScreen(phoneNumber: '79990001122'),
        profile: FakeProfileRepository()..sendCodeError = Exception('offline'),
        stubPaths: const ['/delete-account/confirm'],
      );

      await harness.pump(tester);
      await tester.ensureVisible(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.tap(find.widgetWithText(UiButton, 'Продолжить'));
      await tester.pumpAndSettle();

      expect(find.text('stub /delete-account/confirm'), findsNothing);
      expect(find.text('Произошла ошибка. Попробуйте позже.'), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('шаг 2: кнопка включается после четырёх цифр и удаляет аккаунт', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const DeleteAccountConfirmScreen(phoneNumber: '79990001122'),
        stubPaths: const ['/account-deleted'],
      );

      await harness.pump(tester);

      expect(find.textContaining('+7 999 000-11-22'), findsOneWidget);
      expect(_button(tester, 'Удалить аккаунт').onPressed, isNull);

      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();

      expect(_button(tester, 'Удалить аккаунт').onPressed, isNotNull);

      await tester.tap(find.widgetWithText(UiButton, 'Удалить аккаунт'));
      await tester.pumpAndSettle();

      expect(harness.profile.calls, ['deleteAccount(1234)']);
      expect(find.text('stub /account-deleted'), findsOneWidget);

      await harness.dispose(tester);
    });

    testWidgets('шаг 2: неверный код очищает поле и показывает ответ сервера', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const DeleteAccountConfirmScreen(phoneNumber: '79990001122'),
        profile: FakeProfileRepository()
          ..deleteError = const InvalidDeletionCodeException(message: 'Неверный код. Осталось 4'),
        stubPaths: const ['/account-deleted'],
      );

      await harness.pump(tester);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();
      await tester.tap(find.widgetWithText(UiButton, 'Удалить аккаунт'));
      await tester.pumpAndSettle();

      expect(find.text('Неверный код. Осталось 4'), findsOneWidget);
      expect(find.text('stub /account-deleted'), findsNothing);
      expect(_button(tester, 'Удалить аккаунт').onPressed, isNull);
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .every((field) => field.controller!.text.isEmpty),
        isTrue,
      );

      await harness.dispose(tester);
    });

    testWidgets('«Аккаунт удалён» забывает сессию и ведёт ко входу', (tester) async {
      final harness = ProfileScreenHarness(
        screen: (_, _) => const AccountDeletedScreen(),
        stubPaths: const ['/auth'],
      );

      await harness.pump(tester);

      expect(find.text('Аккаунт удалён'), findsOneWidget);
      expect(harness.auth.calls, ['clearSession']);

      await tester.tap(find.widgetWithText(UiButton, 'Вернуться ко входу'));
      await tester.pumpAndSettle();

      expect(find.text('stub /auth'), findsOneWidget);

      await harness.dispose(tester);
    });
  });
}
