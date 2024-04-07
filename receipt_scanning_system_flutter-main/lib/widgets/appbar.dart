import 'package:flutter/material.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_color.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_constant.dart';
import 'package:sizer/sizer.dart';

PreferredSizeWidget customAppBar(BuildContext context, String title, bool isBool) {
  return AppBar(
    toolbarHeight: 10.h,
    shape: RoundedRectangleBorder(
      borderRadius: AppConstant.borderRdAppBar,
    ),
    title: Text(
      title,
      style: const TextStyle(color: Colors.white),
    ),
    centerTitle: true,
    backgroundColor: AppColor.primary,
    leading: isBool == true
        ? GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          )
        : null,
  );
}
