import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
import '../models/kehadiran_model.dart';

class ApiService {
  static const String baseUrl = 'https://hr.urbanaccess.net/api';

  Future<ProfileModel> fetchProfile(String userPkl) async {
    final response = await http.get(Uri.parse('$baseUrl/profile-siswa?userPkl=$userPkl'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProfileModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat data profil');
    }
  }

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
}
