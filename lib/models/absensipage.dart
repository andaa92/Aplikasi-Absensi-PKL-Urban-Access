import 'package:flutter/material.dart';


class AbsensiModel {
  final String hari;
  final String tanggal;
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;
  final IconData icon;
  final Color statusColor;
  final Color statusBgColor;
  

  AbsensiModel({
    required this.hari,
    required this.tanggal,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.icon,
    required this.statusColor,
    required this.statusBgColor,

  });

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] ?? '';

    String formattedDate = '';
    String dayName = '';

    if (rawDate.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(rawDate);
        const months = [
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember'
        ];
        formattedDate = '${dateTime.day}, ${months[dateTime.month - 1]} ${dateTime.year}';
        dayName = getDayName(rawDate);
      } catch (e) {
        formattedDate = rawDate; // fallback to raw if parsing fails
        dayName = '';
      }
    }

    String status = (json['status'] ?? '').toString().toLowerCase();
    if (status == 'hadir') status = 'tepat waktu';


    return AbsensiModel(
      hari: dayName,
      tanggal: formattedDate,
      date: rawDate,
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      status: json['status'] ?? '',
      icon: mapStatusToIcon(json['status'] ?? ''),
      statusColor: mapStatusToColor(json['status'] ?? ''),
      statusBgColor: mapStatusBgColor(json['status'] ?? ''),
    );
  }
    
    
  

  static IconData mapStatusToIcon(String status) {
    switch (status.toLowerCase()) {
      case 'tepat waktu':
        return Icons.check_circle;
      case 'izin':
        return Icons.calendar_today;
      case 'sakit':
        return Icons.sick;
      case 'terlambat':
        return Icons.close;
      default:
        return Icons.help_outline;
    }
  }

  static Color mapStatusToColor(String status) {
    switch (status.toLowerCase()) {
      case 'tepat waktu':
        return const Color(0xFF4CAF50);
      case 'izin':
        return const Color(0xFFFFC107);
      case 'sakit':
        return const Color(0xFFFF9800);
      case 'terlambat':
        return const Color(0xFFFF5252);
      default:
        return Colors.grey;
    }
  }

  static Color mapStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'tepat waktu':
        return const Color(0xFFC8E6C9);
      case 'izin':
        return const Color(0xFFFFF9C4);
      case 'sakit':
        return const Color(0xFFFFE0B2);
      case 'terlambat':
        return const Color(0xFFFFCDD2);
      default:
        return Colors.grey.shade200;
    }
  }
static String getDayName(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];
    return days[date.weekday - 1];
  } catch (e) {
    return '';
  }
}

  
}
