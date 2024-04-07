import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:receipt_scanning_system_flutter/models/receipt.model.dart';
import 'package:receipt_scanning_system_flutter/services/receipts.service.dart';
import 'package:receipt_scanning_system_flutter/services/upload.service.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_button.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_spacer.dart';
import 'package:receipt_scanning_system_flutter/utilities/constants.dart';
import 'package:receipt_scanning_system_flutter/utilities/globals.dart';
import 'package:receipt_scanning_system_flutter/utilities/toasts.dart';
import 'package:receipt_scanning_system_flutter/widgets/appbar.dart';
import 'package:sizer/sizer.dart';

class AddReceiptScreen extends StatefulWidget {
  final File? itemFile;
  final ReceiptModel? itemReceipt;
  const AddReceiptScreen({
    super.key,
    this.itemFile,
    this.itemReceipt,
  });

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen> {
  TextEditingController receiptName = TextEditingController();
  TextEditingController receiptDate = TextEditingController();
  TextEditingController receiptTotal = TextEditingController();
  List<String> listValue = <String>[
    'อาหาร',
    'เสื้อผ้า',
    'ของใช้',
    'ที่พัก',
    'รักษา',
    'การศึกษา',
    'เดินทาง',
    'อื่นๆ'
  ];
  String dropdownValue = 'อาหาร';

  @override
  void initState() {
    onInitData();
    super.initState();
  }

  onInitData() {
    if (widget.itemFile != null) {
      List<String> datetime = DateTime.now().toString().split(' ');
      receiptDate.text =
          '${datetime[0]} ${datetime[1].split(':')[0]}:${datetime[1].split(':')[1]}';
      readTextFromImage();
    }
    if (widget.itemReceipt != null) {
      setState(() {
        receiptName.text = widget.itemReceipt?.receiptName ?? '';
        List<String> datetime =
            DateTime.parse(widget.itemReceipt?.receiptDate ?? '')
                .toLocal()
                .toString()
                .split(' ');
        receiptDate.text =
            '${datetime[0]} ${datetime[1].split(':')[0]}:${datetime[1].split(':')[1]}';
        receiptTotal.text = widget.itemReceipt?.receiptTotal ?? '';
        dropdownValue = widget.itemReceipt?.receiptType ?? 'อาหาร';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'กรอกรายละเอียดข้อมูล', true),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: Colors.transparent,
          padding: AppSpacer.padAll16,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: receiptName,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อร้าน',
                    hintText: 'Your ชื่อร้าน',
                  ),
                ),
                TextField(
                  controller: receiptDate,
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                  onTap: () {
                    DatePicker.showDateTimePicker(
                      context,
                      showTitleActions: true,
                      minTime: DateTime(DateTime.now().year - 2,
                          DateTime.now().month, DateTime.now().day),
                      maxTime: DateTime.now(),
                      onConfirm: (dateResult) {
                        final [date, time] = dateResult.toString().split(' ');
                        final [hour, minute, sec] = time.split(':');
                        print(sec);
                        setState(() {
                          receiptDate.text = '$date $hour:$minute';
                        });
                      },
                      currentTime: DateTime.parse(receiptDate.text),
                      locale: LocaleType.th,
                    );
                  },
                  decoration: const InputDecoration(
                    labelText: 'วันที่ / เวลา',
                    hintText: 'Your วันที่ / เวลา',
                  ),
                ),
                TextField(
                  controller: receiptTotal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ยอดสุทธิ',
                    hintText: 'Your ยอดสุทธิ',
                  ),
                ),
                SizedBox(height: AppSpacer.gap4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ประเภทค่าใช้จ่าย'),
                      SizedBox(height: AppSpacer.gap8),
                      DropdownButton<String>(
                        underline: Container(),
                        isDense: true,
                        isExpanded: true,
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_drop_down),
                        style: const TextStyle(color: Colors.black),
                        onChanged: (String? value) {
                          setState(() {
                            dropdownValue = value!;
                          });
                        },
                        items: listValue
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacer.gap16),
                Container(
                    child: widget.itemFile != null
                        ? Image.file(widget.itemFile!)
                        : widget.itemReceipt != null
                            ? Image.network(
                                '${Globals.URL_IMAGE}/${widget.itemReceipt?.receiptImage}')
                            : null),
                SizedBox(height: AppSpacer.gap16),
                SizedBox(
                  width: 100.w,
                  child: AppButton.buttonPrimary(
                    text: 'บันทึก',
                    onPress: () {
                      onSave();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onSave() {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (receiptName.text == '' ||
          receiptDate.text == '' ||
          receiptTotal.text == '') {
        Toasts.toastWarning(context, Constants.notFillForm, 3);
      } else {
        if (widget.itemFile != null) {
          UploadService()
              .uploadImage(widget.itemFile?.path, 'receipts')
              .then((value) async {
            dynamic responseData =
                convert.jsonDecode(await value!.stream.bytesToString());

            ReceiptModel model = ReceiptModel();
            model.receiptName = receiptName.text;
            model.receiptDate = receiptDate.text;
            model.receiptTotal = receiptTotal.text;
            model.receiptType = dropdownValue;
            model.receiptImage =
                '${responseData['filename']}?path=${Globals.PATH_IMAGE}/receipts';
            ReceiptsService().create(model).then((value) {
              Toasts.toastSuccess(context, Constants.createSuccess, 1);
              Navigator.pop(context);
            }).catchError((ex) {
              Toasts.toastError(context, Constants.error, 1);
            });
          }).catchError((ex) {
            Toasts.toastError(context, Constants.error, 1);
          });
        }
        if (widget.itemReceipt != null) {
          ReceiptModel model = widget.itemReceipt ?? ReceiptModel();
          model.receiptName = receiptName.text;
          model.receiptDate = receiptDate.text;
          model.receiptTotal = receiptTotal.text;
          model.receiptType = dropdownValue;
          ReceiptsService().update(model).then((value) {
            Toasts.toastSuccess(context, Constants.editSuccess, 1);
            Navigator.pop(context);
          }).catchError((ex) {
            Toasts.toastError(context, Constants.error, 1);
          });
        }
      }
    });
  }

  Future<void> readTextFromImage() async {
    final inputImage = InputImage.fromFile(widget.itemFile!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    String resultText = checkNumber(recognizedText);
    receiptTotal.text = resultText;
  }

  String checkNumber(RecognizedText items) {
    List res1 = [];
    List res2 = [];
    for (var item in items.blocks) {
      if (item.text.split(' ').length <= 3) {
        if (item.text.contains(' ')) {
          if (item.text.split(' ').length == 2) {
            if (double.tryParse(item.text.split(' ')[0]) != null) {
              res1.add(item.text.split(' ')[0]);
            } else {
              res1.add(item.text.split(' ')[1]);
            }
          } else {
            if (double.tryParse(item.text.split(' ')[0]) != null) {
              res1.add(item.text.split(' ')[0]);
            } else if (double.tryParse(item.text.split(' ')[1]) != null) {
              res1.add(item.text.split(' ')[1]);
            } else {
              res1.add(item.text.split(' ')[2]);
            }
          }
        } else {
          res1.add(item.text);
        }
      }
    }

    for (String item in res1) {
      if (double.tryParse(item) != null) {
        res2.add(item);
      }
    }

    for (int i = res2.length - 1; i >= 0; i--) {
      double value = double.parse(res2[i]);
      if (value > 0) {
        return value.toString();
      }
    }
    return '';
  }
}
