import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 🟢 [TAMBAHAN GPT]
import '../models/dashboard_model.dart';

class ApiService {
  final String baseUrl = "https://hr.urbanaccess.net/api"; // 🔁 ubah ke https (sesuai API kamu)

  Future<DashboardData> fetchDashboardData(String userEmail) async {
    try {
      // 🟢 [TAMBAHAN GPT] ambil token dari SharedPreferences (hasil login)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // API endpoint yang kamu punya
      final kehadiranUrl = Uri.parse("$baseUrl/kehadiran?userPkl=$userEmail");

      print("🔗 Fetching data dari: $kehadiranUrl");
      print("🔑 Token: ${token.isNotEmpty ? 'Ditemukan' : 'Tidak ditemukan'}");

      // 🟢 [TAMBAHAN GPT] tambahkan header Authorization jika Sanctum digunakan
      final response = await http.get(
        kehadiranUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token', // 🟢
        },
      );

      print("📥 RESPONSE STATUS: ${response.statusCode}");
      print("📦 RESPONSE BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Gagal memuat data kehadiran (${response.statusCode})");
      }

      final jsonData = jsonDecode(response.body);
      final List<dynamic> kehadiranList = jsonData['data'] ?? [];

      // Konversi ke model HistoryAbsen
      final List<HistoryAbsen> historyList = kehadiranList.map((item) {
        return HistoryAbsen(
          tanggal: item['date'] ?? '-',
          keterangan: item['status'] ?? '-',
          masuk: item['check_in'] ?? '-',
          keluar: item['check_out'] ?? '-',
          status: item['status'] ?? '-',
        );
      }).toList();

      // Hitung jumlah hadir & terlambat (bisa disesuaikan)
      int hadir = historyList.where((h) => h.status == "Tepat Waktu").length;
      int terlambat = historyList.where((h) => h.status == "Terlambat").length;

      return DashboardData(
        hadir: hadir,
        terlambat: terlambat,
        izin: 0, // nanti bisa diambil dari API izin
        sakit: 0, // nanti bisa diambil dari API sakit
        history: historyList,
      );
    } catch (e) {
      throw Exception("Gagal memuat data dashboard: $e");
    }
  }
}
