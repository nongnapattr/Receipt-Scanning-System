import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:receipt_scanning_system_flutter/models/user.model.dart';
import 'package:receipt_scanning_system_flutter/screens/launcher_screen.dart';
import 'package:receipt_scanning_system_flutter/services/auth.service.dart';
import 'package:receipt_scanning_system_flutter/services/users.service.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_button.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_spacer.dart';
import 'package:receipt_scanning_system_flutter/utilities/constants.dart';
import 'package:receipt_scanning_system_flutter/utilities/toasts.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int indexScreen = 1;

  bool isShowPassword = false;
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    checkAuth();
    super.initState();
  }

  void checkAuth() async {
    if (await AuthService().getRemember() != null && await AuthService().getToken() != null) {
      AuthService().getProfile().then((value) {
        if (value.userId != null) {
          Get.off(const LauncherScreen());
        } else {
          AuthService().removeToken();
          Toasts.toastWarning(context, 'Token Expire', 1);
        }
      });
    }
  }

  void setIndexScreen(int index) {
    setState(() {
      indexScreen = index;
      isShowPassword = false;
      username.text = '';
      password.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: indexScreen == 1
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              leading: GestureDetector(
                child: const Icon(Icons.close),
                onTap: () {
                  setState(() {
                    indexScreen = 1;
                  });
                },
              ),
            ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: 100.w,
          height: 100.h,
          padding: AppSpacer.padAll16,
          alignment: Alignment.bottomCenter,
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/bg-login.png'), fit: BoxFit.cover),
          ),
          child: indexScreen == 1
              ? buildHome()
              : indexScreen == 2
                  ? buildRegister()
                  : buildLogin(),
        ),
      ),
    );
  }

  Widget buildHome() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton.buttonPrimaryWithIcon(
            text: 'เข้าสู่ระบบ',
            onPress: () {
              setIndexScreen(3);
            }),
        SizedBox(height: AppSpacer.gap16),
        AppButton.buttonSecondaryWithIcon(
            text: 'ลงทะเบียน',
            onPress: () {
              setIndexScreen(2);
            }),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget buildLogin() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เข้าสู่ระบบ',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          controller: username,
          decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้งาน'),
          autofillHints: const [AutofillHints.username, AutofillHints.email],
        ),
        TextField(
          controller: password,
          obscureText: !isShowPassword,
          decoration: InputDecoration(
            labelText: 'รหัสผ่าน',
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
        SizedBox(height: AppSpacer.gap24),
        AppButton.buttonPrimaryWithIcon(
            text: 'ตกลง',
            onPress: () {
              onLogin();
            }),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget buildRegister() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ลงทะเบียน',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          controller: username,
          decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้งาน'),
          autofillHints: const [AutofillHints.username, AutofillHints.email],
        ),
        TextField(
          controller: password,
          obscureText: !isShowPassword,
          decoration: InputDecoration(
            labelText: 'รหัสผ่าน',
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
        SizedBox(height: AppSpacer.gap24),
        AppButton.buttonPrimaryWithIcon(
            text: 'ตกลง',
            onPress: () {
              onRegister();
            }),
        SizedBox(height: 10.h),
      ],
    );
  }

  onLogin() {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (username.text == '' || password.text == '') {
        Toasts.toastWarning(context, Constants.notFillForm, 3);
      } else {
        AuthService().login(username.text, password.text).then((value) async {
          dynamic responseData = convert.jsonDecode(value.body);
          if (value.statusCode == 200) {
            AuthService().setRemember('true');
            AuthService().setToken(responseData['access_token']);
            Toasts.toastSuccess(context, 'เข้าสู่ระบบสำเร็จ', 1);
            Get.off(const LauncherScreen());
          } else {
            Toasts.toastWarning(context, '${responseData['message']}', 2);
          }
        }).catchError((ex) {
          Toasts.toastError(context, Constants.error, 1);
        });
      }
    });
  }

  onRegister() {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (username.text == '' || password.text == '') {
        Toasts.toastWarning(context, Constants.notFillForm, 3);
      } else {
        UserModel user = UserModel();
        user.userUsername = username.text;
        user.userPassword = password.text;
        UsersService().create(user).then((value) {
          dynamic responseData = convert.jsonDecode(value!.body);
          if (value.statusCode == 201) {
            Toasts.toastSuccess(context, 'สมัครใช้งานสำเร็จ', 1);
            setState(() {
              indexScreen = 1;
            });
          } else {
            Toasts.toastWarning(context, '${responseData['message']}', 2);
          }
        }).catchError((ex) {
          Toasts.toastError(context, Constants.error, 1);
        });
      }
    });
  }
}