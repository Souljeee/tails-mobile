/// Форматирует российский номер `+79990000000` для показа: `+7 999 000-00-00`.
///
/// Если номер не подходит под формат, возвращает его без изменений.
String formatPhoneForDisplay(String phoneNumber) {
  final match = RegExp(r'^\+7(\d{3})(\d{3})(\d{2})(\d{2})$').firstMatch(phoneNumber);

  if (match == null) {
    return phoneNumber;
  }

  return '+7 ${match[1]} ${match[2]}-${match[3]}-${match[4]}';
}
