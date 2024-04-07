import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_scanning_system_flutter/models/receipt-group.model.dart';
import 'package:receipt_scanning_system_flutter/models/receipt.model.dart';
import 'package:receipt_scanning_system_flutter/screens/dashboard/add_receipt_screen.dart';
import 'package:receipt_scanning_system_flutter/services/receipts.service.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_color.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_constant.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_spacer.dart';
import 'package:receipt_scanning_system_flutter/utilities/constants.dart';
import 'package:receipt_scanning_system_flutter/utilities/datetime_format.dart';
import 'package:receipt_scanning_system_flutter/utilities/toasts.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  List<ReceiptGroupModel> itemsReceipt = [];
  TextEditingController searchText = TextEditingController();

  @override
  void initState() {
    onLoadData();
    super.initState();
  }

  onLoadData() {
    ReceiptsService().groupByDate(searchText.text).then((value) {
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
        Expanded(
          flex: 1,
          child: TextField(
            controller: searchText,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              hintText: 'ค้นหารายการ',
              suffixIcon: TextButton(
                onPressed: () {
                  onLoadData();
                },
                child: const Text('ค้นหา'),
              ),
            ),
          ),
        ),
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
                      for (ReceiptGroupModel item in itemsReceipt) ...[
                        SizedBox(height: AppSpacer.gap8),
                        Padding(
                          padding: AppSpacer.padX16,
                          child: Row(
                            children: [
                              const Expanded(child: Divider()),
                              Text(DateTimeFormat.date(item.date!)),
                              const Expanded(child: Divider()),
                            ],
                          ),
                        ),
                        for (ReceiptModel item2 in item.items!) ...[
                          SizedBox(height: AppSpacer.gap8),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ListView(
                                      shrinkWrap: true,
                                      children: [
                                        SizedBox(height: AppSpacer.gap16),
                                        ListTile(
                                          onTap: () {
                                            Navigator.pop(context);
                                            Get.to(AddReceiptScreen(itemReceipt: item2))?.whenComplete(() => null).then((value) {
                                              onLoadData();
                                            });
                                          },
                                          leading: const Icon(Icons.edit),
                                          title: const Text('แก้ไข'),
                                        ),
                                        ListTile(
                                          onTap: () {
                                            ReceiptsService().delete(item2.receiptId!).then((value) {
                                              onLoadData();
                                              Toasts.toastSuccess(context, Constants.deleteSuccess, 1);
                                              Navigator.pop(context);
                                            }).catchError((ex) {
                                              Toasts.toastError(context, Constants.error, 3);
                                            });
                                          },
                                          leading: const Icon(Icons.delete),
                                          title: const Text('ลบ'),
                                        ),
                                        SizedBox(height: AppSpacer.gap16),
                                      ],
                                    );
                                  });
                            },
                            child: Card(
                              color: Colors.white,
                              child: Padding(
                                padding: AppSpacer.padAll8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: AppSpacer.padAll16,
                                          decoration: BoxDecoration(
                                            color: AppColor.grey,
                                            borderRadius: BorderRadius.all(AppConstant.radiusCard),
                                          ),
                                          child: Image.asset(
                                            item2.receiptType == 'ของใช้'
                                                ? 'assets/icon-cart.png'
                                                : item2.receiptType == 'อาหาร'
                                                    ? 'assets/icon-food.png'
                                                    : item2.receiptType == 'เสื้อผ้า'
                                                        ? 'assets/icon-clothes.png'
                                                        : item2.receiptType == 'ที่พัก'
                                                            ? 'assets/icon-hotel.png'
                                                            : item2.receiptType == 'รักษา'
                                                                ? 'assets/icon-medical.png'
                                                                : item2.receiptType == 'การศึกษา'
                                                                    ? 'assets/icon-education.png'
                                                                    : item2.receiptType == 'เดินทาง'
                                                                        ? 'assets/icon-travel.png'
                                                                        : 'assets/icon-other.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                        SizedBox(width: AppSpacer.gap16),
                                        Text('${item2.receiptName} (${item2.receiptType})'),
                                      ],
                                    ),
                                    Text(
                                      '${item2.receiptTotal}THB',
                                      style: const TextStyle(color: Colors.red),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
