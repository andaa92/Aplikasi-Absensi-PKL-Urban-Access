import 'package:absensi_pkl_urban/screen/login/landing-page.dart';
import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-izin.dart';
import 'package:absensi_pkl_urban/screen/dashboard/fake_location_dialog.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-sakit.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:absensi_pkl_urban/services/api_service.dart';
import 'package:absensi_pkl_urban/models/dashboard_model.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ntp/ntp.dart';


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

  Future<bool> checkFakeLocation(BuildContext context) async {
  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (position.isMocked) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const FakeLocationDialog(); // gunakan ini
        },
      );
      return true;
    }
    return false;
  } catch (e) {
    debugPrint('❌ Error saat deteksi lokasi palsu: $e');
    return false;
  }
}





 Future<void> _absenManual() async {
  try {
    // 🛑 Cek fake GPS sebelum lanjut
    bool isFake = await checkFakeLocation(context);
    if (isFake) return;

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

    // ✅ Ambil posisi setelah lolos pengecekan
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    const double officeLatitude = -6.947716562093121;
    const double officeLongitude = 107.6271448595231;

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

      final response = await apiService.absenMasukSiswa(userEmail);

      if (response['statusCode'] == 200) {
       showSuccessPopup(context, response['msg']);
        await refreshDashboard();
      } else {
        showErrorPopup(context, response['msg'] ?? 'Gagal absen pulang');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Anda di luar area absensi (${distance.toStringAsFixed(1)} m)")),
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
    // 🛑 Cek fake GPS sebelum lanjut
    bool isFake = await checkFakeLocation(context);
    if (isFake) return;

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

    const double officeLatitude = -6.947716562093121;
    const double officeLongitude = 107.6271448595231;

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
       showSuccessPopup(context, response['msg']);
      

        await refreshDashboard();
      } else {
        showErrorPopup(context, response['msg'] ?? 'Gagal absen pulang');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Anda di luar area absensi (${distance.toStringAsFixed(1)} m)")),
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
Duration _remainingTime = Duration.zero;
double _progress = 1.0;
Color _timerColor = Colors.green; // Warna awal: hijau

void startWorkTimer() async {
  const startHour = 8;
  const endHour = 17;

  DateTime ntpTime;
  try {
    ntpTime = await NTP.now();
  } catch (e) {
    ntpTime = DateTime.now(); // fallback kalau gagal
  }

  DateTime localTime = DateTime.now();
  Duration offset = ntpTime.difference(localTime);

  final startTime = DateTime(ntpTime.year, ntpTime.month, ntpTime.day, startHour);
  final endTime = DateTime(ntpTime.year, ntpTime.month, ntpTime.day, endHour);
  final totalDuration = endTime.difference(startTime).inSeconds;

  _timer?.cancel(); // hentikan timer lama sebelum buat baru

  // 🔹 Update awal sekali
  if (!mounted) return;
  setState(() {
    DateTime current = DateTime.now().add(offset);
    final remainingSeconds = endTime.difference(current).inSeconds;
    _remainingTime = Duration(seconds: remainingSeconds.clamp(0, totalDuration));
    _progress = remainingSeconds > 0 ? remainingSeconds / totalDuration : 0;
    _timerColor = remainingSeconds > 4 * 3600
        ? Colors.green
        : remainingSeconds > 2 * 3600
            ? Colors.yellow
            : Colors.red;
  });

  // 🔁 Timer setiap detik
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (!mounted) return; // Cegah update kalau widget sudah dispose

    DateTime current = DateTime.now().add(offset);

    if (current.isBefore(startTime)) {
      setState(() {
        _remainingTime = endTime.difference(startTime);
        _progress = 1.0;
        _timerColor = Colors.grey;
      });
      return;
    }

    if (current.isAfter(endTime)) {
      timer.cancel();
      setState(() {
        _remainingTime = Duration.zero;
        _progress = 0.0;
        _timerColor = Colors.red;
      });
      return;
    }

    final remainingSeconds = endTime.difference(current).inSeconds;
    final progress = remainingSeconds / totalDuration;

    Color color;
    if (remainingSeconds > 4 * 3600) {
      color = Colors.green;
    } else if (remainingSeconds > 2 * 3600) {
      color = Colors.yellow;
    } else {
      color = Colors.red;
    }

    setState(() {
      _remainingTime = Duration(seconds: remainingSeconds);
      _progress = progress;
      _timerColor = color;
    });
  });
}






// 🧹 Tambahkan ini di dalam State class (bukan di luar)
@override
void dispose() {
  _timer?.cancel(); // pastikan timer berhenti saat halaman ditutup
  _timer = null;
  super.dispose();
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
        cardColor = const Color.fromARGB(255, 255, 78, 78);
        iconData = Icons.close;
        break;
      case 'izin':
        cardColor = const Color(0xFFFFD54F);
        iconData = Icons.warning;
        break;
      case 'sakit':
        cardColor = const Color(0xFFFF8A65);
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

void showSuccessPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) => _SuccessPopup(message: message),
  );
}


