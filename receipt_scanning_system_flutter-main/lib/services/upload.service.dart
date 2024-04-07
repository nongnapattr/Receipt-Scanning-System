import 'package:http/http.dart' as http;
import 'package:receipt_scanning_system_flutter/utilities/globals.dart';

class UploadService {
  static const className = 'UploadService';
  final _baseUrl = Globals.URL_IMAGE;

  Future<http.StreamedResponse?> uploadImage(String? file, String path) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.fields.addAll({'path': '${Globals.PATH_IMAGE}/$path'});
      request.files.add(await http.MultipartFile.fromPath('file', file ?? ''));
      http.StreamedResponse res = await request.send();
      return res;
    } catch (e) {
      print("$className uploadImage(String file, String type) failed with status ${e.toString()}");
      rethrow;
    }
  }
}
