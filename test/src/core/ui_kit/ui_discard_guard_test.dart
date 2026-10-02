import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_discard_guard/ui_discard_guard.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';

Widget _app({required bool hasChanges}) => MaterialApp(
  theme: UiThemeData.lightTheme,
  locale: const Locale('ru'),
  localizationsDelegates: Localization.localizationDelegates,
  supportedLocales: Localization.supportedLocales,
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => UiDiscardGuard(
                hasChanges: hasChanges,
                child: Scaffold(
                  body: Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Назад'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          child: const Text('Открыть'),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('без изменений экран закрывается сразу', (tester) async {
    await tester.pumpWidget(_app(hasChanges: false));
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Назад'));
    await tester.pumpAndSettle();

    expect(find.text('Открыть'), findsOneWidget);
    expect(find.text('Закрыть без сохранения?'), findsNothing);
  });

  testWidgets('с изменениями спрашивает подтверждение; «Продолжить» оставляет экран', (
    tester,
  ) async {
    await tester.pumpWidget(_app(hasChanges: true));
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Назад'));
    await tester.pumpAndSettle();

    expect(find.text('Закрыть без сохранения?'), findsOneWidget);

    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();

    expect(find.text('Закрыть без сохранения?'), findsNothing);
    expect(find.text('Назад'), findsOneWidget);
  });

  testWidgets('с изменениями «Закрыть» закрывает экран', (tester) async {
    await tester.pumpWidget(_app(hasChanges: true));
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Назад'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();

    expect(find.text('Открыть'), findsOneWidget);
    expect(find.text('Назад'), findsNothing);
  });
}
