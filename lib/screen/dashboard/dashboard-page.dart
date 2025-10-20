import 'package:absensi_pkl_urban/screen/dashboard/absen-face.dart';
import 'package:absensi_pkl_urban/screen/login/landing-page.dart';
import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-izin.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-sakit.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:absensi_pkl_urban/screen/dashboard/absen-finger.dart';
import 'package:absensi_pkl_urban/services/api_service.dart';
import 'package:absensi_pkl_urban/models/dashboard_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

Future<String?> _getUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('nama') ?? 'User';
}

class DashboardPageState extends State<DashboardPage> {
  final ApiService apiService = ApiService();
  Future<DashboardData>? futureDashboard;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchData(); // 🟢 otomatis ambil data user login
  }

  // 🟢 Fungsi ambil email dari local storage dan load data dashboard
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

  // 🟢 Fungsi refresh dashboard (bukan hardcode)
  Future<void> refreshDashboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('email');

    if (userEmail == null || userEmail.isEmpty) {
      print("⚠️ Tidak ada email di cache, tidak bisa refresh");
      return;
    }

    print("🔁 Refresh dashboard untuk $userEmail");
    setState(() {
      futureDashboard = apiService.fetchDashboardData(userEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: (futureDashboard == null)
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<DashboardData>(
              future: futureDashboard,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Gagal memuat data: ${snapshot.error}"));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text("Tidak ada data"));
                }

                final data = snapshot.data!;
                return _buildDashboardContent(context, data);
              },
            ),
    );
  }
          Future<void> _checkLocationAndNavigate() async {
  try {
    print("🧭 Tombol Fingerprint ditekan");

    // Pastikan service lokasi aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Layanan lokasi tidak aktif")),
      );
      return;
    }

    // Cek & minta izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin lokasi ditolak")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin lokasi ditolak permanen, buka pengaturan untuk mengaktifkan.")),
      );
      return;
    }

    // Ambil posisi user
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Koordinat lokasi kantor (contoh)
    const double officeLatitude = -6.947776152570353;
    const double officeLongitude = 107.62715926653917;

    // Hitung jarak dari posisi user ke kantor
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      officeLatitude,
      officeLongitude,
    );

    print("📍 Lokasi user: ${position.latitude}, ${position.longitude}");
    print("📏 Jarak ke kantor: ${distance.toStringAsFixed(2)} meter");

    // Jika jarak di bawah 100 meter, boleh lanjut
    if (distance <= 20) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AbsenFinger()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Anda berada di luar area absensi (${distance.toStringAsFixed(1)} m)")),
      );
    }
  } catch (e) {
    print("❌ Error lokasi: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan: $e")),
    );
  }
}
Future<void> _checkLocationAndOpenCamera() async {
  try {
    // Pastikan service lokasi aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Layanan lokasi tidak aktif")),
      );
      return;
    }

    // Cek izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Izin lokasi ditolak")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin lokasi ditolak permanen")),
      );
      return;
    }

    // Ambil posisi user
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    const double officeLatitude = -6.947776152570353;
    const double officeLongitude = 107.62715926653917;

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      officeLatitude,
      officeLongitude,
    );

    if (distance <= 100) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AbsenFace()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Anda berada di luar area absensi (${distance.toStringAsFixed(1)} m)")),
      );
    }
  } catch (e) {
    print("❌ Error lokasi: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan: $e")),
    );
  }
}



  Widget _buildDashboardContent(BuildContext context, DashboardData data) {
    // 🟢 tampilkan semua data (bukan cuma 3)
    final recentHistory = (data.history
    .where((h) {
      final tanggal = DateTime.tryParse(h.tanggal);
      if (tanggal == null) return false;
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      return tanggal.isAfter(threeDaysAgo) && tanggal.isBefore(now.add(const Duration(days: 1)));
    })
    .toList()
      ..sort((a, b) => DateTime.parse(b.tanggal).compareTo(DateTime.parse(a.tanggal))))
  .take(3)
  .toList();

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
              // === Bar Atas ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Logout & Refresh
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LandingPage()),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: refreshDashboard, // 🟢 pakai fungsi baru
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),

                  // Nama & Profil
                  Row(
                    children: [
                      FutureBuilder<String?>(
                        future: _getUserName(),
                        builder: (context, snapshot) {
                          String namaUser = snapshot.data ?? 'User';
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
                                builder: (context) =>
                                    const MainPage(initialIndex: 2)),
                          );
                        },
                        child: const Icon(Icons.account_circle,
                            color: Colors.white),
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
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat("d MMMM yyyy", "id_ID").format(DateTime.now()),
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 14),
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
                        child: _buildStatCard(
                            "${data.hadir}",
                            'Hadir Tepat Waktu',
                            Icons.check_circle,
                            const Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                            "${data.terlambat}",
                            'Terlambat',
                            Icons.cancel,
                            const Color(0xFFE57373)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard("${data.izin}", 'Izin',
                            Icons.error, const Color(0xFFFFD54F)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard("${data.sakit}", 'Sakit',
                            Icons.medical_services,
                            const Color(0xFFFF8A65)),
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
                        child:_buildMethodCard('Finger Print', Icons.fingerprint, _checkLocationAndNavigate),

                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildMethodCard('Face ID', Icons.face, _checkLocationAndOpenCamera),
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
                                builder: (context) => const FormIzin()),
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
                                builder: (context) => const FormSakit()),
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
                            color: Colors.black87),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MainPage(initialIndex: 0)),
                          );
                        },
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                              color: Color(0xFF29B6F6),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // === Tampilkan semua data dari API ===
                  for (var history in recentHistory)
                    _buildHistoryCard(
                        history.tanggal,
                        history.keterangan,
                        history.masuk,
                        history.keluar,
                        history.status),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==== COMPONENTS ====

  Widget _buildStatCard(
      String count, String label, IconData icon, Color color) {
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
                Text(count,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20))
              ],
            ),
            const SizedBox(height: 8),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54))),
          ],
        ),
      ),
    );
  }

  // Added method card for choosing absen method (Finger / Face)
  Widget _buildMethodCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF29B6F6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF29B6F6), size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // Added action button used for Izin / Sakit
  Widget _buildActionButton(String title, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(String date, String description, String masuk,
      String keluar, String status) {
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
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2))
            ]),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: cardColor, size: 24)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatTanggal(date),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text("Keterangan : $description",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: Text("Masuk: $masuk",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black45))),
                    Expanded(
                        child: Text("Keluar: $keluar",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.black45))),
                  ])
                ]),
          ),
          const SizedBox(width: 10),
          Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(status,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cardColor)))
        ]),
      ),
    );
  }
}
