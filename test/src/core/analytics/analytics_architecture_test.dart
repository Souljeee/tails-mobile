import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  void check(String package) {
    test('$package импортируется только в core/analytics/sinks и инициализации', () {
      final offenders = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;

        final path = entity.path.replaceAll(r'\', '/');
        if (path.startsWith('lib/src/core/analytics/sinks/')) continue;

        if (entity.readAsStringSync().contains('package:$package/')) offenders.add(path);
      }

      expect(offenders, isEmpty, reason: 'Используйте TailsAnalytics вместо прямых вызовов.');
    });
  }

  check('appmetrica_plugin');
  check('firebase_analytics');
}