class _SuccessPopup extends StatefulWidget {
  final String message;
  
  const _SuccessPopup({required this.message});

  @override
  State<_SuccessPopup> createState() => _SuccessPopupState();
}

class _SuccessPopupState extends State<_SuccessPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _rippleController;
  late AnimationController _fadeController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controller untuk scale popup
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Controller untuk checkmark
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Controller untuk ripple effect
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Controller untuk fade out
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      ),
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    // Sequence animasi
    _scaleController.forward();
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _checkController.forward();
        _rippleController.forward();
      }
    });

    // Auto close setelah 1.5 detik
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (mounted) {
        await _fadeController.reverse(from: 1.0);
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _rippleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF29B6F6).withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Success dengan animasi dan ripple effect
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ripple effect luar (besar)
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 100 + (_rippleAnimation.value * 60),
                          height: 100 + (_rippleAnimation.value * 60),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(
                              0.2 * (1 - _rippleAnimation.value),
                            ),
                          ),
                        );
                      },
                    ),
                    // Ripple effect tengah
                    AnimatedBuilder(
                      animation: _rippleAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 100 + (_rippleAnimation.value * 40),
                          height: 100 + (_rippleAnimation.value * 40),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(
                              0.3 * (1 - _rippleAnimation.value),
                            ),
                          ),
                        );
                      },
                    ),
                    // Circle background putih
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    // Animated checkmark
                    AnimatedBuilder(
                      animation: _checkAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _checkAnimation.value,
                          child: Transform.rotate(
                            angle: (1 - _checkAnimation.value) * 0.5,
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 70,
                              color: const Color(0xFF29B6F6),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                
                // Text sukses
                Text(
                  'Berhasil!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


void showErrorPopup(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) => _ErrorPopup(message: message),
  );
}


class _ErrorPopup extends StatefulWidget {
  final String message;
  
  const _ErrorPopup({required this.message});

  @override
  State<_ErrorPopup> createState() => _ErrorPopupState();
}

class _ErrorPopupState extends State<_ErrorPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _iconController;
  late AnimationController _rippleController;
  late AnimationController _fadeController;
  late AnimationController _shakeController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _iconAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controller untuk scale popup
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Controller untuk icon X
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Controller untuk ripple effect
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Controller untuk fade out
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Controller untuk shake effect
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeOut,
      ),
    );

    _iconAnimation = CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticInOut,
      ),
    );

    // Sequence animasi
    _scaleController.forward();
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _iconController.forward();
        _rippleController.forward();
        _shakeController.forward();
      }
    });

    // Auto close setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (mounted) {
        await _fadeController.reverse(from: 1.0);
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _iconController.dispose();
    _rippleController.dispose();
    _fadeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              // Shake effect
              double shake = 0;
              if (_shakeAnimation.value < 0.5) {
                shake = _shakeAnimation.value * 20 - 5;
              } else {
                shake = (1 - _shakeAnimation.value) * 20 - 5;
              }
              
              return Transform.translate(
                offset: Offset(shake * 0.3, 0),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE53935).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Error dengan animasi dan ripple effect
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple effect luar (besar)
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 100 + (_rippleAnimation.value * 60),
                            height: 100 + (_rippleAnimation.value * 60),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(
                                0.2 * (1 - _rippleAnimation.value),
                              ),
                            ),
                          );
                        },
                      ),
                      // Ripple effect tengah
                      AnimatedBuilder(
                        animation: _rippleAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 100 + (_rippleAnimation.value * 40),
                            height: 100 + (_rippleAnimation.value * 40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(
                                0.3 * (1 - _rippleAnimation.value),
                              ),
                            ),
                          );
                        },
                      ),
                      // Circle background putih
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      // Animated X icon
                      AnimatedBuilder(
                        animation: _iconAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _iconAnimation.value,
                            child: Transform.rotate(
                              angle: (1 - _iconAnimation.value) * 0.5,
                              child: Icon(
                                Icons.cancel_rounded,
                                size: 70,
                                color: const Color(0xFFE53935),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  
                  // Text gagal
                  Text(
                    'Gagal!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Message
                  Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}