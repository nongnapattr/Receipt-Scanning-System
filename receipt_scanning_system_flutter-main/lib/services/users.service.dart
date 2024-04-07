import 'dart:io';
import 'package:receipt_scanning_system_flutter/models/user.model.dart';
import 'package:receipt_scanning_system_flutter/utilities/globals.dart';
import 'package:receipt_scanning_system_flutter/utilities/params-option.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'auth.service.dart';

class UsersService {
  static const className = 'UsersService';
  final _baseUrl = '${Globals.API}/users';

  Future<http.Response?> create(UserModel model) async {
    var headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    return await http.post(Uri.parse(_baseUrl), body: convert.jsonEncode(model.toJson()), headers: headers);
  }

  Future<http.Response> update(UserModel model) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    return await http.put(Uri.parse('$_baseUrl/${model.userId}'), body: convert.jsonEncode(model.toJson()), headers: headers);
  }

  Future<http.Response> delete(String userId) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    return await http.delete(Uri.parse('$_baseUrl/$userId'), headers: headers);
  }

  Future<UserModel> findOne(String userId) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await http.get(Uri.parse('$_baseUrl/$userId'), headers: headers);
    if (response.statusCode == 200) {
      return UserModel.fromJson(convert.jsonDecode(response.body));
    } else {
      print("$className findOne() failed with status ${response.statusCode}. ${response.body.toString()}");
      return UserModel();
    }
  }

  Future<List<UserModel>> findAll(ParamsOption? params) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await http.get(Uri.parse('$_baseUrl${params?.toParams(params.toJson()) ?? ''}'), headers: headers);
    if (response.statusCode == 200) {
      return parseData(response.body);
    } else {
      print("$className findAll() failed with status ${response.statusCode}. ${response.body.toString()}");
      return <UserModel>[];
    }
  }

  List<UserModel> parseData(String responseBody) {
    final parsed = convert.jsonDecode(responseBody)["data"].cast<Map<String, dynamic>>();
    return parsed.map<UserModel>((json) => UserModel.fromJson(json)).toList();
  }
}
