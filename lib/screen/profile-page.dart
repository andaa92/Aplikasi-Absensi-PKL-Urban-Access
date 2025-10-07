import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Blue header section
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF5BA3E7),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Back and Refresh buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
          
                       children: [
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                            onPressed: () {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),

                    // Profile Section
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  shape: BoxShape.circle,
                                ),
                                  child: const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Color.fromARGB(255, 156, 156, 156),
                                  
                                ),                                
                              ),
                            
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bebassssssss',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Software Developer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // White content area
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Statistics Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.show_chart, size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'Statistik Bulan Ini',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Oktober 2025',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  '20',
                                  'Tepat Waktu',
                                  const Color(0xFFD4F4DD),
                                  const Color(0xFF5FAF5C),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildStatCard(
                                  '2',
                                  'Terlambat',
                                  const Color(0xFFFFDADA),
                                  const Color(0xFFAF5C5C),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  '1',
                                  'Izin',
                                  const Color(0xFFFFF4D4),
                                  const Color(0xFFAF9A5C),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildStatCard(
                                  '1',
                                  'Sakit',
                                  const Color(0xFFFFDCC4),
                                  const Color(0xFFAF7A5C),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tabs and Info Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Tabs
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 0;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: _selectedTab == 0
                                              ? const Color(0xFF5BA3E7)
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Informasi',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _selectedTab == 0
                                            ? const Color(0xFF5BA3E7)
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedTab = 1;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: _selectedTab == 1
                                              ? const Color(0xFF5BA3E7)
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Detail',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _selectedTab == 1
                                            ? const Color(0xFF5BA3E7)
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Content
                          _selectedTab == 0
                              ? _buildInformasiTab()
                              : _buildDetailTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformasiTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.business_outlined,
            'Departement',
            'Urban Access',
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.email_outlined,
            'Email',
            'jawa.santoso@gmail.com',
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.phone_outlined,
            'Telepon',
            '+62 812 1907 8753',
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Lokasi Kerja',
            'Bandung',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Tanggal',
            '2 Oktober 2025',
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.access_time,
            'Jam Kerja',
            '08:00 - 17:00 WIB',
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.workspace_premium_outlined,
            'Status Karyawan',
            'Praktek Kerja Lapangan',
          ),
          const SizedBox(height: 18),
          _buildInfoRow(
            Icons.person_outline,
            'Atasan Langsung',
            'Zaenal',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 34,
          color: Colors.black87,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}