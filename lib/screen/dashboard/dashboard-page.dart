import 'package:absensi_pkl_urban/screen/login/landing-page.dart';
import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-izin.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-sakit.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:absensi_pkl_urban/services/api_service.dart';
import 'package:absensi_pkl_urban/models/dashboard_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:percent_indicator/percent_indicator.dart';


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
    _loadUserAndFetchData();
    startWorkTimer(); // 🟢 otomatis ambil data user login + timer
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

                  // === Progress Waktu Kerja ===
                   const SizedBox(height: 10),
                  Center(
                    child: CircularPercentIndicator(
                      radius: 90.0,
                      lineWidth: 12.0,
                      percent: _progress.clamp(0.0, 1.0),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: _timerColor, // 🔥 otomatis sesuai sisa waktu
                      backgroundColor: Colors.grey.shade300,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDuration(_remainingTime),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _timerColor, // 🔥 teks waktu ikut berubah warna juga
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Sisa Waktu Kerja",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
              
                  // === Metode Absen ===
                  const Text(
                      'Silahkan Lakukan Absensi :',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 15),
                   Row(
                    children: [
                      Expanded(
                        child: _buildMethodCard('Absen Sekarang', Icons.access_time, _absenManual),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildMethodCard('Absen Pulang', Icons.logout, _absenPulang),
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
                 // === Tampilkan hanya weekday (Senin–Jumat) ===
                for (var history in recentHistory)
                  if (_isWeekday(history.tanggal))
                    _buildHistoryCard(
                      history.tanggal,
                      history.keterangan,
                      history.masuk,
                      history.keluar,
                      history.status,
                    ),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Future<void> _absenManual() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Layanan lokasi tidak aktif")),
      );
      return;
    }

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

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    const double officeLatitude = -6.931985511473663;
    const double officeLongitude = 107.5560453216009;

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      officeLatitude,
      officeLongitude,
    );

    if (distance <= 50) {
      // ✅ Ambil email user dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail == null || userEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email tidak ditemukan, silakan login ulang.")),
        );
        return;
      }

      // ✅ Kirim data ke API
      final response = await apiService.absenMasukSiswa(userEmail);

      if (response['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ ${response['msg']}")),
        );

        // Optional: refresh dashboard biar data update
        await refreshDashboard();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${response['msg'] ?? 'Gagal absen'}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Anda di luar area absensi (${distance.toStringAsFixed(1)} m)"),
        ),
      );
    }
  } catch (e) {
    print("❌ Error absen manual: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan: $e")),
    );
  }
}

Future<void> _absenPulang() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Layanan lokasi tidak aktif")),
      );
      return;
    }

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

    if (distance <= 50) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');

      if (userEmail == null || userEmail.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email tidak ditemukan, silakan login ulang.")),
        );
        return;
      }

      final response = await apiService.absenPulangSiswa(userEmail);

      if (response['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ ${response['msg']}")),
        );
        await refreshDashboard();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ ${response['msg'] ?? 'Gagal absen pulang'}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Anda di luar area absensi (${distance.toStringAsFixed(1)} m)"),
        ),
      );
    }
  } catch (e) {
    print("❌ Error absen pulang: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan: $e")),
    );
  }
}

Timer? _timer;
Duration _remainingTime = const Duration();
double _progress = 1.0;
Color _timerColor = Colors.green; // Warna awal: hijau

void startWorkTimer() {
  const startHour = 8; // 08:00
  const endHour = 17;  // 17:00
  final now = DateTime.now();
  final startTime = DateTime(now.year, now.month, now.day, startHour);
  final endTime = DateTime(now.year, now.month, now.day, endHour);
  final totalDuration = endTime.difference(startTime).inSeconds;

  _timer?.cancel();
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    final current = DateTime.now();

    if (current.isBefore(startTime)) {
      // Belum jam kerja
      setState(() {
        _remainingTime = endTime.difference(startTime);
        _progress = 1.0;
        _timerColor = Colors.grey; // Belum mulai
      });
      return;
    }

    if (current.isAfter(endTime)) {
      // Sudah lewat jam kerja
      timer.cancel();
      setState(() {
        _remainingTime = Duration.zero;
        _progress = 0.0;
        _timerColor = Colors.red; // Waktu habis
      });
      return;
    }

    // Hitung sisa waktu
    final remainingSeconds = endTime.difference(current).inSeconds;
    final progress = remainingSeconds / totalDuration;

    // Tentukan warna otomatis
    Color color;
    if (remainingSeconds > 4 * 3600) {
      color = Colors.red; // >4 jam → merah
    } else if (remainingSeconds > 2 * 3600) {
      color = Colors.yellow; // 2–4 jam → kuning
    } else {
      color = Colors.green; // <2 jam → hijau
    }

    setState(() {
      _remainingTime = Duration(seconds: remainingSeconds);
      _progress = progress;
      _timerColor = color;
    });
  });
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
  
  bool _isWeekday(String tanggal) {
  try {
    final date = DateTime.parse(tanggal);
    return date.weekday >= 1 && date.weekday <= 5; // 1=Senin, 7=Minggu
  } catch (e) {
    return true; // kalau parsing gagal, biar tidak error tampilkan saja
  }
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
String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$hours:$minutes:$seconds";
}