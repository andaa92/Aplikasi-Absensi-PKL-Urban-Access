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

  // === DASHBOARD ===
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
          '$baseUrl/kehadiran?userPkl=$userEmail&start_date=$start&end_date=$end');

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

      DateTime? minDate;
      DateTime? maxDate;

      List<HistoryAbsen> historyList = kehadiranList.map<HistoryAbsen>((item) {
        DateTime? parsedDate;
        try {
          parsedDate = DateTime.parse(item['date']); // API format: yyyy-MM-dd
        } catch (_) {
          parsedDate = null;
        }

        if (parsedDate != null) {
          if (minDate == null || parsedDate.isBefore(minDate!)) minDate = parsedDate;
          if (maxDate == null || parsedDate.isAfter(maxDate!)) maxDate = parsedDate;
        }

        return HistoryAbsen(
          tanggal: item['date'] ?? '-',
          keterangan: item['status'] ?? '-',
          masuk: item['check_in'] ?? '-',
          keluar: item['check_out'] ?? '-',
          status: item['status'] ?? '-',
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
}
