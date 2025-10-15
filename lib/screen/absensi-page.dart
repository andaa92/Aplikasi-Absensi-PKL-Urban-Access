import 'package:flutter/material.dart';

void main() {
  runApp(const AbsensiPageApp());
}

class AbsensiPageApp extends StatelessWidget {
  const AbsensiPageApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AbsensiPage(),
    );
  }
}

class AbsensiPage extends StatelessWidget {
  const AbsensiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient
              (colors: [ Color(0xFF4FC3F7), Color(0xFF29B6F6) ] ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar with icons and profile
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 35, vertical: 35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.arrow_back,
                                color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Icon(Icons.refresh, color: Colors.white, size: 24),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              'Rayfan Maulana',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF2196F3),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Title
                  Padding(
  padding: const EdgeInsets.only(left: 20, top: 0, bottom: 24),
  child: Transform.translate(
    offset: const Offset(0, -25), // nilai negatif = geser ke atas
    child: const Text(
      'Riwayat Absensi',
      style: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),

                ],
              ),
            ),
          ),
          // Filter Button
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      GestureDetector(
        onTap: () {
          // Popup tampil
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  "Filter Absensi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pilih Periode Waktu"),
                    const SizedBox(height: 10),
                   Row(
  children: [
    Expanded(
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null) {
            // tampilkan hasil di console (sementara)
            print("Dari Tanggal: $picked");
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text("Dari Tanggal"),
        ),
      ),
    ),
    const SizedBox(width: 10),
    Expanded(
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null) {
            print("Sampai Tanggal: $picked");
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text("Sampai Tanggal"),
        ),
      ),
    ),
  ],
),

                    const SizedBox(height: 20),
                    const Text("Filter Berdasarkan:"),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Terlambat", child: Text("Terlambat")),
                        DropdownMenuItem(value: "Hadir", child: Text("Hadir")),
                        DropdownMenuItem(value: "Izin", child: Text("Izin")),
                        DropdownMenuItem(value: "Sakit", child: Text("Sakit")),
                      ],
                      onChanged: (value) {},
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("BATAL"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("TERAPKAN"),
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: const Text(
            'FILTER',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    ],
  ),
),
          // Divider line
     // Divider line
Container(
  height: 1,
  margin: const EdgeInsets.symmetric(vertical: 8),
  decoration: BoxDecoration(
    color: Colors.grey.shade300,
  ),
),



          // List Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildAbsensiItem(
                  hari: 'Kamis',
                  tanggal: '2, Oktober 2025',
                  statusIcon: Icons.close,
                  statusColor: const Color(0xFFFF5252),
                  statusBgColor: const Color(0xFFFFCDD2),
                  backgroundColor: Colors.white,
                ),
                _buildAbsensiItem(
                  hari: 'Jumat',
                  tanggal: '3, Oktober 2025',
                  statusIcon: Icons.edit,
                  statusColor: const Color(0xFFFFC107),
                  statusBgColor: const Color(0xFFFFF59D),
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
                _buildAbsensiItem(
                  hari: 'Senin',
                  tanggal: '6, Oktober 2025',
                  statusIcon: Icons.check_circle,
                  statusColor: const Color(0xFF4CAF50),
                  statusBgColor: const Color(0xFFC8E6C9),
                  backgroundColor: Colors.white,
                ),
                _buildAbsensiItem(
                  hari: 'Selasa',
                  tanggal: '7, Oktober 2025',
                  statusIcon: Icons.check_circle,
                  statusColor: const Color(0xFF4CAF50),
                  statusBgColor: const Color(0xFFC8E6C9),
                  backgroundColor: Colors.white,
                ),
                _buildAbsensiItem(
                  hari: 'Rabu',
                  tanggal: '8, Oktober 2025',
                  statusIcon: Icons.check_circle,
                  statusColor: const Color(0xFF4CAF50),
                  statusBgColor: const Color(0xFFC8E6C9),
                  backgroundColor: Colors.white,
                ),
                _buildAbsensiItem(
                  hari: 'Kamis',
                  tanggal: '9, Oktober 2025',
                  statusIcon: Icons.check_circle,
                  statusColor: const Color(0xFF4CAF50),
                  statusBgColor: const Color(0xFFC8E6C9),
                  backgroundColor: Colors.white,
                ),
                _buildAbsensiItem(
                  hari: 'Jumat',
                  tanggal: '10, Oktober 2025',
                  statusIcon: Icons.check_circle,
                  statusColor: const Color(0xFF4CAF50),
                  statusBgColor: const Color(0xFFC8E6C9),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                _buildKeteranganSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsensiItem({
  required String hari,
  required String tanggal,
  required IconData statusIcon,
  required Color statusColor,
  required Color statusBgColor,
  required Color backgroundColor,
}) {
  return Container(
     margin: const EdgeInsets.symmetric(vertical: 2),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    decoration: BoxDecoration(
      color: backgroundColor,
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade400, width: 0.6),
      ),
    ),
     child: Row(
      children: [
        // Kolom kiri: hari
        Expanded(
          flex: 3,
          child: Text(
            hari,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),

        // Spacer buat jarak
        const Spacer(),

       // Kolom tengah: tanggal
        Expanded(
          flex: 4,
          child: Center(
            child: Text(
              tanggal,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Spacer lagi biar posisi tengah tetap pas
        const Spacer(),

         // Kolom kanan: ikon status
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: statusBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusIcon,
                size: 18,
                color: statusColor,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}



  static Widget _buildKeteranganSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KETERANGAN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildKeteranganItem(
                  icon: Icons.sick,
                  text: 'SAKIT',
                  iconColor: const Color(0xFFFF9800),
                  iconBgColor: const Color(0xFFFFE0B2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKeteranganItem(
                  icon: Icons.calendar_today,
                  text: 'IZIN',
                  iconColor: const Color(0xFFFFC107),
                  iconBgColor: const Color(0xFFFFF9C4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKeteranganItem(
                  icon: Icons.check_circle,
                  text: 'TEPAT WAKTU',
                  iconColor: const Color(0xFF4CAF50),
                  iconBgColor: const Color(0xFFC8E6C9),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKeteranganItem(
                  icon: Icons.close,
                  text: 'TERLAMBAT',
                  iconColor: const Color(0xFFFF5252),
                  iconBgColor: const Color(0xFFFFCDD2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildKeteranganItem({
    required IconData icon,
    required String text,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '=',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  
}
