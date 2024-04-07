import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receipt_scanning_system_flutter/screens/home_screen.dart';
import 'package:sizer/sizer.dart';

Future<void> main() async {
  initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.photos.isDenied.then((value) {
    if (value) {
      Permission.photos.request();
    }
  });
  await Permission.camera.isDenied.then((value) {
    if (value) {
      Permission.camera.request();
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      );
    });
  }
}
