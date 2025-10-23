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

    // === Fetch data utama (kehadiran) ===
    final kehadiranUrl = Uri.parse(
        '$baseUrl/kehadiran?userPkl=$userEmail&start_date=$start&end_date=$end');
    final izinUrl = Uri.parse('$baseUrl/getIzin?userPkl=$userEmail');
    final sakitUrl = Uri.parse('$baseUrl/getSakit?userPkl=$userEmail');

    final responses = await Future.wait([
      http.get(kehadiranUrl, headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      }),
      http.get(izinUrl),
      http.get(sakitUrl),
    ]);

    final kehadiranRes = responses[0];
    final izinRes = responses[1];
    final sakitRes = responses[2];

    if (kehadiranRes.statusCode != 200) {
      throw Exception("Gagal memuat data kehadiran");
    }

    final kehadiranData = jsonDecode(kehadiranRes.body);
    final izinData = jsonDecode(izinRes.body);
    final sakitData = jsonDecode(sakitRes.body);

    final List<dynamic> kehadiranList = kehadiranData['data'] ?? [];
    final List<dynamic> izinList = izinData['data'] ?? [];
    final List<dynamic> sakitList = sakitData['data'] ?? [];

    DateTime? minDate;
    DateTime? maxDate;

    List<HistoryAbsen> historyList = kehadiranList.map<HistoryAbsen>((item) {
      DateTime? parsedDate;
      try {
        parsedDate = DateTime.parse(item['date']);
      } catch (_) {
        parsedDate = null;
      }

      if (parsedDate != null) {
        if (minDate == null || parsedDate.isBefore(minDate!)) minDate = parsedDate;
        if (maxDate == null || parsedDate.isAfter(maxDate!)) maxDate = parsedDate;
      }

      String status = item['status'] ?? '-';
      String keterangan = status;

      // 🔹 Jika status izin → ambil dari API getIzin
      if (status.toLowerCase() == 'izin') {
        final match = izinList.firstWhere(
          (i) =>
              i['tanggal_mulai'] != null &&
              DateTime.tryParse(i['tanggal_mulai'])?.day == parsedDate?.day,
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          keterangan = match['keterangan'] ?? 'Izin';
        }
      }

      // 🔹 Jika status sakit → ambil dari API getSakit
      if (status.toLowerCase() == 'sakit') {
        final match = sakitList.firstWhere(
          (s) =>
              s['tanggal_mulai'] != null &&
              DateTime.tryParse(s['tanggal_mulai'])?.day == parsedDate?.day,
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          keterangan = match['keterangan'] ?? 'Sakit';
        }
      }

      return HistoryAbsen(
        tanggal: item['date'] ?? '-',
        keterangan: keterangan,
        masuk: item['check_in'] ?? '-',
        keluar: item['check_out'] ?? '-',
        status: status,
        startDate: parsedDate ?? DateTime.now(),
        endDate: parsedDate ?? DateTime.now(),
      );
    }).toList();

    // Hitung jumlah
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
