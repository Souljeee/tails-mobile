import 'package:rest_client/rest_client.dart';

/// Запрос, который получил [FakeRestClient].
class RecordedRequest {
  const RecordedRequest({
    required this.method,
    required this.path,
    this.body,
    this.fields,
    this.files,
    this.queryParams,
  });

  final String method;
  final String path;
  final Map<String, Object?>? body;
  final Map<String, String>? fields;
  final List<RestClientMultipartFile>? files;
  final Map<String, String?>? queryParams;
}

/// Подставной [RestClient]: запоминает запросы и отвечает через [handler].
///
/// Если [handler] не задан, на любой запрос возвращается `null`.
class FakeRestClient implements RestClient {
  FakeRestClient({this.handler});

  Object? Function(RecordedRequest request)? handler;

  final List<RecordedRequest> requests = [];

  RecordedRequest get last => requests.last;

  Future<Object?> _handle(RecordedRequest request) async {
    requests.add(request);

    return handler?.call(request);
  }

  @override
  Future<Object?> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  }) => _handle(RecordedRequest(method: 'GET', path: path, queryParams: queryParams));

  @override
  Future<Object?> post(
    String path, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  }) => _handle(RecordedRequest(method: 'POST', path: path, body: body));

  @override
  Future<Object?> put(
    String path, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  }) => _handle(RecordedRequest(method: 'PUT', path: path, body: body));

  @override
  Future<Object?> patch(
    String path, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  }) => _handle(RecordedRequest(method: 'PATCH', path: path, body: body));

  @override
  Future<Object?> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  }) => _handle(RecordedRequest(method: 'DELETE', path: path));

  @override
  Future<Object?> multipart(
    String path, {
    String method = 'POST',
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
    Map<String, String>? fields,
    List<RestClientMultipartFile>? files,
  }) => _handle(RecordedRequest(method: method, path: path, fields: fields, files: files));
}

/// Токен-хранилище в памяти.
class FakeTokenStorage implements TokenStorage<OAuth2Token> {
  FakeTokenStorage([this.token]);

  OAuth2Token? token;
  int clearCalls = 0;

  @override
  Future<void> clear() async {
    clearCalls++;
    token = null;
  }

  @override
  Future<void> close() async {}

  @override
  Stream<OAuth2Token?> getStream() => const Stream.empty();

  @override
  Future<OAuth2Token?> load() async => token;

  @override
  Future<void> save(OAuth2Token tokenPair) async => token = tokenPair;
}
