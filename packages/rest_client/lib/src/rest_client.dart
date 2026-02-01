/// {@template rest_client}
/// A REST client for making HTTP requests.
/// {@endtemplate}
import 'multipart/rest_client_multipart_file.dart';

abstract interface class RestClient {
  /// Sends a GET request to the given [path].
  Future<Map<String, Object?>?> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  });

  /// Sends a multipart/form-data request to the given [path].
  ///
  /// Use [fields] for обычных form-полей, и [files] для файлов.
  /// По умолчанию используется метод POST.
  Future<Map<String, Object?>?> multipart(
    String path, {
    String method = 'POST',
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
    Map<String, String>? fields,
    List<RestClientMultipartFile>? files,
  });

  /// Sends a POST request to the given [path].
  Future<Map<String, Object?>?> post(
    String path, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  });

  /// Sends a PUT request to the given [path].
  Future<Map<String, Object?>?> put(
    String path, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  });

  /// Sends a DELETE request to the given [path].
  Future<Map<String, Object?>?> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  });

  /// Sends a PATCH request to the given [path].
  Future<Map<String, Object?>?> patch(
    String path, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  });
}
