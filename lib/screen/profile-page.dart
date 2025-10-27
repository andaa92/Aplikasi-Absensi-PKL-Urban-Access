import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_pkl_urban/models/profile_model.dart';
import 'package:absensi_pkl_urban/models/dashboard_model.dart';
import 'package:absensi_pkl_urban/services/api_service.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService apiService = ApiService();
  Future<ProfileModel>? futureProfile;
  Future<DashboardData>? futureDashboard;
  String? userEmail;
  bool isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');

    if (savedEmail != null) {
      setState(() {
        userEmail = savedEmail;
        futureProfile = apiService.fetchProfile(userEmail!);
        futureDashboard = apiService.fetchDashboardData(userEmail!);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final nameFont = screenWidth * 0.05;
    final jurusanFont = screenWidth * 0.038;
    final sekolahFont = screenWidth * 0.033;
    final statNumberFont = screenWidth * 0.07;
    final statLabelFont = screenWidth * 0.03;
    final tabFont = screenWidth * 0.037;
    final infoLabelFont = screenWidth * 0.032;
    final infoValueFont = screenWidth * 0.038;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userEmail == null) {
      return const Scaffold(
        body: Center(child: Text("Email user tidak ditemukan")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔹 HEADER PROFIL FIXED dengan lingkaran gelembung
          Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
                    child: Column(
                      children: [
                        // Bar Atas dengan Refresh dan Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (userEmail != null) {
                                    futureProfile = apiService.fetchProfile(
                                      userEmail!,
                                    );
                                    futureDashboard = apiService
                                        .fetchDashboardData(userEmail!);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // 🔸 Profil Data
                        FutureBuilder<ProfileModel>(
                          future: futureProfile,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(15),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white),
                              );
                            } else if (!snapshot.hasData) {
                              return const Text(
                                'Tidak ada data',
                                style: TextStyle(color: Colors.white),
                              );
                            }

                            final data = snapshot.data!;
                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  data.namaSiswa,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: nameFont,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    data.namaJurusan,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: jurusanFont,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.school_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        data.namaSekolah,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.95),
                                          fontSize: sekolahFont,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 🔹 LINGKARAN GELEMBUNG DEKORASI
              Positioned(
                top: 40,
                right: 25,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: 90,
                right: 50,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                top: 70,
                left: 30,
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                left: 60,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                top: 130,
                left: 80,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.09),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 70,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
            ],
          ),

          // 🔹 KONTEN YANG BISA DI-SCROLL
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 🔹 Statistik Bulan Ini
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: FutureBuilder<DashboardData>(
                      future: futureDashboard,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData) {
                          return const Text('Tidak ada data statistik');
                        }

                        final data = snapshot.data!;
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.show_chart, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Statistik Bulan Ini',
                                    style: TextStyle(
                                      fontSize: tabFont,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _getNamaBulan(DateTime.now().month),
                                    style: TextStyle(
                                      fontSize: infoLabelFont,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      "${data.hadir}",
                                      "Tepat Waktu",
                                      const Color(0xFFD4F4DD),
                                      const Color(0xFF4CAF50),
                                      statNumberFont,
                                      statLabelFont,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildStatCard(
                                      "${data.terlambat}",
                                      "Terlambat",
                                      const Color(0xFFFFDADA),
                                      const Color(0xFFE57373),
                                      statNumberFont,
                                      statLabelFont,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      "${data.izin}",
                                      "Izin",
                                      const Color(0xFFFFF4D4),
                                      const Color(0xFFFFD54F),
                                      statNumberFont,
                                      statLabelFont,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildStatCard(
                                      "${data.sakit}",
                                      "Sakit",
                                      const Color(0xFFFFDCC4),
                                      const Color(0xFFFF8A65),
                                      statNumberFont,
                                      statLabelFont,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // 🔹 Tab Informasi & Detail
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildTabButton('Informasi', 0, tabFont),
                              _buildTabButton('Detail', 1, tabFont),
                            ],
                          ),
                          FutureBuilder<ProfileModel>(
                            future: futureProfile,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData) {
                                return const Text('Tidak ada data');
                              }

                              final data = snapshot.data!;
                              return _selectedTab == 0
                                  ? _buildInformasiTab(
                                      data,
                                      infoLabelFont,
                                      infoValueFont,
                                    )
                                  : _buildDetailTab(infoLabelFont, infoValueFont);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Statistik Card
  Widget _buildStatCard(
    String value,
    String label,
    Color bgColor,
    Color textColor,
    double valueFont,
    double labelFont,
  ) {
    // Tentukan icon berdasarkan label
    IconData icon;
    if (label == "Tepat Waktu") {
      icon = Icons.check_circle;
    } else if (label == "Terlambat") {
      icon = Icons.cancel;
    } else if (label == "Izin") {
      icon = Icons.error;
    } else if (label == "Sakit") {
      icon = Icons.medical_services;
    } else {
      icon = Icons.info;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainPage(initialIndex: 0),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: textColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Tab Button
  Widget _buildTabButton(String title, int index, double fontSize) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    _selectedTab == index
                        ? const Color(0xFF4FC3F7)
                        : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              color:
                  _selectedTab == index
                      ? const Color(0xFF4FC3F7)
                      : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Tab Informasi
  Widget _buildInformasiTab(
    ProfileModel data,
    double labelFont,
    double valueFont,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.badge,
            'Nomor Siswa (NSM)',
            data.nsm,
            labelFont,
            valueFont,
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.school,
            'Sekolah',
            data.namaSekolah,
            labelFont,
            valueFont,
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.computer,
            'Jurusan',
            data.namaJurusan,
            labelFont,
            valueFont,
          ),
        ],
      ),
    );
  }

  // 🔹 Tab Detail
  Widget _buildDetailTab(double labelFont, double valueFont) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.email,
            'Email',
            userEmail ?? '-',
            labelFont,
            valueFont,
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.apartment,
            'Instansi',
            'Urban Access',
            labelFont,
            valueFont,
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.location_on,
            'Lokasi',
            'Bandung',
            labelFont,
            valueFont,
          ),
        ],
      ),
    );
  }

  // 🔹 Info Row
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    double labelFont,
    double valueFont,
  ) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Colors.black87),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: labelFont, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: valueFont,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 Nama Bulan Helper
  String _getNamaBulan(int bulan) {
    const namaBulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return namaBulan[bulan];
  }
}