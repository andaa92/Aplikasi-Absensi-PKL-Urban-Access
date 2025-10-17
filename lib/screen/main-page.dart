import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/absensi-page.dart';
import 'package:absensi_pkl_urban/screen/profile-page.dart';
import 'package:absensi_pkl_urban/navigation/navigation-item.dart';
import 'package:absensi_pkl_urban/screen/dashboard/dashboard-page.dart';
import 'package:absensi_pkl_urban/services/api_absensi_services.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({super.key, this.initialIndex = 1});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;
  final _service = AbsensiService();
  List<dynamic> _absensiList = [];
  bool _isLoading = true;

  // 🟢 Tambahan: Key agar Dashboard bisa di-refresh otomatis
  final GlobalKey<DashboardPageState> _dashboardKey = GlobalKey<DashboardPageState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadAbsensiData();
  }

  Future<void> _loadAbsensiData() async {
    try {
      // 🟢 nanti kamu bisa ganti email ini dengan SharedPreferences email login juga
      final data = await _service.getAbsensiList('destia@gmail.com');
      setState(() {
        _absensiList = data;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🟢 Buat daftar halaman (Dashboard pakai UniqueKey supaya reset filter)
  late final List<Widget> _pages = [
    const AbsensiPage(),
    DashboardPage(key: _dashboardKey), // tetap pakai key
    const ProfilePage(),
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

          // 🟢 Jika pindah ke Dashboard, langsung auto refresh data user login
          if (index == 1) {
            _dashboardKey.currentState?.refreshDashboard(); // 🟢 panggil fungsi asli dari Dashboard
            developer.log("🟢 Dashboard auto refresh ketika tab aktif");
          }
        },
      ),
    );
  }
}
