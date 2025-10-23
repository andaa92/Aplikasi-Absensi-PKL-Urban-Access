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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 HEADER PROFIL
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF4FC3F7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 22,
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
                    ),

                    // 🔸 Profil Data
                    FutureBuilder<ProfileModel>(
                      future: futureProfile,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                data.namaSiswa,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: nameFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.namaJurusan,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: jurusanFont,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                data.namaSekolah,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: sekolahFont,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

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
                                  const Color(0xFF5FAF5C),
                                  statNumberFont,
                                  statLabelFont,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildStatCard(
                                  "${data.terlambat}",
                                  "Terlambat",
                                  const Color(0xFFFFDADA),
                                  const Color(0xFFAF5C5C),
                                  statNumberFont,
                                  statLabelFont,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  "${data.izin}",
                                  "Izin",
                                  const Color(0xFFFFF4D4),
                                  const Color(0xFFAF9A5C),
                                  statNumberFont,
                                  statLabelFont,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildStatCard(
                                  "${data.sakit}",
                                  "Sakit",
                                  const Color(0xFFFFDCC4),
                                  const Color(0xFFAF7A5C),
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
            ],
          ),
        ),
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
  return GestureDetector(
    onTap: () {
      // Navigasi ke halaman absensi di tab pertama
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(initialIndex: 0),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: valueFont,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFont,
              color: textColor,
              fontWeight: FontWeight.w500,
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
