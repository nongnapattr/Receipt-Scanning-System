import 'package:receipt_scanning_system_flutter/models/receipt.model.dart';

class ReceiptGroupModel {
  String? date;
  String? type;
  int? count;
  double? price;
  List<ReceiptModel>? items;

  ReceiptGroupModel({
    this.date,
    this.type,
    this.count,
    this.price,
    this.items,
  });

  factory ReceiptGroupModel.fromJson(Map<String, dynamic> parsedJson) {
    try {
      var itemsList = (parsedJson['items'] ?? []) as List;
      return ReceiptGroupModel(
        date: parsedJson['date'],
        type: parsedJson['type'] ?? '',
        count: parsedJson['count'],
        price: double.parse(parsedJson['price'].toString()),
        items: itemsList.map((element) => ReceiptModel.fromJson(element)).toList(),
      );
    } catch (ex) {
      print('ReceiptGroupModel ====> $ex');
      throw ('factory ReceiptGroupModel.fromJson ====> $ex');
    }
  }
}
