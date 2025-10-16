import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/absensipage.dart'; // pastikan path sesuai

class AbsensiService {
  Future<List<AbsensiModel>> getAbsensiList(String userPkl) async {
    final url = Uri.parse('https://hr.urbanaccess.net/api/kehadiran?userPkl=$userPkl');
    final response = await http.get(url);

    print('Response body: ${response.body}'); // debug

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data'];
      return data.map((e) => AbsensiModel.fromJson(e)).toList();

    } else {
      throw Exception('Gagal memuat data absensi (${response.statusCode})');
    }  
  }
  

}
