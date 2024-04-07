import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receipt_scanning_system_flutter/models/receipt-group.model.dart';
import 'package:receipt_scanning_system_flutter/screens/dashboard/add_receipt_screen.dart';
import 'package:receipt_scanning_system_flutter/services/receipts.service.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_button.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_color.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_constant.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_spacer.dart';
import 'package:receipt_scanning_system_flutter/utilities/constants.dart';
import 'package:receipt_scanning_system_flutter/utilities/datetime_format.dart';
import 'package:receipt_scanning_system_flutter/utilities/toasts.dart';
import 'package:sizer/sizer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController searchText = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<ReceiptGroupModel> itemsReceipt = [];

  @override
  void initState() {
    onLoadData();
    super.initState();
  }

  onLoadData() {
    ReceiptsService().groupByDate(null).then((value) {
      setState(() {
        itemsReceipt = value;
      });
    }).catchError((ex) {
      Toasts.toastError(context, Constants.error, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Expanded(
        //   flex: 1,
        //   child: TextField(
        //     controller: searchText,
        //     decoration: const InputDecoration(
        //       border: OutlineInputBorder(),
        //       prefixIcon: Icon(Icons.search),
        //       hintText: 'ค้นหารายการ',
        //     ),
        //   ),
        // ),
        SizedBox(height: AppSpacer.gap8),
        Expanded(
          flex: 8,
          child: itemsReceipt.isEmpty
              ? const Center(
                  child: Text(
                    'ไม่มีรายการ',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      for (ReceiptGroupModel item in itemsReceipt)
                        Card(
                          color: AppColor.white,
                          child: Container(
                            width: 100.w,
                            padding: AppSpacer.padAll16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateTimeFormat.date(item.date!),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                SizedBox(height: AppSpacer.gap8),
                                Container(
                                  padding: AppSpacer.padAll8,
                                  decoration: BoxDecoration(
                                    color: AppColor.grey,
                                    borderRadius: BorderRadius.all(AppConstant.radiusCard),
                                  ),
                                  child: Text('${item.count} รายการ'),
                                ),
                                SizedBox(height: AppSpacer.gap8),
                                Container(
                                  padding: AppSpacer.padAll16,
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.all(AppConstant.radiusCard),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'รายจ่าย',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${item.price?.toStringAsFixed(2)}THB',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        SizedBox(height: AppSpacer.gap8),
        Expanded(
          flex: 1,
          child: AppButton.buttonPrimary(
            text: 'เพิ่มรายการ',
            onPress: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: AppSpacer.padAll24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                // Navigator.pop(context);
                                XFile? image = await _picker.pickImage(source: ImageSource.camera);
                                if (image?.path != '') {
                                  Navigator.pop(context);
                                  Get.to(AddReceiptScreen(itemFile: File(image!.path)))?.whenComplete(() => null).then((value) => onLoadData());
                                }
                              },
                              child: Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.grey,
                                    borderRadius: BorderRadius.all(AppConstant.radiusCard),
                                  ),
                                  padding: AppSpacer.padAll24,
                                  child: const Column(
                                    children: [
                                      Icon(Icons.camera_alt_outlined),
                                      Text('Camera'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacer.gap24),
                            GestureDetector(
                              onTap: () async {
                                XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                if (image?.path != '') {
                                  Navigator.pop(context);
                                  Get.to(AddReceiptScreen(itemFile: File(image!.path)))?.whenComplete(() => null).then((value) => onLoadData());
                                }
                              },
                              child: Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.bgCream,
                                    borderRadius: BorderRadius.all(AppConstant.radiusCard),
                                  ),
                                  padding: AppSpacer.padAll24,
                                  child: const Column(
                                    children: [
                                      Icon(Icons.photo_outlined),
                                      Text('Gallery'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            isAdd: true,
          ),
        ),
      ],
    );
  }
}
