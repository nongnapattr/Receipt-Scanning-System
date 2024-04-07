import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:receipt_scanning_system_flutter/models/jwt-payload.model.dart';
import 'package:receipt_scanning_system_flutter/utilities/globals.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  static const className = 'AuthService';
  final _baseUrl = Globals.API;

  Future<http.Response> login(String user, String pass) async {
    try {
      var headers = {HttpHeaders.contentTypeHeader: 'application/json'};
      return await http.post(Uri.parse('$_baseUrl/auth/login'), body: convert.jsonEncode({'username': user, 'password': pass}), headers: headers);
    } catch (e) {
      print("$className login(String user, String pass) failed with status ${e.toString()}");
      rethrow;
    }
  }

  Future<JwtPayloadModel> getProfile() async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await http.get(Uri.parse('$_baseUrl/auth/profile'), headers: headers);
    if (response.statusCode == 200) {
      return JwtPayloadModel.fromJson(convert.jsonDecode(response.body));
    } else {
      print("$className getProfile() failed with status ${response.statusCode}. ${response.body.toString()}");
      return JwtPayloadModel();
    }
  }

  void setRemember(String check) {
    _storage.write(key: 'remember', value: check);
  }

  Future<String?> getRemember() async {
    return await _storage.read(key: 'remember');
  }

  void setToken(String token) {
    _storage.write(key: 'token', value: token);
  }

  void removeToken() {
    // _storage.deleteAll();
    _storage.delete(key: 'token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);

    final payloadMap = convert.jsonDecode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }
    return payloadMap;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return convert.utf8.decode(convert.base64Url.decode(output));
  }

  Future<String> decodeUserId() async {
    var token = await getToken();
    return _parseJwt(token!)['user_id'];
  }
}
