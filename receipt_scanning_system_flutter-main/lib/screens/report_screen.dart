import 'package:flutter/material.dart';
import 'package:receipt_scanning_system_flutter/models/receipt-group.model.dart';
import 'package:receipt_scanning_system_flutter/services/receipts.service.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_color.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_constant.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_spacer.dart';
import 'package:receipt_scanning_system_flutter/utilities/constants.dart';
import 'package:receipt_scanning_system_flutter/utilities/toasts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int isSelected = 1;

  List<ChartData> chartData = [
    // ChartData('อาหาร', 535.00, const Color.fromRGBO(177, 137, 255, 1)),
    // ChartData('เสื้อผ้า', 138.00, const Color.fromRGBO(234, 98, 173, 1)),
    // ChartData('ของใช้', 234.00, const Color.fromRGBO(255, 213, 115, 1)),
    // ChartData('อื่นๆ', 152.00, const Color.fromRGBO(194, 194, 194, 1))
  ];
  List<ReceiptGroupModel> itemsReceipt = [];
  double totalPrice = 0;

  @override
  void initState() {
    onLoadData();
    super.initState();
  }

  onLoadData() {
    itemsReceipt = [];
    chartData = [];
    totalPrice = 0;
    ReceiptsService().groupByType(isSelected).then((value) {
      setState(() {
        itemsReceipt = value;
        for (ReceiptGroupModel item in itemsReceipt) {
          totalPrice += item.price ?? 0;
          item.price = double.parse(item.price!.toStringAsFixed(2));
          chartData.add(ChartData(
            item.type ?? '',
            item.price ?? 0,
            item.type == 'อาหาร'
                ? const Color.fromRGBO(177, 137, 255, 1)
                : item.type == 'เสื้อผ้า'
                    ? const Color.fromARGB(255, 255, 143, 205)
                    : item.type == 'ของใช้'
                        ? const Color.fromRGBO(255, 213, 115, 1)
                        : item.type == 'ที่พัก'
                            ? const Color.fromARGB(255, 148, 255, 248)
                            : item.type == 'รักษา'
                                ? const Color.fromARGB(255, 255, 40, 40)
                                : item.type == 'การศึกษา'
                                    ? const Color.fromARGB(255, 59, 138, 222)
                                    : item.type == 'เดินทาง'
                                        ? const Color.fromARGB(255, 159, 255, 142)
                                        : const Color.fromRGBO(194, 194, 194, 1),
          ));
        }
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
          child: SingleChildScrollView(
            reverse: true,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    isSelected = 1;
                    onLoadData();
                  }),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacer.gap16, vertical: AppSpacer.gap8),
                    decoration: BoxDecoration(
                      color: isSelected == 1 ? AppColor.primary : AppColor.bgBlue,
                      borderRadius: BorderRadius.all(AppConstant.radiusCard),
                    ),
                    child: const Text(
                      'รายวัน',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacer.gap8),
                GestureDetector(
                  onTap: () => setState(() {
                    isSelected = 2;
                    onLoadData();
                  }),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacer.gap16, vertical: AppSpacer.gap8),
                    decoration: BoxDecoration(
                      color: isSelected == 2 ? AppColor.primary : AppColor.bgBlue,
                      borderRadius: BorderRadius.all(AppConstant.radiusCard),
                    ),
                    child: const Text(
                      'รายสัปดาห์',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacer.gap8),
                GestureDetector(
                  onTap: () => setState(() {
                    isSelected = 3;
                    onLoadData();
                  }),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacer.gap16, vertical: AppSpacer.gap8),
                    decoration: BoxDecoration(
                      color: isSelected == 3 ? AppColor.primary : AppColor.bgBlue,
                      borderRadius: BorderRadius.all(AppConstant.radiusCard),
                    ),
                    child: const Text(
                      'รายเดือน',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacer.gap8),
                GestureDetector(
                  onTap: () => setState(() {
                    isSelected = 4;
                    onLoadData();
                  }),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacer.gap16, vertical: AppSpacer.gap8),
                    decoration: BoxDecoration(
                      color: isSelected == 4 ? AppColor.primary : AppColor.bgBlue,
                      borderRadius: BorderRadius.all(AppConstant.radiusCard),
                    ),
                    child: const Text(
                      'รายปี',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: itemsReceipt.isEmpty
              ? const Center(
                  child: Text(
                    'ไม่มีรายการ',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : SfCircularChart(
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    borderColor: AppColor.grey,
                    borderWidth: 5,
                    color: AppColor.primary,
                  ),
                  series: <CircularSeries>[
                    DoughnutSeries<ChartData, String>(
                      dataSource: chartData,
                      pointColorMapper: (ChartData data, _) => data.color,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      dataLabelMapper: (ChartData data, _) => '${data.x} ${data.y}',
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                      ),
                    ),
                  ],
                ),
        ),
        Expanded(
          flex: 1,
          child: Center(
              child: Text(
            'รวมทั้งหมด : ${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20),
          )),
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}
