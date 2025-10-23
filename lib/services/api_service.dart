import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
import '../models/kehadiran_model.dart';
import '../models/dashboard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://hr.urbanaccess.net/api';

  // === PROFIL ===
  Future<ProfileModel> fetchProfile(String userPkl) async {
    final response = await http.get(Uri.parse('$baseUrl/profile-siswa?userPkl=$userPkl'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProfileModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat data profil');
    }
  }

  // === KEHADIRAN ===
  Future<List<KehadiranModel>> fetchKehadiran(String userPkl) async {
    final response = await http.get(Uri.parse('$baseUrl/kehadiran?userPkl=$userPkl'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['data'];
      return list.map((e) => KehadiranModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data kehadiran');
    }
  }

  // === DASHBOARD (dengan keterangan izin & sakit) ===
  Future<DashboardData> fetchDashboardData(String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1, now.day);

      String formatDate(DateTime date) {
        return "${date.day.toString().padLeft(2, '0')}-"
            "${date.month.toString().padLeft(2, '0')}-"
            "${date.year}";
      }

      final start = formatDate(lastMonth);
      final end = formatDate(now);

      final kehadiranUrl = Uri.parse(
        '$baseUrl/kehadiran?userPkl=$userEmail&start_date=$start&end_date=$end',
      );

      print("🔗 Fetching data dari: $kehadiranUrl");

      final response = await http.get(
        kehadiranUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      print("📥 RESPONSE STATUS: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception("Gagal memuat data kehadiran (${response.statusCode})");
      }

      final jsonData = jsonDecode(response.body);
      final List<dynamic> kehadiranList = jsonData['data'] ?? [];

      if (kehadiranList.isEmpty) {
        throw Exception("Tidak ada data absensi ditemukan");
      }

      // 🔹 Ambil data izin dan sakit dari API lain
      final izinMap = await fetchIzinKeterangan(userEmail);
      final sakitMap = await fetchSakitKeterangan(userEmail);

      DateTime? minDate;
      DateTime? maxDate;

      List<HistoryAbsen> historyList = kehadiranList.map<HistoryAbsen>((item) {
        final date = item['date'] ?? '-';
        final status = item['status'] ?? '-';
        final checkIn = item['check_in'] ?? '-';
        final checkOut = item['check_out'] ?? '-';

        DateTime? parsedDate;
        try {
          parsedDate = DateTime.tryParse(date);
        } catch (_) {
          parsedDate = null;
        }

        if (parsedDate != null) {
          if (minDate == null || parsedDate.isBefore(minDate!)) minDate = parsedDate;
          if (maxDate == null || parsedDate.isAfter(maxDate!)) maxDate = parsedDate;
        }

        // 🔸 Gunakan keterangan tambahan jika izin/sakit
        String keterangan = '-';
        if (status.toLowerCase() == 'izin') {
          keterangan = izinMap[date] ?? '-';
        } else if (status.toLowerCase() == 'sakit') {
          keterangan = sakitMap[date] ?? '-';
        } else {
          keterangan = status;
        }

        return HistoryAbsen(
          tanggal: date,
          keterangan: keterangan,
          masuk: checkIn,
          keluar: checkOut,
          status: status,
          startDate: parsedDate ?? DateTime.now(),
          endDate: parsedDate ?? DateTime.now(),
        );
      }).toList();

      // Hitung jumlah sesuai status
      int hadir = historyList.where((h) => h.status.toLowerCase() == "tepat waktu").length;
      int terlambat = historyList.where((h) => h.status.toLowerCase() == "terlambat").length;
      int izin = historyList.where((h) => h.status.toLowerCase() == "izin").length;
      int sakit = historyList.where((h) => h.status.toLowerCase() == "sakit").length;

      return DashboardData(
        hadir: hadir,
        terlambat: terlambat,
        izin: izin,
        sakit: sakit,
        history: historyList,
        startDate: minDate ?? now,
        endDate: maxDate ?? now,
      );
    } catch (e) {
      throw Exception("Gagal memuat data dashboard: $e");
    }
  }

  // === IZIN MAP ===
  Future<Map<String, String>> fetchIzinKeterangan(String userEmail) async {
    final response = await http.get(Uri.parse('$baseUrl/getIzin?userPkl=$userEmail'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Map<String, String> izinMap = {};

      final izinData = data['data'];
      if (izinData is List) {
        for (var item in izinData) {
          final tanggal = item['tanggal_izin'] ?? item['date'] ?? '-';
          final keterangan = item['keterangan'] ?? '-';
          izinMap[tanggal] = keterangan;
        }
      } else if (izinData is Map) {
        final tanggal = izinData['tanggal_izin'] ?? izinData['date'] ?? '-';
        final keterangan = izinData['keterangan'] ?? '-';
        izinMap[tanggal] = keterangan;
      }

      print("✅ Data izin diambil: ${izinMap.length} item");
      return izinMap;
    } else {
      print("⚠️ Gagal ambil data izin (${response.statusCode})");
      return {};
    }
  }

  // === SAKIT MAP ===
  Future<Map<String, String>> fetchSakitKeterangan(String userEmail) async {
    final response = await http.get(Uri.parse('$baseUrl/getSakit?userPkl=$userEmail'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Map<String, String> sakitMap = {};

      final sakitData = data['data'];
      if (sakitData is List) {
        for (var item in sakitData) {
          final tanggal = item['tanggal_mulai'] ?? item['date'] ?? '-';
          final keterangan = item['keterangan'] ?? '-';
          sakitMap[tanggal] = keterangan;
        }
      } else if (sakitData is Map) {
        final tanggal = sakitData['tanggal_mulai'] ?? sakitData['date'] ?? '-';
        final keterangan = sakitData['keterangan'] ?? '-';
        sakitMap[tanggal] = keterangan;
      }

      print("✅ Data sakit diambil: ${sakitMap.length} item");
      return sakitMap;
    } else {
      print("⚠️ Gagal ambil data sakit (${response.statusCode})");
      return {};
    }
  }

  // === ABSEN MASUK SISWA ===
  Future<Map<String, dynamic>> absenMasukSiswa(String userEmail) async {
    final url = Uri.parse('$baseUrl/absen-masuk-siswa');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userPkl': userEmail}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal absen: ${response.body}');
    }
  }

  // === ABSEN PULANG SISWA ===
  Future<Map<String, dynamic>> absenPulangSiswa(String userEmail) async {
    final url = Uri.parse('$baseUrl/absen-pulang-siswa');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userPkl': userEmail}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal absen pulang: ${response.body}');
    }
  }
}
