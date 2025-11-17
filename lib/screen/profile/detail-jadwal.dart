import 'package:flutter/material.dart';

class DetailJadwal extends StatelessWidget {
  const DetailJadwal({Key? key}) : super(key: key);

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
          'Pusat bantuan',
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
                'Jadwal Kerja PKL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Jadwal kerja adalah panduan waktu yang harus Anda ikuti selama menjalani program PKL. Pastikan Anda memahami dan mematuhi jadwal yang telah ditentukan agar penilaian PKL Anda optimal.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Jadwal Kerja Resmi
              _buildSectionTitle('Jadwal Kerja Resmi'),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Jam Kerja PKL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildScheduleItem(
                      'Senin - Kamis',
                      '08:00 - 17:00',
                      '9 jam kerja (termasuk istirahat)',
                      Icons.calendar_month,
                    ),
                    const SizedBox(height: 16),
                    _buildScheduleItem(
                      'Jumat',
                      '08:00 - 17:30',
                      '9,5 jam kerja (termasuk istirahat)',
                      Icons.calendar_today_outlined,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Penjelasan Detail
              _buildSectionTitle('Penjelasan Jadwal'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      Icons.login,
                      'Jam Masuk (Check In)',
                      'Pukul 08:00 WIB setiap hari kerja',
                      Colors.orange,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.logout,
                      'Jam Pulang (Check Out)',
                      'Senin-Kamis: 17:00 WIB\nJumat: 17:30 WIB',
                      Colors.orange,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.free_breakfast,
                      'Waktu Istirahat',
                      'Sudah termasuk dalam jam kerja\n(biasanya 12:00-13:00)',
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Ketentuan Penting
              _buildSectionTitle('Ketentuan Penting Jadwal Kerja'),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!, width: 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.access_time, color: Colors.red[700], size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PENTING: Ketentuan Absensi Pulang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Absensi pulang (Check Out) TIDAK DAPAT dilakukan sebelum waktu kerja sesuai jadwal hari tersebut selesai.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[900],
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Senin-Kamis: Baru bisa check out mulai pukul 17:00\n• Jumat: Baru bisa check out mulai pukul 17:30\n\nTombol check out akan otomatis aktif sesuai jadwal.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[900],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Aturan Keterlambatan
              _buildSectionTitle('Aturan Kehadiran'),
              _buildBulletPoint('Tepat waktu: Check in sebelum atau tepat pukul 08:00'),
              _buildBulletPoint('Terlambat: Check in setelah pukul 08:00 akan tercatat sebagai terlambat'),
              _buildBulletPoint('Wajib hadir setiap hari kerja sesuai jadwal'),
              _buildBulletPoint('Jika berhalangan hadir, ajukan izin/sakit melalui aplikasi'),
              _buildBulletPoint('Pulang lebih awal harus seizin supervisor'),
              
              const SizedBox(height: 20),
              
              // Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.green[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips Disiplin Waktu',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Datang 10-15 menit lebih awal untuk persiapan\n• Set alarm sebagai pengingat\n• Cek jadwal rutin melalui aplikasi\n• Rencanakan perjalanan dengan baik\n• Disiplin waktu = penilaian PKL baik',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[900],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Hari Libur
              _buildSectionTitle('Hari Libur dan Libur Nasional'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.beach_access, color: Colors.blue[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Anda tidak perlu absensi pada hari Sabtu, Minggu, dan libur nasional kecuali ada pemberitahuan khusus dari perusahaan. Jadwal khusus akan diinformasikan melalui aplikasi.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Perubahan Jadwal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.cyan[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.cyan[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perubahan Jadwal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Jika ada perubahan jadwal kerja (misalnya karena event khusus atau hari libur pengganti), Anda akan mendapat notifikasi melalui aplikasi. Selalu cek aplikasi secara rutin.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.cyan[900],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            
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
                      label: const Text('Ya'),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Maaf artikel ini kurang membantu'),
                            backgroundColor: Colors.grey,
                          ),
                        );
                      },
                      icon: const Icon(Icons.thumb_down_outlined),
                      label: const Text('Tidak'),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String day, String time, String duration, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String detail, MaterialColor color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 13,
                  color: color[900],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}