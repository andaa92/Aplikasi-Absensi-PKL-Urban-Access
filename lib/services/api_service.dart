import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_model.dart';

class ApiService {
  final String baseUrl = "https://hr.urbanaccess.net/api";

  Future<DashboardData> fetchDashboardData(String userPkl) async {
    try {
      // 🔧 Coba pakai parameter sesuai kebutuhan server kamu
      final url = Uri.parse("$baseUrl/kehadiran?userPkl=$userPkl");
      // Jika masih error, ganti jadi:
      // final url = Uri.parse("$baseUrl/kehadiran?email=$userPkl");

      final headers = {
        'Accept': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Gagal memuat data: ${response.statusCode}");
      }

      final jsonData = jsonDecode(response.body);

      if (jsonData['data'] == null || jsonData['data'] is! List) {
        throw Exception("Format data tidak sesuai");
      }

      List<dynamic> kehadiranList = jsonData['data'];
      List<dynamic> dataUser = kehadiranList;

      int tepatWaktu = dataUser
          .where((d) =>
              (d['status']?.toString().toLowerCase() ?? '') ==
              'tepat waktu')
          .length;

      int terlambat = dataUser
          .where((d) =>
              (d['status']?.toString().toLowerCase() ?? '') ==
              'terlambat')
          .length;

      int izin = dataUser
          .where((d) =>
              (d['status']?.toString().toLowerCase() ?? '') == 'izin')
          .length;

      int sakit = dataUser
          .where((d) =>
              (d['status']?.toString().toLowerCase() ?? '') == 'sakit')
          .length;

      List<HistoryAbsen> historyList = dataUser.map((item) {
        return HistoryAbsen(
          tanggal: item['date'] ?? '-',
          keterangan: item['status'] ?? '-',
          masuk: item['check_in'] ?? '-',
          keluar: item['check_out'] ?? '-',
          status: item['status'] ?? '-',
        );
      }).toList();

      historyList.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      return DashboardData(
        hadir: tepatWaktu,
        terlambat: terlambat,
        izin: izin,
        sakit: sakit,
        history: historyList,
      );
    } catch (e) {
      throw Exception("Gagal memuat data dashboard: $e");
    }
  }
}
