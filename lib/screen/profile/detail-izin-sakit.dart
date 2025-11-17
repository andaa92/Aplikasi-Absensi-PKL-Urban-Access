import 'package:flutter/material.dart';

class DetailIzinSakit extends StatelessWidget {
  const DetailIzinSakit({Key? key}) : super(key: key);

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
                'Panduan Izin & Sakit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              // Pengertian Izin dan Sakit
              _buildSectionTitle('Apa itu Izin dan Sakit?'),
              const Text(
                'Izin dan Sakit adalah fitur yang memungkinkan Anda untuk mengajukan permohonan tidak masuk kerja dengan alasan tertentu:',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.assignment_outlined, color: Colors.blue[700], size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'IZIN',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Digunakan untuk keperluan pribadi seperti urusan keluarga, acara penting, atau keperluan mendesak lainnya yang membuat Anda tidak dapat hadir bekerja.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[900],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.medical_services_outlined, color: Colors.red[700], size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SAKIT',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Digunakan ketika Anda mengalami kondisi kesehatan yang tidak memungkinkan untuk bekerja, seperti demam, flu, atau sakit lainnya yang memerlukan istirahat.',
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
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Cara Mengajukan Izin/Sakit
              _buildSectionTitle('Cara Mengajukan Izin atau Sakit'),
              const Text(
                'Untuk mengajukan izin atau sakit, ikuti langkah-langkah berikut dengan seksama:',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              _buildNumberedStep('1', 'Buka aplikasi dan masuk ke Halaman Dashboard'),
              _buildNumberedStep('2', 'Cari dan tekan menu "Izin" atau "Sakit" sesuai kebutuhan Anda'),
              _buildNumberedStep('3', 'Anda akan diarahkan ke halaman form pengajuan'),
              _buildNumberedStep('4', 'Isi SEMUA form input yang tersedia dengan lengkap dan benar'),
              _buildNumberedStep('5', 'Pada kolom "Keterangan", jelaskan alasan Anda secara DETAIL dan JELAS'),
              _buildNumberedStep('6', 'Pastikan semua informasi sudah benar, lalu tekan tombol "Kirim"'),
              _buildNumberedStep('7', 'Tunggu konfirmasi dari atasan atau HRD Anda'),
              
              const SizedBox(height: 20),
              
              // Peringatan Penting
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_outlined, color: Colors.red[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PENTING!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Semua form input WAJIB diisi dengan lengkap. Keterangan harus jelas dan spesifik menjelaskan alasan Anda. Pengajuan yang tidak lengkap atau keterangan yang tidak jelas akan ditolak.',
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
              
              // Ketentuan Pengajuan
              _buildSectionTitle('Ketentuan Pengajuan'),
              _buildBulletPoint('Pengajuan izin sebaiknya dilakukan minimal H-1 (sehari sebelumnya)'),
              _buildBulletPoint('Untuk sakit mendadak, segera ajukan pada hari yang sama'),
              _buildBulletPoint('Keterangan harus spesifik, contoh: "Sakit demam tinggi 39°C" bukan hanya "Sakit"'),
              _buildBulletPoint('Upload dokumen pendukung jika diminta (seperti surat dokter untuk sakit)'),
              _buildBulletPoint('Pastikan nomor telepon yang bisa dihubungi aktif'),
              
              const SizedBox(height: 20),
              
              // Contoh Keterangan yang Baik
              _buildSectionTitle('Contoh Keterangan yang Baik dan Benar'),
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
                        Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Contoh BENAR:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• "Sakit demam tinggi 39°C sejak tadi malam, disertai batuk dan flu. Sudah ke dokter dan disarankan istirahat total."\n\n• "Izin mengurus orang tua yang dirawat di RS Hasan Sadikin Bandung. Harus mendampingi untuk tindakan medis."\n\n• "Izin menghadiri pemakaman kakek di Tasikmalaya. Keberangkatan pukul 06.00 pagi."',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[900],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
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
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.orange[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Contoh SALAH (Terlalu Singkat):',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• "Sakit"\n• "Izin urusan keluarga"\n• "Tidak bisa masuk"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[900],
                        height: 1.5,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
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
                            'Tips Pengajuan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan[900],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Selalu berikan keterangan yang jujur, detail, dan dapat dipertanggungjawabkan. Semakin jelas keterangan Anda, semakin cepat pengajuan disetujui.',
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

  Widget _buildNumberedStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}