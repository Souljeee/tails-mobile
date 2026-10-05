import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_formatter.dart';

TailsLogEvent _event({
  TailsLogLevel level = TailsLogLevel.info,
  TailsLogCategory category = TailsLogCategory.network,
  String message = '→ #42 GET /pets/3/',
  String? source,
  Map<String, Object?> data = const {},
  Object? error,
  StackTrace? stackTrace,
}) => TailsLogEvent(
  sequence: 1,
  time: DateTime(2026, 10, 5, 12, 3, 41, 5),
  level: level,
  category: category,
  message: message,
  source: source,
  data: data,
  error: error,
  stackTrace: stackTrace,
);

void main() {
  const formatter = TailsLogFormatter();

  group('TailsLogFormatter', () {
    test('главная строка: время, уровень, категория и сообщение', () {
      expect(formatter.format(_event()), ['12:03:41.005 I NET  → #42 GET /pets/3/']);
    });

    test('метка категории BLOC не получает лишних пробелов', () {
      final lines = formatter.format(
        _event(category: TailsLogCategory.bloc, level: TailsLogLevel.debug, message: 'a'),
      );

      expect(lines.single, '12:03:41.005 D BLOC a');
    });

    test('добавляет компонент перед сообщением', () {
      final lines = formatter.format(_event(source: 'PetRepository', message: 'Загружено'));

      expect(lines.single, '12:03:41.005 I NET  PetRepository  Загружено');
    });

    test('поля выводятся как ключ=значение', () {
      final lines = formatter.format(_event(data: {'petId': 3, 'ok': true, 'missing': null}));

      expect(lines.single, endsWith(' petId=3 ok=true missing=null'));
    });

    test('строки с пробелами и пустые значения берутся в кавычки', () {
      final lines = formatter.format(_event(data: {'name': 'Белла Мия', 'empty': ''}));

      expect(lines.single, endsWith(' name="Белла Мия" empty=""'));
    });

    test('списки и карты выводятся как JSON', () {
      final lines = formatter.format(
        _event(
          data: {
            'ids': [1, 2],
            'query': {'type': 'dog'},
          },
        ),
      );

      expect(lines.single, endsWith(' ids=[1,2] query={"type":"dog"}'));
    });

    test('объекты внутри коллекций выводятся через toString', () {
      final lines = formatter.format(
        _event(
          data: {
            'items': [_Opaque()],
          },
        ),
      );

      expect(lines.single, endsWith(' items=["opaque"]'));
    });

    test('произвольный объект выводится через toString', () {
      final lines = formatter.format(_event(data: {'value': _Opaque()}));

      expect(lines.single, endsWith(' value=opaque'));
    });

    test('ошибка идёт отдельной строкой с отступом', () {
      final lines = formatter.format(_event(error: StateError('сбой')));

      expect(lines, hasLength(2));
      expect(lines[1], '    ↳ Bad state: сбой');
    });

    test('многострочная ошибка сохраняет отступ', () {
      final lines = formatter.format(_event(error: 'первая\nвторая'));

      expect(lines.sublist(1), ['    ↳ первая', '      вторая']);
    });

    test('стек ограничивается и сообщает, сколько строк скрыто', () {
      final stack = StackTrace.fromString(List.generate(5, (i) => '#$i frame$i').join('\n'));

      final lines = const TailsLogFormatter(
        maxStackTraceLines: 2,
      ).format(_event(stackTrace: stack));

      expect(lines, [
        '12:03:41.005 I NET  → #42 GET /pets/3/',
        '    #0 frame0',
        '    #1 frame1',
        '    … ещё 3 строк стека',
      ]);
    });

    test('includeDate добавляет дату', () {
      final lines = const TailsLogFormatter(includeDate: true).format(_event());

      expect(lines.single, startsWith('2026-10-05 12:03:41.005 I NET '));
    });
  });

  group('TailsLogFormatter.console', () {
    const console = TailsLogFormatter.console();

    test('главная строка не меняется, если данных нет', () {
      expect(console.format(_event()), ['12:03:41.005 I NET  → #42 GET /pets/3/']);
    });

    test('сетевая запись: метаданные одной строкой, параметры запроса отдельно', () {
      final lines = console.format(
        _event(
          source: 'api',
          data: {
            'screen': 'pets',
            'bloc': 'PetsBloc#6',
            'query': {'date_from': '2026-10-06', 'date_to': '2026-11-05'},
          },
        ),
      );

      expect(lines, [
        '12:03:41.005 I NET  api  → #42 GET /pets/3/',
        '    │ screen=pets  bloc=PetsBloc#6',
        '    │ query: date_from=2026-10-06  date_to=2026-11-05',
      ]);
    });

    test('заголовки скрыты', () {
      final lines = console.format(
        _event(
          data: {
            'headers': {'content-type': 'application/json'},
            'screen': 'pets',
          },
        ),
      );

      expect(lines.join('\n'), isNot(contains('content-type')));
      expect(lines.last, '    │ screen=pets');
    });

    test('плоское тело выводится одной строкой', () {
      final lines = console.format(
        _event(
          data: {
            'body': {'id': 12, 'name': 'Бакс'},
          },
        ),
      );

      expect(lines.last, '    │ body: id=12  name=Бакс');
    });

    test('вложенное тело JSON выводится читаемым блоком', () {
      final lines = console.format(
        _event(
          data: {
            'body': {
              'id': 12,
              'pet': {'name': 'Бакс'},
            },
          },
        ),
      );

      expect(lines, [
        '12:03:41.005 I NET  → #42 GET /pets/3/',
        '    │ body: {',
        '    │   "id": 12,',
        '    │   "pet": {',
        '    │     "name": "Бакс"',
        '    │   }',
        '    │ }',
      ]);
    });

    test('просмотр сокращает списки, ключи, длинные строки и глубокую вложенность', () {
      final lines = console.format(
        _event(
          data: {
            'body': [
              {for (var i = 0; i < 9; i++) 'k$i': i, 'long': 'я' * 200},
              {
                'a': {
                  'b': {
                    'c': {'d': 1},
                  },
                },
              },
              {'third': 3},
            ],
          },
        ),
      );
      final text = lines.join('\n');

      expect(text, contains('"…": "+4"'));
      expect(text, contains('"… +1"'));
      expect(text, contains('{…1}'));
      expect(text, isNot(contains('third')));
    });

    test('длинное тело ограничивается числом строк', () {
      final lines = console.format(
        _event(
          data: {
            'body': {
              for (var i = 0; i < 6; i++) 'k$i': List.filled(2, {'x': i}),
            },
          },
        ),
      );

      expect(lines.length, lessThanOrEqualTo(26));
    });

    test('HTML-страница сводится к заголовку', () {
      final lines = console.format(
        _event(
          level: TailsLogLevel.warning,
          data: {
            'body': '<!DOCTYPE html>\n<html>\n<head><title>Page not found at /x/</title></head>',
          },
        ),
      );

      expect(lines.last, startsWith('    │ body: [HTML] Page not found at /x/ ('));
    });

    test('обычный длинный текст сворачивается и обрезается', () {
      final lines = console.format(_event(data: {'body': 'слово ' * 100}));

      expect(lines.last, contains('… (ещё '));
      expect(lines.last.length, lessThan(260));
    });

    test('короткие поля не сетевых записей остаются в главной строке', () {
      final lines = console.format(
        _event(
          category: TailsLogCategory.bloc,
          level: TailsLogLevel.debug,
          message: 'Idle → Idle',
          data: {
            'event': {'status': 'authorized'},
          },
        ),
      );

      expect(lines, ['12:03:41.005 D BLOC Idle → Idle event={"status":"authorized"}']);
    });

    test('длинные значения не сетевых записей выносятся блоком', () {
      final lines = console.format(
        _event(
          category: TailsLogCategory.bloc,
          message: 'x',
          data: {
            'state': {for (var i = 0; i < 8; i++) 'key$i': 'значение $i'},
          },
        ),
      );

      expect(lines.first, '12:03:41.005 I BLOC x');
      expect(lines[1], startsWith('    │ state: {'));
    });

    test('ошибка и стек выводятся как раньше', () {
      final lines = console.format(
        _event(message: 'Сбой', error: StateError('x'), data: {'screen': 'pets'}),
      );

      expect(lines[1], '    │ screen=pets');
      expect(lines[2], '    ↳ Bad state: x');
    });
  });
}

class _Opaque {
  @override
  String toString() => 'opaque';
}
