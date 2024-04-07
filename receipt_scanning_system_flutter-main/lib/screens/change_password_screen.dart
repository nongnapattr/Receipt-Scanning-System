import 'package:flutter/material.dart';
import 'package:receipt_scanning_system_flutter/models/user.model.dart';
import 'package:receipt_scanning_system_flutter/services/auth.service.dart';
import 'package:receipt_scanning_system_flutter/services/users.service.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_button.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_spacer.dart';
import 'package:receipt_scanning_system_flutter/utilities/constants.dart';
import 'package:receipt_scanning_system_flutter/utilities/toasts.dart';
import 'package:receipt_scanning_system_flutter/widgets/appbar.dart';
import 'package:sizer/sizer.dart';

class ChangePasswordScreen extends StatefulWidget {
  final UserModel? itemUser;
  const ChangePasswordScreen({
    super.key,
    this.itemUser,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isShowPassword = false;
  bool isShowPasswordNew = false;
  bool isShowPasswordConfirm = false;
  TextEditingController passwordOldController = TextEditingController();
  TextEditingController passwordNewController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'เปลี่ยนรหัสผ่าน', true),
      body: Container(
        padding: AppSpacer.padAll16,
        child: Column(
          children: [
            TextField(
              controller: passwordOldController,
              obscureText: !isShowPassword,
              decoration: InputDecoration(
                labelText: 'รหัสผ่านเดิม',
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      isShowPassword = !isShowPassword;
                    });
                  },
                  child: Icon(isShowPassword ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              autofillHints: const [AutofillHints.password],
            ),
            TextField(
              controller: passwordNewController,
              obscureText: !isShowPasswordNew,
              decoration: InputDecoration(
                labelText: 'รหัสผ่านใหม่',
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      isShowPasswordNew = !isShowPasswordNew;
                    });
                  },
                  child: Icon(isShowPasswordNew ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              autofillHints: const [AutofillHints.newPassword],
            ),
            TextField(
              controller: passwordConfirmController,
              obscureText: !isShowPasswordConfirm,
              decoration: InputDecoration(
                labelText: 'ยืนยันรหัสผ่านใหม่',
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      isShowPasswordConfirm = !isShowPasswordConfirm;
                    });
                  },
                  child: Icon(isShowPasswordConfirm ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              autofillHints: const [AutofillHints.newPassword],
            ),
            SizedBox(height: AppSpacer.gap16),
            SizedBox(
              width: 100.w,
              child: AppButton.buttonPrimary(
                text: 'ตกลง',
                onPress: () {
                  onSave();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  onSave() {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (passwordOldController.text == '' || passwordNewController.text == '' || passwordConfirmController.text == '') {
        Toasts.toastWarning(context, Constants.notFillForm, 3);
      } else {
        if (passwordNewController.text == passwordConfirmController.text) {
          AuthService().login(widget.itemUser?.userUsername ?? '', passwordOldController.text).then((value) async {
            if (value.statusCode == 200) {
              UserModel model = widget.itemUser ?? UserModel();
              model.userPassword = passwordNewController.text;
              UsersService().update(model).then((value) {
                Toasts.toastSuccess(context, Constants.editSuccess, 1);
                Navigator.pop(context);
              }).catchError((ex) {
                Toasts.toastError(context, Constants.error, 2);
              });
            } else {
              Toasts.toastWarning(context, 'รหัสผ่านเดิมไม่ถูกต้อง', 2);
            }
          }).catchError((ex) {
            Toasts.toastError(context, Constants.error, 1);
          });
        } else {
          Toasts.toastWarning(context, Constants.passwordNotMatch, 1);
        }
      }
    });
  }
}
