/*import '../models/absensipage.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class AbsensiService {
  final ApiService _apiService = ApiService();

  Future<List<AbsensiModel>> getAbsensiList(
    String userEmail, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 🔹 Ambil data dari dashboard (biar ga double API)
      final DashboardData dashboardData = await _apiService.fetchDashboardData(userEmail);

      // 🔹 Ambil history absensi dari dashboard
      final history = dashboardData.history;

      // 🔹 Mapping ke AbsensiModel
      List<AbsensiModel> list = history.map((e) => AbsensiModel.fromJson(e)).toList();
      // 🔹 Filter tanggal (kalau dipilih di UI)
      if (startDate != null && endDate != null) {
        list = list.where((item) {
          final date = DateTime.tryParse(item.tanggal);
          if (date == null) return false;
          return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              date.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
      }

      return list;
    } catch (e) {
      throw Exception('Gagal memuat data absensi: $e');
    }
      }
}*/
