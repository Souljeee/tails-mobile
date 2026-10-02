import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tails_mobile/src/core/ui_kit/colors/ui_palette.dart';
import 'package:tails_mobile/src/feature/pets/core/data/pet_color_store.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_color_assignment.dart';

void main() {
  group('assignPetColors', () {
    test('размер палитры совпадает с UiPalette', () {
      expect(petPaletteSize, const UiPalette.light().petColors.length);
    });

    test('новым питомцам достаются разные цвета в порядке id, а не порядка списка', () {
      final colors = assignPetColors(petIds: [30, 10, 20], stored: {});

      expect(colors, {10: 0, 20: 1, 30: 2});
    });

    test('сохранённые цвета не меняются, когда питомцев добавляют', () {
      final colors = assignPetColors(petIds: [10, 20, 5], stored: {10: 0, 20: 1});

      expect(colors[10], 0);
      expect(colors[20], 1);
      expect(colors[5], 2);
    });

    test('после удаления питомца цвета остальных не сдвигаются, свободный цвет занимает новый', () {
      final afterDelete = assignPetColors(petIds: [10, 30], stored: {10: 0, 20: 1, 30: 2});

      expect(afterDelete, {10: 0, 30: 2});

      final afterAdd = assignPetColors(petIds: [10, 30, 40], stored: afterDelete);

      expect(afterAdd[40], 1);
    });

    test('когда питомцев больше палитры, цвета повторяются равномерно', () {
      final colors = assignPetColors(petIds: [1, 2, 3, 4, 5, 6, 7], stored: {}, paletteSize: 3);

      expect(colors.values.where((c) => c == 0), hasLength(3));
      expect(colors.values.where((c) => c == 1), hasLength(2));
      expect(colors.values.where((c) => c == 2), hasLength(2));
    });

    test('некорректный сохранённый индекс заменяется новым', () {
      final colors = assignPetColors(petIds: [1], stored: {1: 99});

      expect(colors[1], 0);
    });
  });

  group('PetColorStore', () {
    late PetColorStore store;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      store = PetColorStore(preferences: SharedPreferencesAsync());
    });

    test('sync запоминает цвета и возвращает те же при другом порядке списка', () async {
      final first = await store.sync([2, 1, 3]);
      final second = await store.sync([3, 2, 1]);

      expect(first, {1: 0, 2: 1, 3: 2});
      expect(second, first);
    });

    test('sync убирает удалённых и не сдвигает остальных', () async {
      await store.sync([1, 2, 3]);

      final after = await store.sync([1, 3]);

      expect(after, {1: 0, 3: 2});
    });

    test('colorIndexFor возвращает сохранённый цвет и выдаёт новый неизвестному питомцу', () async {
      await store.sync([1, 2]);

      expect(await store.colorIndexFor(2), 1);
      expect(await store.colorIndexFor(9), 2);
      expect(await store.colorIndexFor(9), 2);
    });

    test('повреждённые данные не ломают назначение', () async {
      await SharedPreferencesAsync().setString('pet_colors', 'не json');

      expect(await store.sync([1, 2]), {1: 0, 2: 1});
    });
  });
}
