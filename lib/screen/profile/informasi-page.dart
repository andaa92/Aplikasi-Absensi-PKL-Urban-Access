import 'package:flutter/material.dart';
import 'detail-absen.dart';
import 'detail-izin-sakit.dart';
import 'detail-jadwal.dart';
import 'detail-akun.dart';

class InformasiPage extends StatefulWidget {
  const InformasiPage({Key? key}) : super(key: key);

  @override
  State<InformasiPage> createState() => _InformasiPageState();
}

class _InformasiPageState extends State<InformasiPage> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Data menu dan FAQ untuk pencarian
  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.person_outline,
      'title': 'Akun',
      'keywords': ['akun', 'profil', 'dibekukan', 'suspend'],
      'page': 'DetailAkun',
    },
    {
      'icon': Icons.fingerprint,
      'title': 'Absensi',
      'keywords': ['absensi', 'absen', 'check in', 'check out', 'kehadiran'],
      'page': 'DetailAbsen',
    },
    {
      'icon': Icons.schedule,
      'title': 'Jadwal Kerja',
      'keywords': ['jadwal', 'kerja', 'shift', 'jam kerja'],
      'page': 'DetailJadwal',
    },
    {
      'icon': Icons.assignment_outlined,
      'title': 'Izin & Sakit',
      'keywords': ['izin', 'sakit', 'cuti', 'tidak masuk'],
      'page': 'DetailIzinSakit',
    },
  ];

  final List<Map<String, String>> faqItems = [
    {
      'question': 'Bagaimana cara melakukan absensi?',
      'answer': 'Buka aplikasi -> Halaman Dashbaord -> lalu tekan tombol Absen Sekarang',
    },
    {
      'question': 'Bagaimana cara mengajukan izin atau sakit?',
      'answer': 'Buka Aplikasi -> Halaman Dashbaord -> Tekan menu Izin / Sakit -> Form Input WAJIB terisi -> Kirim form.',
    },
    {
      'question': 'Apa yang harus dilakukan jika lupa absen?',
      'answer': 'Segera hubungi pembimbing PKL untuk melakukan konfirmasi kehadiran.',
    },
    {
      'question': 'Bagaimana cara melihat jadwal kerja?',
      'answer': 'Buka menu Jadwal Kerja untuk melihat jadwal shift dan jadwal kerja bulan ini.',
    },
  ];

  List<Map<String, dynamic>> getFilteredMenuItems() {
    if (searchQuery.isEmpty) {
      return menuItems;
    }
    
    return menuItems.where((item) {
      final titleMatch = item['title'].toLowerCase().contains(searchQuery.toLowerCase());
      final keywordsMatch = (item['keywords'] as List<String>)
          .any((keyword) => keyword.toLowerCase().contains(searchQuery.toLowerCase()));
      return titleMatch || keywordsMatch;
    }).toList();
  }

  List<Map<String, String>> getFilteredFAQItems() {
    if (searchQuery.isEmpty) {
      return faqItems;
    }
    
    return faqItems.where((item) {
      final questionMatch = item['question']!.toLowerCase().contains(searchQuery.toLowerCase());
      final answerMatch = item['answer']!.toLowerCase().contains(searchQuery.toLowerCase());
      return questionMatch || answerMatch;
    }).toList();
  }

  void navigateToDetail(String pageName) {
    Widget? page;
    switch (pageName) {
      case 'DetailAkun':
        page = const DetailAkun();
        break;
      case 'DetailAbsen':
        page = const DetailAbsen();
        break;
      case 'DetailJadwal':
        page = const DetailJadwal();
        break;
      case 'DetailIzinSakit':
        page = const DetailIzinSakit();
        break;
    }
    
    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page!),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenuItems = getFilteredMenuItems();
    final filteredFAQItems = getFilteredFAQItems();
    final hasResults = filteredMenuItems.isNotEmpty || filteredFAQItems.isNotEmpty;

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
          'Bantuan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.grey[700], size: 20),
              const SizedBox(width: 6),
              const Text(
                'Laporan Saya',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Divider setelah AppBar
            Divider(height: 1, color: Colors.grey[200]),

            const SizedBox(height: 20),

            // Cari masalah yang lagi kamu alami
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cari masalah yang lagi kamu alami',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Ada masalah soal...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Hasil pencarian atau menu normal
            if (!hasResults && searchQuery.isNotEmpty) ...[
              // Tidak ada hasil
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada hasil untuk "$searchQuery"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coba kata kunci lain',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Divider
              Container(
                height: 1,
                color: Colors.grey[200],
              ),

              // Menu Items
              if (filteredMenuItems.isNotEmpty) ...[
                ...filteredMenuItems.map((item) => Column(
                      children: [
                        _buildMenuItem(
                          icon: item['icon'] as IconData,
                          title: item['title'] as String,
                          iconColor: item['title'] == 'Akun'
                              ? Colors.black87
                              : Colors.cyan,
                          onTap: () => navigateToDetail(item['page'] as String),
                        ),
                        if (item != filteredMenuItems.last)
                          Divider(height: 1, indent: 56, color: Colors.grey[200]),
                      ],
                    )),
              ],

              const SizedBox(height: 24),

              // FAQ Section
              if (filteredFAQItems.isNotEmpty) ...[
                // Divider sebelum FAQ
                Container(
                  height: 8,
                  color: Colors.grey[100],
                ),

                const SizedBox(height: 20),

                // Pertanyaan Umum
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    'Pertanyaan Umum',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // FAQ List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: filteredFAQItems.map((faq) {
                      final index = filteredFAQItems.indexOf(faq);
                      return Column(
                        children: [
                          _buildFAQItem(
                            question: faq['question']!,
                            answer: faq['answer']!,
                          ),
                          if (index < filteredFAQItems.length - 1)
                            const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.black87,
              size: 26,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: const Color(0xFF4FC3F7).withOpacity(0.1),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.help_outline,
              color: Color(0xFF4FC3F7),
              size: 20,
            ),
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}