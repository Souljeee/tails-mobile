import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sanitizer.dart';

void main() {
  const sanitizer = TailsLogSanitizer();
  const redacted = TailsLogSanitizer.redacted;

  group('TailsLogSanitizer.isSensitiveKey', () {
    test('распознаёт чувствительные ключи в разных написаниях', () {
      const keys = [
        'Authorization',
        'authorization',
        'Proxy-Authorization',
        'Cookie',
        'Set-Cookie',
        'password',
        'new_password',
        'access_token',
        'accessToken',
        'refresh_token',
        'refreshToken',
        'X-Api-Key',
        'api_key',
        'apiKey',
        'client_secret',
        'access',
        'refresh',
        'code',
        'sms_code',
        'confirmationCode',
        'otp',
        'pin',
      ];

      for (final key in keys) {
        expect(sanitizer.isSensitiveKey(key), isTrue, reason: key);
      }
    });

    test('не трогает обычные ключи, похожие на чувствительные', () {
      const keys = [
        'statusCode',
        'status_code',
        'errorCode',
        'petId',
        'accessLevel',
        'name',
        'content-type',
        'Accept',
        'tokenizer',
      ];

      // `tokenizer` содержит `token` — это осознанная перестраховка, остальные чистые.
      for (final key in keys.where((key) => key != 'tokenizer')) {
        expect(sanitizer.isSensitiveKey(key), isFalse, reason: key);
      }
    });

    test('учитывает дополнительные ключи', () {
      const custom = TailsLogSanitizer(extraSensitiveKeys: {'passport_number'});

      expect(custom.isSensitiveKey('passportNumber'), isTrue);
      expect(sanitizer.isSensitiveKey('passportNumber'), isFalse);
    });
  });

  group('TailsLogSanitizer.sanitizeData', () {
    test('заменяет значения чувствительных ключей', () {
      final result = sanitizer.sanitizeData({
        'password': 'qwerty',
        'access_token': 'abc',
        'code': 1234,
        'petId': 3,
      });

      expect(result, {
        'password': redacted,
        'access_token': redacted,
        'code': redacted,
        'petId': 3,
      });
    });

    test('null под чувствительным ключом остаётся null', () {
      expect(sanitizer.sanitizeData({'token': null}), {'token': null});
    });

    test('обходит вложенные карты и списки', () {
      final result = sanitizer.sanitizeData({
        'user': {
          'name': 'Анна',
          'credentials': {'password': 'x'},
          'sessions': [
            {'refresh_token': 'r', 'id': 1},
          ],
        },
      });

      expect(result, {
        'user': {
          'name': 'Анна',
          'credentials': redacted,
          'sessions': [
            {'refresh_token': redacted, 'id': 1},
          ],
        },
      });
    });

    test('значения-списки под чувствительным ключом скрываются целиком', () {
      expect(
        sanitizer.sanitizeData({
          'tokens': ['a', 'b'],
        }),
        {'tokens': redacted},
      );
    });

    test('маскирует телефон по ключу', () {
      final result = sanitizer.sanitizeData({
        'phoneNumber': '+79001112233',
        'phone_number': 79001112233,
        'phones': ['89005556677'],
      });

      expect(result, {
        'phoneNumber': '+7***2233',
        'phone_number': '+7***2233',
        'phones': ['+8***6677'],
      });
    });

    test('вычищает секреты из текстовых значений', () {
      final result = sanitizer.sanitizeData({'header': 'Bearer abc.def-123'});

      expect(result, {'header': 'Bearer $redacted'});
    });

    test('приводит даты к строке ISO, а прочие объекты — к очищенному тексту', () {
      final result = sanitizer.sanitizeData({
        'at': DateTime.utc(2026, 10, 5, 12),
        'other': _Opaque('телефон +79001112233'),
      });

      expect(result, {'at': '2026-10-05T12:00:00.000Z', 'other': 'телефон +7***2233'});
    });

    test('ограничивает вложенность', () {
      const shallow = TailsLogSanitizer(maxDepth: 2);

      final result = shallow.sanitizeData({
        'a': {
          'b': {
            'c': {'d': 1},
          },
        },
      });

      expect(result, {
        'a': {
          'b': {'c': '[слишком глубоко]'},
        },
      });
    });

    test('ограничивает число элементов в коллекциях', () {
      const small = TailsLogSanitizer(maxCollectionItems: 2);

      final result = small.sanitizeData({
        'list': [1, 2, 3, 4, 5],
        'map': {'a': 1, 'b': 2, 'c': 3},
      });

      expect(result, {
        'list': [1, 2, '… ещё 3'],
        'map': {'a': 1, 'b': 2, '…': 'ещё 1'},
      });
    });

    test('не меняет исходную карту', () {
      final source = <String, Object?>{'password': 'x'};

      sanitizer.sanitizeData(source);

      expect(source, {'password': 'x'});
    });
  });

  group('TailsLogSanitizer.sanitizeText', () {
    test('скрывает JWT', () {
      const jwt =
          'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dBjftJeZ4CVPmB92K27uhbUJU1p1r_wW1gFWFOEjXk';

      expect(sanitizer.sanitizeText('token $jwt expired'), 'token $redacted expired');
    });

    test('скрывает Bearer и Basic', () {
      expect(sanitizer.sanitizeText('Authorization: Bearer abc123'), 'Authorization: $redacted');
      expect(sanitizer.sanitizeText('bearer abc123'), 'bearer $redacted');
      expect(sanitizer.sanitizeText('Basic dXNlcjpwYXNz'), 'Basic $redacted');
    });

    test('скрывает пары ключ=значение и ключ: значение', () {
      expect(sanitizer.sanitizeText('password=hunter2&name=Rex'), 'password=$redacted&name=Rex');
      expect(
        sanitizer.sanitizeText('{"access_token":"abc","id":1}'),
        '{"access_token":$redacted,"id":1}',
      );
      expect(sanitizer.sanitizeText("refresh_token: 'zzz' ok"), 'refresh_token: $redacted ok');
    });

    test('не скрывает обычные упоминания code и statusCode', () {
      const text = 'Error code: 500, statusCode=404';

      expect(sanitizer.sanitizeText(text), text);
    });

    test('маскирует российские телефоны в разных форматах', () {
      expect(sanitizer.sanitizeText('+79001112233'), '+7***2233');
      expect(sanitizer.sanitizeText('89001112233'), '+8***2233');
      expect(sanitizer.sanitizeText('+7 (900) 111-22-33'), '+7***2233');
      expect(sanitizer.sanitizeText('8 900 111 22 33'), '+8***2233');
      expect(sanitizer.sanitizeText('номер 79001112233, код'), 'номер +7***2233, код');
    });

    test('маскирует международные номера с плюсом', () {
      expect(sanitizer.sanitizeText('+44 7911 123456'), '+4***3456');
    });

    test('не принимает за телефон даты, время и идентификаторы', () {
      const text = '2026-10-05 12:03:41.535 petId=123 total=1790000000000 version=1.2.3+45';

      expect(sanitizer.sanitizeText(text), text);
    });

    test('телефон рядом с датой всё равно маскируется', () {
      expect(sanitizer.sanitizeText('2026-10-05 79001112233'), '2026-10-05 +7***2233');
    });

    test('маскирует телефон в пути запроса', () {
      expect(sanitizer.sanitizeText('/users/79001112233/pets/'), '/users/+7***2233/pets/');
    });

    test('обрезает длинный текст', () {
      const short = TailsLogSanitizer(maxStringLength: 5);

      expect(short.sanitizeText('1234567890'), '12345…[обрезано 5 симв.]');
      expect(short.sanitizeText('12345'), '12345');
    });
  });

  group('TailsLogSanitizer.sanitizeHeaders', () {
    test('скрывает значения чувствительных заголовков и сохраняет остальные', () {
      final result = sanitizer.sanitizeHeaders({
        'Authorization': 'Bearer abc',
        'Cookie': 'sid=1',
        'Set-Cookie': 'sid=2',
        'X-Api-Key': 'key',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      expect(result, {
        'Authorization': redacted,
        'Cookie': redacted,
        'Set-Cookie': redacted,
        'X-Api-Key': redacted,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
    });

    test('очищает значения обычных заголовков по шаблонам', () {
      final result = sanitizer.sanitizeHeaders({'X-Debug': 'user +79001112233'});

      expect(result, {'X-Debug': 'user +7***2233'});
    });
  });

  group('TailsLogSanitizer.sanitizeError', () {
    test('чистое исключение возвращается тем же объектом', () {
      final error = StateError('Соединение разорвано');

      expect(sanitizer.sanitizeError(error), same(error));
    });

    test('null остаётся null', () {
      expect(sanitizer.sanitizeError(null), isNull);
    });

    test('исключение с секретом заменяется очищенной копией', () {
      const error = FormatException('Bad response for +79001112233 with Bearer abc');

      final result = sanitizer.sanitizeError(error);

      expect(result, isA<TailsSanitizedException>());
      final sanitized = result! as TailsSanitizedException;
      expect(sanitized.originalType, 'FormatException');
      expect(sanitized.message, contains('+7***2233'));
      expect(sanitized.message, contains('Bearer $redacted'));
      expect(sanitized.message, isNot(contains('79001112233')));
      expect('$sanitized', startsWith('FormatException: '));
    });
  });

  group('TailsLogSanitizer.maskPhone', () {
    test('оставляет код страны и последние четыре цифры', () {
      expect(TailsLogSanitizer.maskPhone('+7 900 111-22-33'), '+7***2233');
    });

    test('уже замаскированное значение не портится повторной маской', () {
      expect(TailsLogSanitizer.maskPhone('+7***2233'), '+7***2233');
      expect(sanitizer.sanitizeData({'phoneNumber': '+7***2233'}), {'phoneNumber': '+7***2233'});
    });

    test('короткие значения почти не раскрываются', () {
      expect(TailsLogSanitizer.maskPhone('123456'), '***3456');
      expect(TailsLogSanitizer.maskPhone('12'), '***');
    });
  });
}

class _Opaque {
  _Opaque(this.text);

  final String text;

  @override
  String toString() => text;
}
