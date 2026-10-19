import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:tails_mobile/src/core/permissions/permission_denied_sheet.dart';
import 'package:tails_mobile/src/core/utils/photo_picking.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  const settingsChannel = MethodChannel('flutter.baseflow.com/permissions/methods');
  late List<String> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      settingsChannel,
      (call) async {
        calls.add(call.method);

        return true;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      settingsChannel,
      null,
    );
  });

  Future<void> open(WidgetTester tester, AppPermission permission) async {
    await tester.pumpWidget(
      uiTestApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showPermissionDeniedSheet(context, permission),
            child: const Text('Открыть'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
  }

  group('showPermissionDeniedSheet', () {
    testWidgets('камера: сообщение и кнопка в настройки', (tester) async {
      await open(tester, AppPermission.camera);

      expect(find.text('Нет доступа к камере'), findsOneWidget);

      await tester.tap(find.text('Открыть настройки'));
      await tester.pumpAndSettle();

      expect(calls, contains('openAppSettings'));
      expect(find.text('Нет доступа к камере'), findsNothing);
    });

    testWidgets('фото: «Не сейчас» закрывает шит и не открывает настройки', (tester) async {
      await open(tester, AppPermission.photos);

      expect(find.text('Нет доступа к фото'), findsOneWidget);

      await tester.tap(find.text('Не сейчас'));
      await tester.pumpAndSettle();

      expect(calls, isNot(contains('openAppSettings')));
      expect(find.text('Нет доступа к фото'), findsNothing);
    });
  });

  group('guardPhotoAccess', () {
    test('отказ в доступе превращается в PhotoAccessDeniedException', () {
      expect(
        guardPhotoAccess<void>(
          ImageSource.camera,
          () async => throw PlatformException(code: 'camera_access_denied'),
        ),
        throwsA(isA<PhotoAccessDeniedException>()),
      );
    });

    test('прочие ошибки пробрасываются как есть', () {
      expect(
        guardPhotoAccess<void>(
          ImageSource.gallery,
          () async => throw PlatformException(code: 'other'),
        ),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}
