import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_empty_state/ui_empty_state.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  group('showUiBottomSheet', () {
    testWidgets('показывает содержимое и закрывается по «Отмена»', (tester) async {
      await tester.pumpWidget(
        uiTestApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showUiBottomSheet<void>(
                context: context,
                builder: (_) => const Column(
                  children: [
                    UiSheetHeader(title: 'Новое событие', cancelLabel: 'Отмена'),
                    Text('Содержимое'),
                  ],
                ),
              ),
              child: const Text('Открыть'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();

      expect(find.text('Новое событие'), findsOneWidget);
      expect(find.text('Содержимое'), findsOneWidget);

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.text('Содержимое'), findsNothing);
    });
  });

  group('showUiBottomSheet: свайп вниз', () {
    Widget host({required bool enableDrag, bool canPop = true}) => uiTestApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showUiBottomSheet<void>(
            context: context,
            enableDrag: enableDrag,
            builder: (_) => PopScope(
              canPop: canPop,
              child: const Column(
                children: [
                  UiSheetHeader(title: 'Заголовок', cancelLabel: 'Отмена'),
                  SizedBox(height: 200, child: Text('Содержимое')),
                ],
              ),
            ),
          ),
          child: const Text('Открыть'),
        ),
      ),
    );

    Future<void> open(WidgetTester tester) async {
      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();
    }

    Offset handle(WidgetTester tester) =>
        tester.getTopLeft(find.byType(UiSheetHeader)) + const Offset(150, -10);

    testWidgets('закрывается, если тянуть ручку', (tester) async {
      await tester.pumpWidget(host(enableDrag: true));
      await open(tester);

      await tester.dragFrom(handle(tester), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.text('Содержимое'), findsNothing);
    });

    testWidgets('без enableDrag тоже закрывается за ручку', (tester) async {
      await tester.pumpWidget(host(enableDrag: false));
      await open(tester);

      await tester.dragFrom(handle(tester), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.text('Содержимое'), findsNothing);
    });

    testWidgets('без enableDrag свайп по содержимому не закрывает', (tester) async {
      await tester.pumpWidget(host(enableDrag: false));
      await open(tester);

      await tester.dragFrom(tester.getCenter(find.text('Содержимое')), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.text('Содержимое'), findsOneWidget);
    });

    testWidgets('защита от закрытия (PopScope) не обходится свайпом за ручку', (tester) async {
      await tester.pumpWidget(host(enableDrag: false, canPop: false));
      await open(tester);

      await tester.dragFrom(handle(tester), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.text('Содержимое'), findsOneWidget);
    });
  });

  group('UiSheetHeader', () {
    testWidgets('«Отмена» стоит у левого края, а не рядом с заголовком', (tester) async {
      await tester.pumpWidget(
        uiTestApp(
          const Column(
            children: [UiSheetHeader(title: 'Новый питомец', cancelLabel: 'Отмена')],
          ),
        ),
      );

      final cancel = tester.getRect(find.text('Отмена'));
      final title = tester.getRect(find.text('Новый питомец'));

      expect(cancel.left, lessThan(24));
      expect(title.left - cancel.right, greaterThan(40));
    });

    testWidgets('длинный заголовок при крупном шрифте не переполняет шапку', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: uiTestApp(
            const UiSheetHeader(title: 'Сохранить изменения', cancelLabel: 'Отмена'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Отмена'), findsOneWidget);
    });
  });

  group('UiSectionHeader', () {
    testWidgets('показывает заголовок капсом и вызывает действие', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(
          UiSectionHeader(title: 'Основное', actionLabel: 'Изменить', onActionTap: () => taps++),
        ),
      );

      expect(find.text('ОСНОВНОЕ'), findsOneWidget);

      await tester.tap(find.text('Изменить'));

      expect(taps, 1);
    });
  });

  group('UiTopBar', () {
    testWidgets('показывает заголовок и вызывает onBack', (tester) async {
      var backs = 0;

      await tester.pumpWidget(uiTestApp(UiTopBar(title: 'Порода · кошки', onBack: () => backs++)));
      await tester.tap(find.byIcon(Icons.chevron_left));

      expect(find.text('Порода · кошки'), findsOneWidget);
      expect(backs, 1);
    });

    testWidgets('без onBack не показывает кнопку назад', (tester) async {
      await tester.pumpWidget(uiTestApp(const UiTopBar(title: 'Порода')));

      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });
  });

  group('UiLargeTitleHeader', () {
    testWidgets('показывает заголовок и подпись', (tester) async {
      await tester.pumpWidget(
        uiTestApp(const UiLargeTitleHeader(title: 'Мои питомцы', subtitle: '2 питомца')),
      );

      expect(find.text('Мои питомцы'), findsOneWidget);
      expect(find.text('2 питомца'), findsOneWidget);
    });
  });

  group('UiEmptyState', () {
    testWidgets('показывает тексты и вызывает действие', (tester) async {
      var actions = 0;

      await tester.pumpWidget(
        uiTestApp(
          UiEmptyState(
            title: 'Ошибка загрузки',
            message: 'Повторите позднее',
            actionLabel: 'Повторить',
            onAction: () => actions++,
          ),
        ),
      );
      await tester.tap(find.text('Повторить'));

      expect(find.text('Ошибка загрузки'), findsOneWidget);
      expect(find.text('Повторите позднее'), findsOneWidget);
      expect(actions, 1);
    });
  });

  group('showUiSnackBar', () {
    testWidgets('показывает сообщение', (tester) async {
      await tester.pumpWidget(
        uiTestApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showUiSnackBar(context, message: 'Произошла ошибка'),
              child: const Text('Показать'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Показать'));
      await tester.pump();

      expect(find.text('Произошла ошибка'), findsOneWidget);
    });
  });
}
