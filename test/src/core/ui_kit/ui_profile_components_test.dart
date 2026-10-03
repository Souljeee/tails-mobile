import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/colors/ui_palette.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_notice_banner/ui_notice_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_photo_picker/ui_photo_picker.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_profile_card/ui_profile_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_sheets/ui_action_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_sheets/ui_confirm_sheet.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  group('UiNavRow', () {
    testWidgets('показывает значение и шеврон и реагирует на нажатие', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(
          UiNavRow(
            icon: Icons.notifications_none,
            title: 'Уведомления',
            value: 'Включены',
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.text('Уведомления'), findsOneWidget);
      expect(find.text('Включены'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.text('Уведомления'));
      expect(taps, 1);
    });

    testWidgets('без onTap шеврона нет', (tester) async {
      await tester.pumpWidget(
        uiTestApp(const UiNavRow(icon: Icons.info_outline, title: 'Версия', value: '1.0.0')),
      );

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('переключатель меняется нажатием по строке', (tester) async {
      bool? changed;

      await tester.pumpWidget(
        uiTestApp(
          UiNavRow.toggle(
            icon: Icons.directions_walk,
            title: 'Прогулки',
            isOn: true,
            onChanged: (value) => changed = value,
          ),
        ),
      );

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

      await tester.tap(find.text('Прогулки'));

      expect(changed, isFalse);
    });

    testWidgets('неактивная строка не нажимается и не переключается', (tester) async {
      var taps = 0;
      var changes = 0;

      await tester.pumpWidget(
        uiTestApp(
          Column(
            children: [
              UiNavRow(
                icon: Icons.info_outline,
                title: 'Строка',
                enabled: false,
                onTap: () => taps++,
              ),
              UiNavRow.toggle(
                icon: Icons.directions_walk,
                title: 'Тумблер',
                isOn: false,
                enabled: false,
                onChanged: (_) => changes++,
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Строка'));
      await tester.tap(find.text('Тумблер'));

      expect(taps, 0);
      expect(changes, 0);
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    });

    testWidgets('опасная плитка красит заголовок цветом danger', (tester) async {
      await tester.pumpWidget(
        uiTestApp(const UiNavRow(icon: Icons.logout, title: 'Выйти', tone: UiNavRowTone.danger)),
      );

      final text = tester.widget<Text>(find.text('Выйти'));

      expect(text.style?.color, const UiPalette.light().danger);
    });

    testWidgets('помещается при увеличенном шрифте и внутри группы', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: uiTestApp(
            UiGroupedList(
              children: [
                UiNavRow(
                  icon: Icons.help_outline,
                  title: 'Помощь и обратная связь',
                  subtitle: 'Сообщить о проблеме',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('UiProfileCard', () {
    testWidgets('показывает имя и подпись', (tester) async {
      await tester.pumpWidget(
        uiTestApp(
          UiProfileCard(
            name: ' Анна ',
            namePlaceholder: 'Ваше имя',
            caption: 'Редактировать профиль',
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Анна'), findsOneWidget);
      expect(find.text('Ваше имя'), findsNothing);
      expect(find.text('Редактировать профиль'), findsOneWidget);
    });

    testWidgets('без имени показывает серую подсказку', (tester) async {
      await tester.pumpWidget(
        uiTestApp(
          UiProfileCard(
            name: '  ',
            namePlaceholder: 'Ваше имя',
            caption: 'Редактировать профиль',
            onTap: () {},
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Ваше имя'));

      expect(text.style?.color, const UiPalette.light().ink3);
    });

    testWidgets('нажимается целиком', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(
          UiProfileCard(
            name: null,
            namePlaceholder: 'Ваше имя',
            caption: 'Редактировать профиль',
            onTap: () => taps++,
          ),
        ),
      );

      await tester.tap(find.text('Редактировать профиль'));

      expect(taps, 1);
    });
  });

  group('UiPhotoPicker', () {
    testWidgets('без фото показывает камеру и подсказку, с фото — картинку и «Изменить»', (
      tester,
    ) async {
      await tester.pumpWidget(
        uiTestApp(
          UiPhotoPicker(hasPhoto: false, label: 'Добавить фото', hint: 'Подсказка', onTap: () {}),
        ),
      );

      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Подсказка'), findsOneWidget);

      await tester.pumpWidget(
        uiTestApp(
          UiPhotoPicker(
            hasPhoto: true,
            label: 'Изменить фото',
            hint: 'Подсказка',
            image: const ColoredBox(color: Colors.red, key: Key('photo')),
            onTap: () {},
          ),
        ),
      );

      expect(find.byKey(const Key('photo')), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.text('Подсказка'), findsNothing);
    });

    testWidgets('нажатие на круг вызывает onTap', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(UiPhotoPicker(hasPhoto: false, label: 'Добавить фото', onTap: () => taps++)),
      );

      await tester.tap(find.byIcon(Icons.photo_camera_outlined));

      expect(taps, 1);
    });
  });

  group('UiNoticeBanner', () {
    testWidgets('показывает заголовок, текст и действие', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(
          UiNoticeBanner(
            title: 'Уведомления отключены',
            text: 'Включите их в настройках',
            actionLabel: 'Открыть настройки',
            onAction: () => taps++,
          ),
        ),
      );

      expect(find.text('Уведомления отключены'), findsOneWidget);
      expect(find.text('Включите их в настройках'), findsOneWidget);

      await tester.tap(find.text('Открыть настройки'));

      expect(taps, 1);
    });

    testWidgets('без действия кнопки нет', (tester) async {
      await tester.pumpWidget(uiTestApp(const UiNoticeBanner(text: 'Только текст')));

      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('шторки', () {
    testWidgets('showUiActionSheet возвращает значение выбранного пункта', (tester) async {
      String? result;

      await tester.pumpWidget(
        uiTestApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showUiActionSheet<String>(
                  context: context,
                  title: 'Фото профиля',
                  cancelLabel: 'Отмена',
                  groups: const [
                    [
                      UiActionSheetItem<String>(
                        value: 'gallery',
                        icon: Icons.photo_library_outlined,
                        label: 'Галерея',
                      ),
                      UiActionSheetItem(
                        value: 'camera',
                        icon: Icons.photo_camera_outlined,
                        label: 'Камера',
                      ),
                    ],
                  ],
                );
              },
              child: const Text('Открыть'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();

      expect(find.text('Фото профиля'), findsOneWidget);

      await tester.tap(find.text('Камера'));
      await tester.pumpAndSettle();

      expect(result, 'camera');
    });

    testWidgets('showUiConfirmSheet: true только по кнопке подтверждения', (tester) async {
      bool? result;

      await tester.pumpWidget(
        uiTestApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showUiConfirmSheet(
                  context: context,
                  title: 'Выйти из аккаунта?',
                  message: 'Данные сохранятся',
                  confirmLabel: 'Выйти',
                  cancelLabel: 'Отмена',
                );
              },
              child: const Text('Открыть'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(result, isFalse);

      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выйти'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });
}
