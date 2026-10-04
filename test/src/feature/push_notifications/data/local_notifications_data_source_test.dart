import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/local_notifications_data_source.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('на iOS ничего не инициализирует и не показывает', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final dataSource = FlutterLocalNotificationsDataSource();

    await expectLater(dataSource.initialize(), completes);
    await expectLater(
      dataSource.show(id: 1, title: 'Корм', body: 'Пора', payload: const {'event_id': '7'}),
      completes,
    );
  });
}
