import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/models/profile_model.dart';
import 'package:absensi_pkl_urban/models/kehadiran_model.dart';
import 'package:absensi_pkl_urban/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTab = 0;
  final ApiService apiService = ApiService();

  Future<ProfileModel>? futureProfile;
  Future<List<KehadiranModel>>? futureKehadiran;
  String? userEmail;
  bool isLoading = true; // <-- tambahin ini

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
        futureKehadiran = apiService.fetchKehadiran(userEmail!);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
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
              // 🔷 HEADER PROFIL
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF5BA3E7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Tombol Refresh
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                            onPressed: () {
                              if (userEmail != null) {
                                setState(() {
                                  futureProfile = apiService.fetchProfile(userEmail!);
                                  futureKehadiran = apiService.fetchKehadiran(userEmail!);
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Email user tidak ditemukan")),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // 🔹 Profil Siswa
                    FutureBuilder<ProfileModel>(
                      future: futureProfile,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white));
                        } else if (!snapshot.hasData) {
                          return const Text('Tidak ada data',
                              style: TextStyle(color: Colors.white));
                        }

                        final data = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person,
                                    size: 70, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                data.namaSiswa,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.namaJurusan,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.namaSekolah,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
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

              // 🔶 KONTEN UTAMA
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 📊 Statistik Kehadiran
                    Container(
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
                      child: FutureBuilder<List<KehadiranModel>>(
                        future: futureKehadiran,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('Tidak ada data kehadiran');
                          }

                          final data = snapshot.data!;
                          final tepatWaktu = data.where((e) => e.status == 'Tepat Waktu').length;
                          final terlambat = data.where((e) => e.status == 'Terlambat').length;
                          final izin = data.where((e) => e.status == 'Izin').length;
                          final sakit = data.where((e) => e.status == 'Sakit').length;

                          return Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.show_chart, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Statistik Bulan Ini',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Oktober 2025',
                                    style: TextStyle(
                                      fontSize: 13,
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
                                      '$tepatWaktu',
                                      'Tepat Waktu',
                                      const Color(0xFFD4F4DD),
                                      const Color(0xFF5FAF5C),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _buildStatCard(
                                      '$terlambat',
                                      'Terlambat',
                                      const Color(0xFFFFDADA),
                                      const Color(0xFFAF5C5C),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      '$izin',
                                      'Izin',
                                      const Color(0xFFFFF4D4),
                                      const Color(0xFFAF9A5C),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _buildStatCard(
                                      '$sakit',
                                      'Sakit',
                                      const Color(0xFFFFDCC4),
                                      const Color(0xFFAF7A5C),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 📘 TAB INFORMASI & DETAIL
                    Container(
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
                          // Tabs
                          Row(
                            children: [
                              _buildTabButton('Informasi', 0),
                              _buildTabButton('Detail', 1),
                            ],
                          ),

                          // Konten Tab
                          FutureBuilder<ProfileModel>(
                            future: futureProfile,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
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
                                  ? _buildInformasiTab(data)
                                  : _buildDetailTab(data);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Tab Button
  Widget _buildTabButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _selectedTab == index
                    ? const Color(0xFF5BA3E7)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _selectedTab == index
                  ? const Color(0xFF5BA3E7)
                  : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Tab Informasi
  Widget _buildInformasiTab(ProfileModel data) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow(Icons.badge, 'Nomor Siswa (NSM)', data.nsm),
          const SizedBox(height: 18),
          _buildInfoRow(Icons.school, 'Sekolah', data.namaSekolah),
          const SizedBox(height: 18),
          _buildInfoRow(Icons.computer, 'Jurusan', data.namaJurusan),
        ],
      ),
    );
  }

  // 🔹 Tab Detail
  Widget _buildDetailTab(ProfileModel data) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        _buildInfoRow(Icons.person, 'Email', userEmail ?? '-'),
        const SizedBox(height: 18),
        _buildInfoRow(Icons.apartment, 'Instansi', 'Urban Access'),
        const SizedBox(height: 18),
        _buildInfoRow(Icons.location_on, 'Lokasi', 'Bandung'),
      ],
    ),
  );
}

  // 🔹 Widget Reusable Info Row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 30, color: Colors.black87),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 Card Statistik
  Widget _buildStatCard(String value, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}