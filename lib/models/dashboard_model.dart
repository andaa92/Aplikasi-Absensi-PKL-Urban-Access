class DashboardData {
  final int hadir;
  final int terlambat;
  final int izin;
  final int sakit;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<HistoryAbsen> history;

  DashboardData({
    required this.hadir,
    required this.terlambat,
    required this.izin,
    required this.sakit,
    required this.history,
    this.startDate,
    this.endDate,
  });
}

class HistoryAbsen {
  final String tanggal;
  final String keterangan;
  final String masuk;
  final String keluar;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  HistoryAbsen({
    required this.tanggal,
    required this.keterangan,
    required this.masuk,
    required this.keluar,
    required this.status,
    this.startDate,
    this.endDate,
  });
}
