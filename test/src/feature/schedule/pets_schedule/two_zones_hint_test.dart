import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/utils/persisted_entry.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/schedule_hint_store.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/presentation/widgets/two_zones_hint.dart';

import '../../../../helpers/ui_test_app.dart';

class _MemoryEntry extends PersistedEntry<bool> {
  _MemoryEntry({this.fails = false});

  bool? value;
  final bool fails;

  @override
  Future<bool?> read() async {
    if (fails) {
      throw Exception('storage down');
    }

    return value;
  }

  @override
  Future<void> set(bool value) async {
    if (fails) {
      throw Exception('storage down');
    }
    this.value = value;
  }

  @override
  Future<void> remove() async => value = null;
}

void main() {
  testWidgets('подсказка показывается один раз и закрывается кнопкой «Понятно»', (tester) async {
    final entry = _MemoryEntry();
    final store = ScheduleHintStore(entry: entry);

    await tester.pumpWidget(uiTestApp(TwoZonesHint(store: store)));
    await tester.pumpAndSettle();

    expect(find.text('Карточка теперь делится на две части'), findsOneWidget);

    await tester.tap(find.text('Понятно'));
    await tester.pumpAndSettle();

    expect(find.text('Карточка теперь делится на две части'), findsNothing);
    expect(entry.value, isTrue);

    // Следующий показ экрана: подсказка уже не появляется.
    await tester.pumpWidget(uiTestApp(TwoZonesHint(store: store, key: UniqueKey())));
    await tester.pumpAndSettle();

    expect(find.text('Карточка теперь делится на две части'), findsNothing);
  });

  testWidgets('сбой хранилища не показывает подсказку и не роняет экран', (tester) async {
    await tester.pumpWidget(
      uiTestApp(TwoZonesHint(store: ScheduleHintStore(entry: _MemoryEntry(fails: true)))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Понятно'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('сбой записи при закрытии не роняет экран', (tester) async {
    final entry = _MemoryEntry();
    final store = ScheduleHintStore(entry: entry);

    await tester.pumpWidget(uiTestApp(TwoZonesHint(store: store)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Понятно'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
