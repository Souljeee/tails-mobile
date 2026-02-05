import 'package:meta/meta.dart';
import 'package:rest_client/rest_client.dart';

/// Описание файла для multipart-запроса.
///
/// Поддерживаются два сценария:
/// - [RestClientMultipartFile.bytes] — кросс‑платформенно (включая web).
/// - [RestClientMultipartFile.path] — только для IO (mobile/desktop). На web
///   будет выброшен [UnsupportedError]/[ClientException] при попытке отправки.
@immutable
final class RestClientMultipartFile {
  const RestClientMultipartFile.bytes({
    required this.field,
    required this.bytes,
    required this.filename,
  }) : path = null;

  const RestClientMultipartFile.path({
    required this.field,
    required this.path,
    this.filename,
  }) : bytes = null;

  /// Имя поля (form field name) для файла.
  final String field;

  /// Сырые bytes файла.
  final List<int>? bytes;

  /// Путь к файлу на диске (только IO-платформы).
  final String? path;

  /// Имя файла в multipart-запросе.
  ///
  /// Для [RestClientMultipartFile.bytes] — обязательно.
  /// Для [RestClientMultipartFile.path] — опционально (будет взято из basename).
  final String? filename;

  bool get isBytes => bytes != null;
  bool get isPath => path != null;

  @override
  String toString() => 'RestClientMultipartFile('
      'field: $field, '
      'bytes: ${bytes == null ? 'null' : '${bytes!.length} bytes'}, '
      'path: $path, '
      'filename: $filename'
      ')';
}
