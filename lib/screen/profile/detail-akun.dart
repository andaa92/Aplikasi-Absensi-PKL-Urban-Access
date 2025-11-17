import 'package:flutter/material.dart';

class DetailAkun extends StatelessWidget {
  const DetailAkun({Key? key}) : super(key: key);

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
                'Informasi Akun User PKL',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              // Penjelasan Akun PKL
              _buildSectionTitle('Apa itu Akun User PKL?'),
              const Text(
                'Akun User PKL (Praktik Kerja Lapangan) adalah akun khusus yang dibuat untuk siswa/mahasiswa yang sedang menjalani program magang atau praktik kerja di perusahaan. Akun ini memiliki hak akses terbatas dan disesuaikan dengan kebutuhan peserta PKL.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Fitur Akun PKL
              _buildSectionTitle('Fitur yang Tersedia untuk Akun PKL'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      Icons.fingerprint,
                      'Absensi Harian',
                      'Check in dan check out setiap hari kerja',
                      Colors.blue,
                    ),
                    const Divider(height: 24),
                    _buildFeatureItem(
                      Icons.schedule,
                      'Jadwal Kerja',
                      'Melihat jadwal dan jam kerja PKL',
                      Colors.green,
                    ),
                    const Divider(height: 24),
                    _buildFeatureItem(
                      Icons.assignment_outlined,
                      'Pengajuan Izin/Sakit',
                      'Mengajukan izin atau sakit jika berhalangan',
                      Colors.orange,
                    ),
                    const Divider(height: 24),
                    _buildFeatureItem(
                      Icons.person_outline,
                      'Profil PKL',
                      'Melihat data diri dan informasi PKL',
                      Colors.purple,
                    ),
                    const Divider(height: 24),
                    _buildFeatureItem(
                      Icons.history,
                      'Riwayat Absensi',
                      'Melihat rekap kehadiran selama PKL',
                      Colors.cyan,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Masa Aktif Akun
              _buildSectionTitle('Masa Aktif Akun'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.schedule, color: Colors.orange[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Durasi Akun PKL',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Akun PKL Anda akan aktif sesuai dengan durasi program PKL yang telah ditentukan oleh sekolah/universitas dan perusahaan. Biasanya berkisar antara 1-6 bulan tergantung kebijakan institusi.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[900],
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
              
              // Ketentuan Penggunaan
              _buildSectionTitle('Ketentuan Penggunaan Akun PKL'),
              _buildBulletPoint('Akun hanya dapat digunakan oleh pemilik akun yang terdaftar'),
              _buildBulletPoint('Dilarang membagikan username dan password kepada orang lain'),
              _buildBulletPoint('Wajib menjaga kerahasiaan data login Anda'),
              _buildBulletPoint('Akun harus digunakan sesuai dengan prosedur yang berlaku'),
              _buildBulletPoint('Pelanggaran dapat mengakibatkan akun dinonaktifkan'),
              
              const SizedBox(height: 20),
              
              // Yang Harus Dilakukan
              _buildSectionTitle('Yang Harus Anda Lakukan'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700], size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Kewajiban Peserta PKL:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildChecklistItem('Absen tepat waktu setiap hari kerja'),
                    _buildChecklistItem('Mengikuti jadwal kerja yang telah ditentukan'),
                    _buildChecklistItem('Mengajukan izin jika berhalangan hadir'),
                    _buildChecklistItem('Menjaga sikap dan perilaku yang profesional'),
                    _buildChecklistItem('Menggunakan aplikasi dengan bertanggung jawab'),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Yang Tidak Boleh Dilakukan
              _buildSectionTitle('Yang Tidak Boleh Dilakukan'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red[700], size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Larangan:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCrossItem('Manipulasi data absensi'),
                    _buildCrossItem('Memberikan akses akun kepada orang lain'),
                    _buildCrossItem('Melakukan absensi untuk orang lain (titip absen)'),
                    _buildCrossItem('Mengakses fitur atau data yang tidak berhak'),
                    _buildCrossItem('Menyalahgunakan aplikasi untuk hal yang tidak semestinya'),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Sanksi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.grey[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Konsekuensi Pelanggaran',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pelanggaran terhadap ketentuan penggunaan akun dapat mengakibatkan: penonaktifan akun sementara atau permanen, pelaporan kepada pihak sekolah/universitas, dan dapat mempengaruhi penilaian PKL Anda.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[900],
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
              
              // Tips
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
                    Icon(Icons.lightbulb_outline, color: Colors.cyan[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips Sukses PKL',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manfaatkan aplikasi ini dengan baik untuk membantu Anda menjalani PKL dengan profesional. Disiplin dalam absensi dan komunikasi yang baik akan memberikan nilai positif dalam penilaian PKL Anda.',
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

  Widget _buildFeatureItem(IconData icon, String title, String description, MaterialColor color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color[700], size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[900],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrossItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.close, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[900],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}