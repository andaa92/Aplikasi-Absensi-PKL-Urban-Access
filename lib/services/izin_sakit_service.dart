import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IzinSakitService {
  final String baseUrl = "https://hr.urbanaccess.net/api";

  // 🟢 Ambil userPkl dari local storage
  Future<String?> _getUserPkl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userPkl');
  }

  // 🟢 Simpan Izin
  Future<Map<String, dynamic>> simpanIzin({
    required String tanggalIzin,
    required String keterangan,
  }) async {
    final userPkl = await _getUserPkl();

    if (userPkl == null) {
      throw Exception("User belum login atau userPkl tidak ditemukan");
    }

    final url = Uri.parse("$baseUrl/simpanIzin");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userPkl': userPkl,
        'tanggal_izin': tanggalIzin,
        'keterangan': keterangan,
      }),
    );

    return jsonDecode(response.body);
  }

  // 🟢 Simpan Sakit
  Future<Map<String, dynamic>> simpanSakit({
    required String tanggalMulai,
    required String tanggalAkhir,
    required String keterangan,
  }) async {
    final userPkl = await _getUserPkl();

    if (userPkl == null) {
      throw Exception("User belum login atau userPkl tidak ditemukan");
    }

    final url = Uri.parse("$baseUrl/simpanSakit");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userPkl': userPkl,
        'tanggal_mulai': tanggalMulai,
        'tanggal_akhir': tanggalAkhir,
        'keterangan': keterangan,
      }),
    );

    return jsonDecode(response.body);
  }

  // 🟢 Ambil data izin user
  Future<List<dynamic>> getIzin() async {
    final userPkl = await _getUserPkl();
    if (userPkl == null) throw Exception("User belum login");

    final url = Uri.parse("$baseUrl/getIzin?userPkl=$userPkl");
    final response = await http.get(url);

    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  // 🟢 Ambil data sakit user
  Future<List<dynamic>> getSakit() async {
    final userPkl = await _getUserPkl();
    if (userPkl == null) throw Exception("User belum login");

    final url = Uri.parse("$baseUrl/getSakit?userPkl=$userPkl");
    final response = await http.get(url);

    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }
}
