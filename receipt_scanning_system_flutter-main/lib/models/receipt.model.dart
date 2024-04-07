class ReceiptModel {
  String? receiptId;
  String? receiptName;
  String? receiptDate;
  String? receiptTotal;
  String? receiptType;
  String? receiptImage;

  ReceiptModel({
    this.receiptId,
    this.receiptName,
    this.receiptDate,
    this.receiptTotal,
    this.receiptType,
    this.receiptImage,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> parsedJson) {
    try {
      return ReceiptModel(
        receiptId: parsedJson['_id'],
        receiptName: parsedJson['receipt_name'],
        receiptDate: parsedJson['receipt_date'],
        receiptTotal: parsedJson['receipt_total'],
        receiptType: parsedJson['receipt_type'],
        receiptImage: parsedJson['receipt_image'],
      );
    } catch (ex) {
      print('ReceiptModel ====> $ex');
      throw ('factory ReceiptModel.fromJson ====> $ex');
    }
  }

  Map<String, dynamic> toJson() => {
        'receipt_name': receiptName,
        'receipt_date': receiptDate,
        'receipt_total': receiptTotal,
        'receipt_type': receiptType,
        'receipt_image': receiptImage,
      };
}
