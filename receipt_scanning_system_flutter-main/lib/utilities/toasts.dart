import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toasts {
  static void toastSuccess(BuildContext context, String message, int time) {
    FToast fToast;
    fToast = FToast();
    fToast.init(context);

    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.greenAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check),
            const SizedBox(
              width: 12.0,
            ),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: time),
    );
  }

  static void toastError(BuildContext context, String message, int time) {
    FToast fToast;
    fToast = FToast();
    fToast.init(context);

    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.redAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded),
            const SizedBox(
              width: 12.0,
            ),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: time),
    );
  }

  static void toastWarning(BuildContext context, String message, int time) {
    FToast fToast;
    fToast = FToast();
    fToast.init(context);

    fToast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.orangeAccent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.report_gmailerrorred_rounded),
            const SizedBox(
              width: 12.0,
            ),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: time),
    );
  }
}
