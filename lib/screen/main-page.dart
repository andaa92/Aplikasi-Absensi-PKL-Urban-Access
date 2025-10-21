import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_pkl_urban/screen/absensi-page.dart';
import 'package:absensi_pkl_urban/screen/profile-page.dart';
import 'package:absensi_pkl_urban/navigation/navigation-item.dart';
import 'package:absensi_pkl_urban/screen/dashboard/dashboard-page.dart';
import 'package:absensi_pkl_urban/services/api_service.dart';
import 'package:absensi_pkl_urban/models/absensipage.dart';
import 'package:absensi_pkl_urban/models/dashboard_model.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;
  const MainPage({super.key, this.initialIndex = 1});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _currentIndex;
  final ApiService _apiService = ApiService();
  List<AbsensiModel> _absensiList = [];
  bool _isLoading = true;
  String? _userEmail;

  final GlobalKey<DashboardPageState> _dashboardKey = GlobalKey<DashboardPageState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _initUserData();
  }

  Future<void> _initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email'); // 🔹 Ambil email login yang tersimpan

    if (email == null) {
      developer.log('⚠️ Email belum tersimpan di SharedPreferences');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _userEmail = email;
    });

    await _loadAbsensiData(email);
  }

  Future<void> _loadAbsensiData(String email) async {
    try {
      final DashboardData dashboardData =
          await _apiService.fetchDashboardData(email);

      final List<AbsensiModel> list = dashboardData.history
          .map((e) => AbsensiModel.fromJson({
                'tanggal': e.tanggal,
                'masuk': e.masuk,
                'keluar': e.keluar,
                'status': e.status,
              }))
          .toList();

      setState(() {
        _absensiList = list;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('❌ Error saat load absensi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userEmail == null) {
      return const Scaffold(
        body: Center(child: Text('Email login tidak ditemukan')),
      );
    }

    final List<Widget> _pages = [
      AbsensiPage(userEmail: _userEmail!), // ✅ email login dikirim ke AbsensiPage
      DashboardPage(key: _dashboardKey),
      const ProfilePage(),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            _dashboardKey.currentState?.refreshDashboard();
            developer.log("🟢 Dashboard auto refresh ketika tab aktif");
          }
        },
      ),
    );
  }
}
