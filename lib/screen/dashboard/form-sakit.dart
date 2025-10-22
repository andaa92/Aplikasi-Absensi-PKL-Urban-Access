import 'package:absensi_pkl_urban/screen/dashboard/succes-submit-page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class FormSakit extends StatefulWidget {
  const FormSakit({Key? key}) : super(key: key);

  @override
  State<FormSakit> createState() => _FormSakitState();
}

class _FormSakitState extends State<FormSakit> {
  final TextEditingController _nsmController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _namaUser;
  String? _emailUser;
  String? _nsmUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaUser = prefs.getString('nama') ?? 'User';
      _emailUser = prefs.getString('email') ?? '';
      _nsmUser = prefs.getString('nsm') ?? '';
      _nsmController.text = _nsmUser ?? '';
    });
  }

    // 🟢 Fungsi refresh tanpa ubah desain
Future<void> _handleRefresh() async {
  await _loadUserData(); // ambil ulang data user
  setState(() {
    _startDateController.clear();
    _endDateController.clear();
    _descriptionController.clear();
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Data berhasil di refresh'),
      backgroundColor: Colors.blueAccent,
      duration: Duration(seconds: 2),
    ),
  );
}

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
  final DateTime now = DateTime.now();

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: DateTime(now.year, now.month, now.day), // 🔒 tidak bisa pilih sebelum hari ini
    lastDate: DateTime(2030),
    helpText: 'Pilih Tanggal Izin',
    cancelText: 'Batal',
    confirmText: 'Pilih',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2196F3), // warna utama kalender
            onPrimary: Colors.white,    // warna teks pada tombol
            onSurface: Colors.black87,  // warna teks tanggal
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2196F3), // warna tombol CANCEL & OK
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24), // pojok kalender lebih halus
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }
}

  // 🔹 Kirim data ke API
  Future<void> _handleSubmit() async {
    if (_startDateController.text.isEmpty ||
        _endDateController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua field'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_emailUser == null || _emailUser!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User belum login atau email tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://hr.urbanaccess.net/api/simpanSakit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "userPkl": _emailUser,
          "tanggal_mulai": _startDateController.text,
          "tanggal_akhir": _endDateController.text,
          "keterangan": _descriptionController.text,
        }),
      );

      print('📡 RESPONSE SAKIT: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['statusCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['msg'] ?? 'Data sakit berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessSubmitPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['msg'] ?? 'Gagal menyimpan data sakit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ ERROR SAKIT: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
    setState(() {
      _startDateController.clear();
      _endDateController.clear();
      _descriptionController.clear();
    });
  }

  @override
  void dispose() {
    _nsmController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                           GestureDetector(
                              onTap: _handleRefresh, // 🟢 panggil fungsi refresh
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),
                          ],
                        ),
                       Row(
                        children: [
                          Text(
                            (() {
                              if (_namaUser == null || _namaUser!.isEmpty) return 'User';
                              final parts = _namaUser!.trim().split(' ');
                              if (parts.length >= 2) {
                                return '${parts[0]} ${parts[1]}';
                              } else {
                                return parts[0];
                              }
                            })(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(0xFF757575),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Halaman Untuk Izin Sakit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kelola dan lihat riwayat laporan sakit anda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                     const SizedBox(height: 15),
                  ],
                  
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Form Pengajuan Sakit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // === NSM Field ===
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'NSM',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nsmController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'NSM otomatis terisi',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === Tanggal Mulai Sakit ===
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Tanggal Mulai Sakit',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _startDateController,
                        readOnly: true,
                        
                        onTap: () => _selectDate(context, _startDateController),
                        decoration: InputDecoration(
                          hintText: 'Pilih tanggal mulai sakit',
                           hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === Tanggal Berakhir Sakit ===
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Tanggal Berakhir Sakit',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () => _selectDate(context, _endDateController),
                        decoration: InputDecoration(
                          hintText: 'Pilih tanggal berakhir sakit',
                           hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === Deskripsi/Alasan Sakit ===
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Deskripsi/Alasan Sakit',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Jelaskan kondisi kesehatan atau penyakit',
                           hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // === Tombol Batal & Submit ===
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleCancel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF5350),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF42A5F5),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}