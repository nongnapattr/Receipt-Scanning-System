import 'package:flutter/material.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_color.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_constant.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_spacer.dart';

class AppButton {
  static Widget buttonPrimary({required String text, Function()? onPress, bool? isAdd}) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: AppConstant.borderRdPrimary,
          ),
        ),
        backgroundColor: const MaterialStatePropertyAll(AppColor.primary),
      ),
      onPressed: onPress,
      child: Padding(
        padding: AppSpacer.padAll8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isAdd == true) ...[
              const Icon(Icons.add, color: Colors.white),
              SizedBox(width: AppSpacer.gap8),
            ],
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buttonPrimaryWithIcon({required String text, Function()? onPress}) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: AppConstant.borderRdPrimary,
          ),
        ),
        backgroundColor: const MaterialStatePropertyAll(AppColor.primary),
      ),
      onPressed: onPress,
      child: Padding(
        padding: AppSpacer.padAll24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white)
          ],
        ),
      ),
    );
  }

  static Widget buttonSecondary({required String text, Function()? onPress}) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: AppConstant.borderRdPrimary,
          ),
        ),
        backgroundColor: const MaterialStatePropertyAll(Colors.white),
      ),
      onPressed: onPress,
      child: Padding(
        padding: AppSpacer.padAll8,
        child: Text(
          text,
          style: const TextStyle(color: AppColor.primary, fontSize: 20),
        ),
      ),
    );
  }

  static Widget buttonSecondaryWithIcon({required String text, Function()? onPress}) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: AppConstant.borderRdPrimary,
          ),
        ),
        backgroundColor: const MaterialStatePropertyAll(Colors.white),
      ),
      onPressed: onPress,
      child: Padding(
        padding: AppSpacer.padAll24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(color: AppColor.primary, fontSize: 20),
            ),
            const Icon(Icons.arrow_forward, color: AppColor.primary)
          ],
        ),
      ),
    );
  }
}
