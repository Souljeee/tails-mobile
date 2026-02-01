import 'package:http/http.dart' as http;
import 'package:rest_client/rest_client.dart';

Future<http.MultipartFile> multipartFileFromPath({
  required String field,
  required String path,
  String? filename,
}) async {
  throw const ClientException(
    message: 'RestClientMultipartFile.path(...) не поддерживается на web. '
        'Используйте RestClientMultipartFile.bytes(...).',
  );
}

