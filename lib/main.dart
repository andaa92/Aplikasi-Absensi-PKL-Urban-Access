import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RiwayatAbsensiScreen(),
    );
  }
}

class RiwayatAbsensiScreen extends StatelessWidget {
  const RiwayatAbsensiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.arrow_back, color: Colors.white, size: 24),
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
                                fontSize: 13,
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
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 8, bottom: 24),
                    child: Text(
                      'Riwayat Absensi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
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
                  onTap: () {},
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
          Container(
            height: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  backgroundColor: const Color(0xFFF5F5F5),
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
      bottomNavigationBar: _buildBottomNavigationBar(),
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
      margin: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hari,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tanggal,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeteranganSection() {
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

  Widget _buildKeteranganItem({
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    color: Color(0xFF2196F3),
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.home_outlined,
                color: Colors.grey.shade400,
                size: 26,
              ),
              Icon(
                Icons.person_outline,
                color: Colors.grey.shade400,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
