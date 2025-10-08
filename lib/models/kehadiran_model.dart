class KehadiranModel {
  final String id;
  final String date;
  final String status;
  final String checkIn;
  final String checkOut;

  KehadiranModel({
    required this.id,
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
  });

  factory KehadiranModel.fromJson(Map<String, dynamic> json) {
    return KehadiranModel(
      id: json['id_kehadiran_siswa'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
    );
  }
}
