import 'package:http/http.dart' as http;

Future<http.MultipartFile> multipartFileFromPath({
  required String field,
  required String path,
  String? filename,
}) {
  return http.MultipartFile.fromPath(
    field,
    path,
    filename: filename,
  );
}
