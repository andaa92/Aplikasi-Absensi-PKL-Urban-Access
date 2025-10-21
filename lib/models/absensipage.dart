import 'package:flutter/material.dart';

class AbsensiModel {
  final String hari;
  final String tanggal;
  final String checkIn;
  final String checkOut;
  final String status;
  final IconData icon;
  final Color statusColor;
  final Color statusBgColor;

  AbsensiModel({
    required this.hari,
    required this.tanggal,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.icon,
    required this.statusColor,
    required this.statusBgColor,
  });

  // biar gampang parse dari JSON Dashboard
  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    final DateTime? dateObj = DateTime.tryParse(json['tanggal'] ?? '');
    final String hari = dateObj != null ? _namaHari(dateObj.weekday) : '-';
    final String status = json['status'] ?? '-';

    return AbsensiModel(
      hari: hari,
      tanggal: json['tanggal'] ?? '-',
      checkIn: json['masuk'] ?? '-',
      checkOut: json['keluar'] ?? '-',
      status: status,
      icon: _getIcon(status),
      statusColor: _getStatusColor(status),
      statusBgColor: _getStatusColor(status).withOpacity(0.1),
    );
  }

  static String _namaHari(int weekday) {
    switch (weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '-';
    }
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tepat waktu':
        return Colors.green;
      case 'izin':
        return Colors.amber;
      case 'sakit':
        return Colors.orange;
      case 'terlambat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData _getIcon(String status) {
    switch (status.toLowerCase()) {
      case 'tepat waktu':
        return Icons.check_circle;
      case 'izin':
        return Icons.error;
      case 'sakit':
        return Icons.medical_services;
      case 'terlambat':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}
