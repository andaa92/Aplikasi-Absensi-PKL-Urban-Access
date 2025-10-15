import 'package:absensi_pkl_urban/navigation/navigation-item.dart';
import 'package:absensi_pkl_urban/screen/dashboard/absen-face.dart';
import 'package:absensi_pkl_urban/screen/login/landing-page.dart';
import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/absensi-page.dart';
import 'package:absensi_pkl_urban/screen/profile-page.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-izin.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-sakit.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:absensi_pkl_urban/screen/dashboard/absen-finger.dart';
import 'package:absensi_pkl_urban/services/api_service.dart';
import 'package:absensi_pkl_urban/models/dashboard_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

Future<String?> _getUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('nama') ?? 'User';
}




class _DashboardPageState extends State<DashboardPage> {
  final ApiService apiService = ApiService();
  Future<DashboardData>? futureDashboard;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchData(); // 🟢 [TAMBAHAN GPT]
  }

  // 🟢 [TAMBAHAN GPT] ambil email dari local storage (SharedPreferences)
  Future<void> _loadUserAndFetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('email');

    if (userEmail == null || userEmail.isEmpty) {
      print("⚠️ Email user tidak ditemukan, arahkan ke login");
      return;
    }

    print("📩 Mengambil data dashboard untuk $userEmail");
    setState(() {
      futureDashboard = apiService.fetchDashboardData(userEmail);
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),

    // 🟢 Tambahan keamanan untuk handle futureDashboard yang belum siap
    body: (futureDashboard == null)
        ? const Center(
            child: CircularProgressIndicator(), // loading awal
          )
        : FutureBuilder<DashboardData>(
            future: futureDashboard,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        "Gagal memuat data: ${snapshot.error.toString()}"));
              } else if (!snapshot.hasData) {
                return const Center(child: Text("Tidak ada data"));
              }

              final data = snapshot.data!;
              return _buildDashboardContent(context, data);
            },
          ),
  );
}


  Widget _buildDashboardContent(BuildContext context, DashboardData data) {
    // Ambil 3 data absen terbaru
    final recentHistory = data.history.take(3).toList();

    return Column(
      children: [
        // ==== HEADER ====
        Container(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LandingPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            futureDashboard = apiService
                                .fetchDashboardData("muhammadnadiprahmatilah@gmail.com");
                          });
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),

                  // 🟢
                  Row(
                     children: [
                  FutureBuilder<String?>(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        String namaUser = snapshot.data ?? 'User';

                        // 🟢 Tambahan: ambil hanya dua kata pertama
                        List<String> parts = namaUser.split(' ');
                        if (parts.length > 2) {
                          namaUser = '${parts[0]} ${parts[1]}';
                        }

                        return Text(
                          namaUser,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            // 🟢 biar kalau masih panjang, ada titik-titik (...)
                          ),
                        );
                      },
                    ),

                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainPage(initialIndex: 2),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),     
           ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat("d MMMM yyyy", "id_ID").format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ==== CONTENT ====
        Expanded(
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // === Stats Cards ===
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MainPage(initialIndex: 0),
                              ),
                            );
                          },
                          
                          child: _buildStatCard(
                            "${data.hadir}",
                            'Hadir Tepat Waktu',
                            Icons.check_circle,
                            const Color(0xFF4CAF50),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded (
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MainPage(initialIndex: 0),
                              ),
                            );
                          },
                          
                        
                        child: _buildStatCard(
                          "${data.terlambat}",
                          'Terlambat',
                          Icons.cancel,
                          const Color(0xFFE57373),
                        ),
                      ),
                      ),
                    ],

                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [ 
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MainPage(initialIndex: 0),
                              ),
                            );
                          },
                        
                        child: _buildStatCard(
                          "${data.izin}",
                          'Izin',
                          Icons.error,
                          const Color(0xFFFFD54F),
                        ),
                      ),
                      ),

                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MainPage(initialIndex: 0),
                              ),
                            );
                          },
                        child: _buildStatCard(
                          "${data.sakit}",
                          'Sakit',
                          Icons.medical_services,
                          const Color(0xFFFF8A65),
                        ),
                      ),
                      ),
                      
                    ],
                  ),

                  const SizedBox(height: 25),

                  // === Metode Absen ===
                  const Text(
                    'Silahkan Pilih Metode Absen :',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AbsenFinger(),
                            ),
                          ),
                          child: _buildMethodCard(
                              'Finger Print', Icons.fingerprint),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AbsenFace(),
                            ),
                          ),
                          child: _buildMethodCard('Face ID', Icons.face),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // === Tombol Izin & Sakit ===
                  const Text(
                    'Jika, Berhalangan hadir :',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Izin',
                          const Color(0xFF4FC3F7),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FormIzin(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildActionButton(
                          'Sakit',
                          const Color(0xFF4FC3F7),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FormSakit(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // === Riwayat Absen ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat Absen :',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainPage(initialIndex: 0),
                            ),
                          );
                        },
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: Color(0xFF29B6F6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  for (var history in recentHistory)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MainPage(initialIndex: 0),
                          ),
                        );
                        
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildHistoryCard(
                          history.tanggal,
                          history.keterangan,
                          history.masuk,
                          history.keluar,
                          history.status == "Tepat Waktu"
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF8A65),
                          history.status,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==== CARD WIDGETS ====
  Widget _buildStatCard(String count, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
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
                count,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4FC3F7), width: 3),
            ),
            child: Icon(icon, size: 40, color: const Color(0xFF4FC3F7)),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  // === HISTORY CARD ===
  Widget _buildHistoryCard(
    String date,
    String description,
    String masuk,
    String keluar,
    Color statusColor,
    String status,
  ) {
    String formatTanggal(String tgl) {
      try {
        final DateTime parsed = DateTime.parse(tgl);
        return DateFormat("d MMMM yyyy", "id_ID").format(parsed);
      } catch (e) {
        return tgl;
      }
    }

    Color cardColor;
    IconData iconData;

    switch (status.toLowerCase()) {
      case 'tepat waktu':
        cardColor = const Color(0xFF4CAF50);
        iconData = Icons.check_circle;
        break;
      case 'terlambat':
        cardColor = const Color(0xFFFF8A65);
        iconData = Icons.close;
        break;
      case 'izin':
        cardColor = const Color(0xFFFFD54F);
        iconData = Icons.warning;
        break;
      case 'sakit':
        cardColor = const Color(0xFF29B6F6);
        iconData = Icons.medical_services;
        break;
      default:
        cardColor = Colors.grey;
        iconData = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: cardColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTanggal(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Keterangan : $description",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Masuk: $masuk",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Keluar: $keluar",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: cardColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
