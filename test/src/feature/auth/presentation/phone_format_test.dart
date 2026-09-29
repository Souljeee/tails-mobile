import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/auth/presentation/utils/phone_format.dart';

void main() {
  test('formatPhoneForDisplay форматирует российский номер', () {
    expect(formatPhoneForDisplay('+79990001122'), '+7 999 000-11-22');
  });

  test('formatPhoneForDisplay не меняет номер в неожиданном формате', () {
    expect(formatPhoneForDisplay('+7(999)000-11-22'), '+7(999)000-11-22');
    expect(formatPhoneForDisplay('+7999'), '+7999');
  });
}
