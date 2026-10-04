import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_button/ui_icon_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_inbox_item/ui_inbox_item.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_avatar/ui_pet_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';

import '../../../helpers/ui_test_app.dart';

UiInboxItem _item({
  bool isRead = false,
  String title = 'Пора дать лекарство',
  String body = 'Сексику нужно дать таблетку Симпарики',
  VoidCallback? onTap,
}) => UiInboxItem(
  title: title,
  body: body,
  timeLabel: '5 мин',
  isRead: isRead,
  leading: const UiIconBadge(icon: Icons.medication),
  onTap: onTap,
);

/// Диаметр кружка-точки «не прочитано» (`DecoratedBox` круглой формы 8×8).
Finder get _unreadDot => find.byWidgetPredicate(
  (widget) =>
      widget is DecoratedBox &&
      widget.decoration is BoxDecoration &&
      (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
      widget.child is SizedBox &&
      (widget.child! as SizedBox).width == 8,
);

void main() {
  group('UiInboxItem', () {
    testWidgets('непрочитанное: жирный заголовок, точка и время цветом акцента', (tester) async {
      await tester.pumpWidget(uiTestApp(_item()));

      final title = tester.widget<Text>(find.text('Пора дать лекарство'));
      final time = tester.widget<Text>(find.text('5 мин'));
      final theme = Theme.of(tester.element(find.byType(UiInboxItem)));

      expect(title.style?.fontWeight, FontWeight.w700);
      expect(_unreadDot, findsOneWidget);
      expect(time.style?.color, isNot(theme.textTheme.bodyMedium?.color));
      expect(find.text('Сексику нужно дать таблетку Симпарики'), findsOneWidget);
    });

    testWidgets('прочитанное: обычный заголовок и без точки', (tester) async {
      await tester.pumpWidget(uiTestApp(_item(isRead: true)));

      final title = tester.widget<Text>(find.text('Пора дать лекарство'));

      expect(title.style?.fontWeight, isNot(FontWeight.w700));
      expect(_unreadDot, findsNothing);
    });

    testWidgets('нажимается вся строка', (tester) async {
      var taps = 0;

      await tester.pumpWidget(uiTestApp(_item(onTap: () => taps++)));
      await tester.tap(find.text('Сексику нужно дать таблетку Симпарики'));

      expect(taps, 1);
    });

    testWidgets('скринридер читает «Новое» только у непрочитанного', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(uiTestApp(_item()));

      expect(
        tester.getSemantics(find.byType(UiInboxItem)).label,
        'Новое. Пора дать лекарство. Сексику нужно дать таблетку Симпарики. 5 мин',
      );

      await tester.pumpWidget(uiTestApp(_item(isRead: true)));

      expect(
        tester.getSemantics(find.byType(UiInboxItem)).label,
        'Пора дать лекарство. Сексику нужно дать таблетку Симпарики. 5 мин',
      );

      handle.dispose();
    });

    testWidgets('длинный текст обрезается до двух строк, высота не меньше 76 pt', (tester) async {
      const longText =
          'Мистерио ждут в клинике в 16:30. Возьмите ветпаспорт и результаты анализов, '
          'которые сдавали на прошлой неделе, а ещё документы на прививку и поводок.';

      await tester.pumpWidget(
        uiTestApp(_item(title: 'Приём у ветеринара сегодня в клинике на Садовой', body: longText)),
      );

      final body = tester.widget<Text>(find.text(longText));

      expect(body.maxLines, 2);
      expect(body.overflow, TextOverflow.ellipsis);
      expect(
        tester.getSize(find.byType(UiInboxItem)).height,
        greaterThanOrEqualTo(UiInboxItem.minHeight),
      );
    });

    testWidgets('короткий текст не делает строку ниже 76 pt', (tester) async {
      await tester.pumpWidget(uiTestApp(_item(title: 'Кормление', body: 'Пора')));

      expect(tester.getSize(find.byType(UiInboxItem)).height, UiInboxItem.minHeight);
    });

    testWidgets('не переполняется при увеличенном тексте на узком экране', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: UiThemeData.lightTheme,
          locale: const Locale('ru'),
          localizationsDelegates: Localization.localizationDelegates,
          supportedLocales: Localization.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(body: _item()),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('UiInboxPetAvatar', () {
    testWidgets('рисует аватар с кольцом цвета питомца и значок типа события', (tester) async {
      await tester.pumpWidget(
        uiTestApp(
          const SizedBox.square(
            dimension: UiInboxItem.leadingSize,
            child: UiInboxPetAvatar(
              imageUrl: null,
              ringColor: Colors.teal,
              typeIcon: Icons.vaccines,
            ),
          ),
        ),
      );

      final avatar = tester.widget<UiPetAvatar>(find.byType(UiPetAvatar));

      expect(avatar.borderColor, Colors.teal);
      expect(find.byIcon(Icons.vaccines), findsOneWidget);
    });
  });

  group('UiIconButton: бейдж', () {
    Future<void> pump(WidgetTester tester, int count) => tester.pumpWidget(
      uiTestApp(
        Padding(
          padding: const EdgeInsets.all(24),
          child: UiIconButton(
            icon: Icons.notifications_none,
            semanticLabel: 'Уведомления',
            badgeCount: count,
          ),
        ),
      ),
    );

    testWidgets('без непрочитанных бейджа нет', (tester) async {
      await pump(tester, 0);

      expect(find.text('0'), findsNothing);
    });

    testWidgets('показывает число', (tester) async {
      await pump(tester, 3);

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('большое число сокращается до «9+»', (tester) async {
      await pump(tester, 12);

      expect(find.text('9+'), findsOneWidget);
      expect(find.text('12'), findsNothing);
    });

    testWidgets('бейдж не мешает нажатию на кнопку', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(
          Padding(
            padding: const EdgeInsets.all(24),
            child: UiIconButton(
              icon: Icons.notifications_none,
              semanticLabel: 'Уведомления',
              badgeCount: 4,
              onPressed: () => taps++,
            ),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.notifications_none));

      expect(taps, 1);
    });
  });
}
