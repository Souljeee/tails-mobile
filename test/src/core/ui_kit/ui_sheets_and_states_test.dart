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
