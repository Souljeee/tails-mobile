import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_button/ui_icon_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_avatar/ui_pet_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_tag/ui_pet_tag.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  group('UiCard', () {
    testWidgets('отображает содержимое', (tester) async {
      await tester.pumpWidget(uiTestApp(const UiCard(child: Text('Сексик'))));

      expect(find.text('Сексик'), findsOneWidget);
    });

    testWidgets('вызывает onTap', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(UiCard(onTap: () => taps++, child: const Text('Карточка'))),
      );
      await tester.tap(find.text('Карточка'));

      expect(taps, 1);
    });
  });

  group('UiChip', () {
    testWidgets('вызывает onTap и показывает подпись', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(UiChip(label: 'Все', selected: false, onTap: () => taps++)),
      );
      await tester.tap(find.text('Все'));

      expect(taps, 1);
    });

    testWidgets('выбранный чип помечен в семантике как selected', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(uiTestApp(const UiChip(label: 'Прогулка', selected: true)));

      expect(
        tester.getSemantics(find.byType(UiChip)),
        matchesSemantics(
          label: 'Прогулка',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('показывает leading-виджет', (tester) async {
      await tester.pumpWidget(
        uiTestApp(const UiChip(label: 'Сексик', selected: false, leading: Icon(Icons.pets))),
      );

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });
  });

  group('UiPetTag', () {
    testWidgets('показывает подпись', (tester) async {
      await tester.pumpWidget(uiTestApp(const UiPetTag(label: 'Собака', color: Color(0xFF6F8F6B))));

      expect(find.text('Собака'), findsOneWidget);
    });
  });

  group('UiPetAvatar', () {
    testWidgets('без фото показывает заглушку', (tester) async {
      await tester.pumpWidget(uiTestApp(const UiPetAvatar(imageUrl: null)));

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('соблюдает заданный размер', (tester) async {
      await tester.pumpWidget(uiTestApp(const UiPetAvatar(imageUrl: null, size: 64)));

      expect(tester.getSize(find.byType(UiPetAvatar)), const Size.square(64));
    });
  });

  group('UiIconBadge', () {
    testWidgets('показывает иконку и занимает заданный размер', (tester) async {
      await tester.pumpWidget(uiTestApp(const UiIconBadge(icon: Icons.schedule)));

      expect(find.byIcon(Icons.schedule), findsOneWidget);
      expect(tester.getSize(find.byType(UiIconBadge)), const Size.square(40));
    });
  });

  group('UiIconButton', () {
    testWidgets('имеет область касания 44×44 и вызывает onPressed', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(
          UiIconButton(icon: Icons.edit, semanticLabel: 'Изменить', onPressed: () => taps++),
        ),
      );
      await tester.tap(find.byType(UiIconButton));

      expect(tester.getSize(find.byType(UiIconButton)), const Size.square(44));
      expect(taps, 1);
    });
  });
}
