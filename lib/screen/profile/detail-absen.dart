import 'package:flutter/material.dart';

class DetailAbsen extends StatelessWidget {
  const DetailAbsen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Panduan Absensi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cara Melakukan Absensi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              // Card 1: Lokasi Fitur Absen
              _buildInfoCard(
                icon: Icons.dashboard_rounded,
                iconColor: Colors.blue[700]!,
                title: 'Lokasi Fitur Absensi',
                description: 'Fitur absensi dapat Anda temukan di halaman Dashboard aplikasi. Setelah membuka aplikasi, Anda akan langsung melihat tombol absensi di halaman utama untuk memudahkan akses.',
              ),
              
              const SizedBox(height: 16),
              
              // Card 2: Syarat Koneksi WiFi
              _buildInfoCard(
                icon: Icons.wifi_rounded,
                iconColor: Colors.green[700]!,
                title: 'Persyaratan Koneksi WiFi',
                description: 'Absensi hanya dapat dilakukan ketika perangkat Anda terhubung dengan WiFi kantor yang bernama "Medima-Guest". Pastikan Anda berada di area kantor dan sudah terkoneksi dengan WiFi tersebut sebelum melakukan absensi.',
                warningText: 'Penting: Absensi tidak akan berhasil jika menggunakan koneksi internet lain seperti data seluler atau WiFi selain Medima-Guest.',
              ),
              
              const SizedBox(height: 16),
              
              // Card 3: Ketentuan Absen Pulang
              _buildInfoCard(
                icon: Icons.schedule_rounded,
                iconColor: Colors.orange[700]!,
                title: 'Ketentuan Absen Pulang',
                description: 'Absen pulang hanya dapat dilakukan setelah waktu kerja Anda selesai sesuai dengan jadwal yang telah ditentukan. Sistem akan secara otomatis membandingkan waktu absen Anda dengan jadwal kerja hari tersebut.',
                additionalInfo: 'Untuk mengetahui jam kerja Anda hari ini, silakan cek detail informasi di menu Jadwal Kerja.',
              ),
              
              const SizedBox(height: 32),
              
              // Tips Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, 
                          color: Colors.blue[700], 
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tips Absensi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTipItem('Pastikan WiFi Medima-Guest sudah terhubung sebelum membuka aplikasi'),
                    _buildTipItem('Lakukan absensi masuk segera setelah tiba di kantor'),
                    _buildTipItem('Cek jadwal kerja Anda di awal hari untuk mengetahui jam pulang'),
                    _buildTipItem('Hubungi admin jika mengalami kendala dalam melakukan absensi'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
             
              
              // Feedback Section
              const Text(
                'Apakah artikel ini membantu?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Terima kasih atas feedback Anda!'),
                            backgroundColor: Color(0xFF4FC3F7),
                          ),
                        );
                      },
                      icon: const Icon(Icons.thumb_up_outlined),
                      label: const Text('Ya, Membantu'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[700],
                        side: BorderSide(color: Colors.green[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Maaf artikel ini kurang membantu. Tim kami akan melakukan perbaikan.'),
                            backgroundColor: Colors.orange,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      icon: const Icon(Icons.thumb_down_outlined),
                      label: const Text('Kurang Jelas'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    String? warningText,
    String? additionalInfo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
          if (warningText != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, 
                    color: Colors.red[700], 
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warningText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red[900],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (additionalInfo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, 
                    color: Colors.amber[900], 
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      additionalInfo,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color.fromARGB(255, 31, 120, 253),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[900],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}