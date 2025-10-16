import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/absensi-page.dart';
import 'package:absensi_pkl_urban/screen/dashboard.dart';
import 'package:absensi_pkl_urban/screen/profile-page.dart';
import 'package:absensi_pkl_urban/navigation/navigation-item.dart';
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadAbsensiData();
  }

  Future<void> _loadAbsensiData() async {
    try {
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

  final List<Widget> _pages = const [
    AbsensiPage(),
    Dashboard(),
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
