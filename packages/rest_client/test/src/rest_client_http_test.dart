import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:rest_client/rest_client.dart';

final class _InspectingClient extends http.BaseClient {
  _InspectingClient(this._onSend);

  final Future<http.StreamedResponse> Function(http.BaseRequest request) _onSend;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _onSend(request);
}

void main() {
  group('RestClientHttp', () {
    test('returns normally', () {
      final mockClient = http_testing.MockClient(
        (request) async => http.Response('{"data": {"hello": "world"}}', 200),
      );

      final restClient = RestClientHttp(
        baseUrl: 'https://example.com',
        client: mockClient,
      );

      expectLater(
        restClient.send(path: '/', method: 'GET'),
        completion(
          isA<Map<String, Object?>>().having(
            (json) => json['hello'],
            'Data contains hello',
            'world',
          ),
        ),
      );
    });

    test("adds body if it's not null", () async {
      final mockClient = http_testing.MockClient((request) async {
        expect(
          request.body,
          '{"hello":"world"}',
          reason: 'Body should be {"hello":"world"}',
        );

        return http.Response('{"data": {"hello": "world"}}', 200);
      });

      final restClient = RestClientHttp(
        baseUrl: 'https://example.com',
        client: mockClient,
      );

      await expectLater(
        restClient.send(path: '/', method: 'POST', body: {'hello': 'world'}),
        completion(
          isA<Map<String, Object?>>().having(
            (json) => json['hello'],
            'Data contains hello',
            'world',
          ),
        ),
      );
    });

    test('adds headers', () {
      final mockClient = http_testing.MockClient((request) async {
        expect(request.headers['hello'], 'world');
        return http.Response('{"data": {"hello": "world"}}', 200);
      });

      final restClient = RestClientHttp(
        baseUrl: 'https://example.com',
        client: mockClient,
      );

      expectLater(
        restClient.send(
          path: '/',
          method: 'GET',
          headers: {'hello': 'world'},
        ),
        completion(
          isA<Map<String, Object?>>().having(
            (json) => json['hello'],
            'Data contains hello',
            'world',
          ),
        ),
      );
    });

    test('throws RestClientException on error', () {
      final mockClient = http_testing.MockClient(
        (request) async => http.Response('{"error": {}}', 400),
      );

      final restClient = RestClientHttp(
        baseUrl: 'https://example.com',
        client: mockClient,
      );

      expectLater(
        restClient.send(path: '/', method: 'GET'),
        throwsA(isA<StructuredBackendException>()),
      );
    });

    test('sends multipart with fields and files', () async {
      final client = _InspectingClient((request) async {
        expect(request, isA<http.MultipartRequest>());
        final multipart = request as http.MultipartRequest;

        expect(multipart.method, 'POST');
        expect(multipart.fields['hello'], 'world');
        expect(multipart.files, hasLength(1));

        final file = multipart.files.single;
        expect(file.field, 'file');
        expect(file.filename, 'file.bin');
        expect(file.length, 3);

        final responseBytes = utf8.encode('{"data": {"ok": true}}');
        return http.StreamedResponse(Stream.value(responseBytes), 200);
      });

      final restClient = RestClientHttp(
        baseUrl: 'https://example.com',
        client: client,
      );

      final result = await restClient.multipart(
        '/',
        fields: const {'hello': 'world'},
        files: const [
          RestClientMultipartFile.bytes(
            field: 'file',
            bytes: [1, 2, 3],
            filename: 'file.bin',
          ),
        ],
      );

      expect((result as Map)['ok'], isTrue);
    });
  });
}
