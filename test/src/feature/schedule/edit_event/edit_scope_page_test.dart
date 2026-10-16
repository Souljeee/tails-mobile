import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/edit_event/presentation/edit_scope_page.dart';

import '../../../../helpers/ui_test_app.dart';

void main() {
  setUpAll(() => initializeDateFormatting('ru'));

  Future<void> pump(
    WidgetTester tester, {
    required ThemeData theme,
    bool allowsOne = true,
    bool showResetHint = false,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: uiTestApp(
          theme: theme,
          EditScopePage(
            date: DateTime(2026, 10, 20),
            scope: allowsOne ? OccurrenceScope.one : OccurrenceScope.future,
            allowsOne: allowsOne,
            isLoading: false,
            isSaving: false,
            loadFailed: false,
            showResetHint: showResetHint,
            onScopeChanged: (_) {},
            onSave: () {},
            onDiscard: () {},
            onRetry: () {},
            onBack: () {},
          ),
        ),
      ),
    );
  }

  for (final entry in {
    'светлая': UiThemeData.lightTheme,
    'тёмная': UiThemeData.darkTheme,
  }.entries) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('${entry.key} тема, масштаб текста $scale: без переполнения', (tester) async {
        await pump(tester, theme: entry.value, showResetHint: true, textScale: scale);

        expect(tester.takeException(), isNull);
        expect(find.text('Только 20 октября'), findsOneWidget);
        expect(find.text('Не сохранять'), findsOneWidget);
      });
    }
  }

  testWidgets('«Только» недоступно: показано пояснение', (tester) async {
    await pump(tester, theme: UiThemeData.lightTheme, allowsOne: false);

    expect(
      find.text('Дата, питомец и повторение меняются только вместе со следующими событиями'),
      findsOneWidget,
    );
  });
}
