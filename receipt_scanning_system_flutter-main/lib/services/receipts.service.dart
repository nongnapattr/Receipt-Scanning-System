import 'dart:io';
import 'package:receipt_scanning_system_flutter/models/receipt-group.model.dart';
import 'package:receipt_scanning_system_flutter/models/receipt.model.dart';
import 'package:receipt_scanning_system_flutter/utilities/globals.dart';
import 'package:receipt_scanning_system_flutter/utilities/params-option.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'auth.service.dart';

class ReceiptsService {
  static const className = 'ReceiptsService';
  final _baseUrl = '${Globals.API}/receipts';

  Future<http.Response?> create(ReceiptModel model) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    return await http.post(Uri.parse(_baseUrl), body: convert.jsonEncode(model.toJson()), headers: headers);
  }

  Future<http.Response> update(ReceiptModel model) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    return await http.put(Uri.parse('$_baseUrl/${model.receiptId}'), body: convert.jsonEncode(model.toJson()), headers: headers);
  }

  Future<http.Response> delete(String receiptId) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    return await http.delete(Uri.parse('$_baseUrl/$receiptId'), headers: headers);
  }

  Future<ReceiptModel> findOne(String receiptId) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await http.get(Uri.parse('$_baseUrl/$receiptId'), headers: headers);
    if (response.statusCode == 200) {
      return ReceiptModel.fromJson(convert.jsonDecode(response.body));
    } else {
      print("$className findOne() failed with status ${response.statusCode}. ${response.body.toString()}");
      return ReceiptModel();
    }
  }

  Future<List<ReceiptModel>> findAll(ParamsOption? params) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await http.get(Uri.parse('$_baseUrl${params?.toParams(params.toJson()) ?? ''}'), headers: headers);
    if (response.statusCode == 200) {
      return parseData(response.body);
    } else {
      print("$className findAll() failed with status ${response.statusCode}. ${response.body.toString()}");
      return <ReceiptModel>[];
    }
  }

  Future<List<ReceiptGroupModel>> groupByDate(String? searchText) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await http.get(Uri.parse('$_baseUrl/actions/group-by-date/${searchText == '' ? '-' : (searchText ?? '-')}'), headers: headers);
    if (response.statusCode == 200) {
      return parseDataGroup(response.body);
    } else {
      print("$className groupByDate() failed with status ${response.statusCode}. ${response.body.toString()}");
      return <ReceiptGroupModel>[];
    }
  }

  Future<List<ReceiptGroupModel>> groupByType(int type) async {
    var headers = {HttpHeaders.authorizationHeader: 'Bearer ${await AuthService().getToken()}', HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await http.get(Uri.parse('$_baseUrl/actions/group-by-type/$type'), headers: headers);
    if (response.statusCode == 200) {
      return parseDataGroup(response.body);
    } else {
      print("$className groupByDate() failed with status ${response.statusCode}. ${response.body.toString()}");
      return <ReceiptGroupModel>[];
    }
  }

  List<ReceiptModel> parseData(String responseBody) {
    final parsed = convert.jsonDecode(responseBody)["data"].cast<Map<String, dynamic>>();
    return parsed.map<ReceiptModel>((json) => ReceiptModel.fromJson(json)).toList();
  }

  List<ReceiptGroupModel> parseDataGroup(String responseBody) {
    final parsed = convert.jsonDecode(responseBody)["data"].cast<Map<String, dynamic>>();
    return parsed.map<ReceiptGroupModel>((json) => ReceiptGroupModel.fromJson(json)).toList();
  }
}
