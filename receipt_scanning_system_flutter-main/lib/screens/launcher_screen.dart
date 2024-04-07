import 'package:flutter/material.dart';
import 'package:receipt_scanning_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:receipt_scanning_system_flutter/screens/my_list_screen.dart';
import 'package:receipt_scanning_system_flutter/screens/profile_screen.dart';
import 'package:receipt_scanning_system_flutter/screens/report_screen.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_color.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_constant.dart';
import 'package:receipt_scanning_system_flutter/utilities/app_spacer.dart';
import 'package:receipt_scanning_system_flutter/widgets/appbar.dart';
import 'package:sizer/sizer.dart';

class LauncherScreen extends StatefulWidget {
  const LauncherScreen({super.key});

  @override
  State<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  late PageController pageController;
  int pageIndex = 0;

  List<Widget> menuScreens = <Widget>[
    const DashboardScreen(),
    const MyListScreen(),
    const ReportScreen(),
    const ProfileScreen(),
  ];

  List<BottomNavigationBarItem> menuItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Column(
        children: [
          Image.asset('assets/menu1.png', width: 24, height: 24),
          const Text(
            'ภาพรวม',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      label: 'ภาพรวม',
    ),
    BottomNavigationBarItem(
      icon: Column(
        children: [
          Image.asset('assets/menu2.png', width: 24, height: 24),
          const Text(
            'รายการ',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      label: 'รายการ',
    ),
    BottomNavigationBarItem(
      icon: Column(
        children: [
          Image.asset('assets/menu3.png', width: 24, height: 24),
          const Text(
            'สรุปรายการ',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      label: 'สรุปรายการ',
    ),
    BottomNavigationBarItem(
      icon: Column(
        children: [
          Image.asset('assets/menu4.png', width: 20, height: 20),
          const Text(
            'เมนู',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      label: 'เมนู',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadProvider();
  }

  loadProvider() {
    pageController = PageController(initialPage: 0);
  }

  onPageChange(int index) {
    setState(() {
      pageIndex = index;
    });
    pageController.jumpToPage(index);
  }

  onItemTapped(int index) {
    setState(() {
      pageIndex = index;
    });
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context, menuItems[pageIndex].label ?? '', false),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: AppSpacer.padAll16,
          child: PageView(
            controller: pageController,
            onPageChanged: onPageChange,
            children: menuScreens,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 10.h,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: AppConstant.radiusPrimary,
            topRight: AppConstant.radiusPrimary,
          ),
          child: BottomNavigationBar(
            selectedFontSize: 0, //จำเป็นมากต้องใส่ ไม่งั้นมันจะลอย !!
            currentIndex: 0,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            enableFeedback: false,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (index) => onItemTapped(index),
            items: menuItems,
            backgroundColor: AppColor.primary,
          ),
        ),
      ),
    );
  }
}
