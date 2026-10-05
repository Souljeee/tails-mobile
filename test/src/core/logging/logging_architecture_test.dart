import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('package:logger импортируется только в core/logging/sinks', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      final path = entity.path.replaceAll(r'\', '/');
      if (path.startsWith('lib/src/core/logging/sinks/')) continue;

      if (entity.readAsStringSync().contains('package:logger/')) offenders.add(path);
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Приложение не должно зависеть от API пакета logger вне инфраструктурного слоя.',
    );
  });
}
