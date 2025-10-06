  import 'package:absensi_pkl_urban/screen/form-izin.dart';
  import 'package:flutter/material.dart';
  import 'package:absensi_pkl_urban/screen/absensi-page.dart';
  import 'package:absensi_pkl_urban/screen/dashboard-page.dart';
  import 'package:absensi_pkl_urban/screen/profile-page.dart';
  import 'package:absensi_pkl_urban/navigation/navigation-item.dart';
  import 'package:absensi_pkl_urban/screen/form-sakit.dart';

  class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({Key? key, this.initialIndex = 1}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = const [
    AbsensiPage(),
    DashboardPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
