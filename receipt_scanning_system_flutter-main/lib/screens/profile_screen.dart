import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_scanning_system_flutter/models/user.model.dart';
import 'package:receipt_scanning_system_flutter/screens/change_password_screen.dart';
import 'package:receipt_scanning_system_flutter/screens/home_screen.dart';
import 'package:receipt_scanning_system_flutter/services/auth.service.dart';
import 'package:receipt_scanning_system_flutter/services/users.service.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_button.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_spacer.dart';
import 'package:receipt_scanning_system_flutter/utilities/constants.dart';
import 'package:receipt_scanning_system_flutter/utilities/toasts.dart';
import 'package:sizer/sizer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel itemUser = UserModel();

  @override
  void initState() {
    onLoadData();
    super.initState();
  }

  onLoadData() async {
    UsersService().findOne(await AuthService().decodeUserId()).then((value) {
      setState(() {
        itemUser = value;
      });
    }).catchError((ex) {
      Toasts.toastSuccess(context, Constants.error, 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'ชื่อผู้ใช้: ${itemUser.userUsername}',
          style: const TextStyle(fontSize: 16),
        ),
        SizedBox(height: AppSpacer.gap16),
        SizedBox(
          width: 100.w,
          child: AppButton.buttonPrimary(
            text: 'เปลี่ยนรหัสผ่าน',
            onPress: () {
              Get.to(ChangePasswordScreen(itemUser: itemUser));
            },
          ),
        ),
        SizedBox(height: AppSpacer.gap16),
        SizedBox(
          width: 100.w,
          child: AppButton.buttonPrimary(
            text: 'ออกจากระบบ',
            onPress: () {
              AuthService().removeToken();
              Toasts.toastSuccess(this.context, 'ออกจากระบบสำเร็จ', 1);
              Get.off(const HomeScreen());
            },
          ),
        ),
      ],
    );
  }
}