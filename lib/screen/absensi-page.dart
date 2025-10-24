import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/absensipage.dart';
import '../models/dashboard_model.dart';
import '../services/api_service.dart';

class AbsensiPage extends StatefulWidget {
  final String userEmail;
  const AbsensiPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final ApiService _apiService = ApiService();
  List<AbsensiModel> _absensiList = [];
  List<AbsensiModel> _filteredList = [];
  bool _isLoading = true;
  String? _errorMessage;

  String? _userName;
  String? _userEmail;

  // Filter state
  String _selectedFilter = "Semua";
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadUserInfo();
  }

  Future<String?> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nama') ?? 'User';
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final email = prefs.getString('email');
    
    print('DEBUG: name = $name, email = $email');

    setState(() {
      _userName = name ?? 'User';
      _userEmail = email ?? '';
    });

    if (_userEmail != null && _userEmail!.isNotEmpty) {
      _loadAbsensi(applyDefaultFilter: true);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Data login tidak ditemukan.';
      });
    }
  }

  Future<void> _loadAbsensi({bool applyDefaultFilter = true}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final DashboardData dashboardData =
          await _apiService.fetchDashboardData(_userEmail!);

      final List<AbsensiModel> list = dashboardData.history
          .map((e) => AbsensiModel.fromJson({
                'tanggal': e.tanggal,
                'keterangan': e.keterangan,
                'masuk': e.masuk,
                'keluar': e.keluar,
                'status': e.status,
              }))
          .where((absen) => absen.status.toLowerCase() != 'libur')
          .toList();

      List<AbsensiModel> filteredList = list;

      if (applyDefaultFilter) {
        final DateTime now = DateTime.now();
        final DateTime oneWeekAgo = now.subtract(const Duration(days: 7));

        filteredList = list.where((absen) {
          final date = DateTime.parse(absen.tanggal);
          return date.isAfter(oneWeekAgo) &&
              date.isBefore(now.add(const Duration(days: 1)));
        }).toList();
      }

      // urutkan terbaru -> terlama
      filteredList.sort((a, b) =>
          DateTime.parse(b.tanggal).compareTo(DateTime.parse(a.tanggal)));

      setState(() {
        _absensiList = filteredList;
        _filteredList = filteredList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data absensi: $e';
      });
    }
  }

  void _applyFilter(String filter, DateTimeRange? range) async {
    // saat user filter manual, kita reload semua data tanpa batas 7 hari
    await _loadAbsensi(applyDefaultFilter: false);

    List<AbsensiModel> tempList = _absensiList;

    if (filter != "Semua") {
      tempList = tempList
          .where((e) => e.status.toLowerCase() == filter.toLowerCase())
          .toList();
    }

    if (range != null) {
      tempList = tempList.where((e) {
        final date = DateFormat('yyyy-MM-dd').parse(e.tanggal);
        return date.isAfter(range.start.subtract(const Duration(days: 1))) &&
            date.isBefore(range.end.add(const Duration(days: 1)));
      }).toList();
    }

    // urutkan juga dari terbaru -> terlama
    tempList.sort((a, b) =>
        DateTime.parse(b.tanggal).compareTo(DateTime.parse(a.tanggal)));

    setState(() {
      _selectedFilter = filter;
      _selectedDateRange = range;
      _filteredList = tempList;
    });
  }

  Future<void> _openFilterDialog() async {
    String tempFilter = _selectedFilter;
    DateTimeRange? tempRange = _selectedDateRange;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF5F9FF)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FC3F7).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.filter_alt_rounded,
                            color: Color(0xFF4FC3F7),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Filter Absensi',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Jenis Absensi
                    const Text(
                      'Jenis Absensi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: tempFilter,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.list_alt_rounded,
                            color: Color(0xFF4FC3F7),
                            size: 22,
                          ),
                        ),
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade600,
                          size: 28,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: "Semua",
                            child: Row(
                              children: const [
                                Icon(Icons.select_all_rounded, size: 20, color: Color(0xFF4FC3F7)),
                                SizedBox(width: 12),
                                Text("Semua", style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Tepat Waktu",
                            child: Row(
                              children: const [
                                Icon(Icons.check_circle, size: 20, color: Color(0xFF4CAF50)),
                                SizedBox(width: 12),
                                Text("Tepat Waktu", style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Terlambat",
                            child: Row(
                              children: const [
                                Icon(Icons.cancel, size: 20, color: Color(0xFFE57373)),
                                SizedBox(width: 12),
                                Text("Terlambat", style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Izin",
                            child: Row(
                              children: const [
                                Icon(Icons.error, size: 20, color: Color(0xFFFFD54F)),
                                SizedBox(width: 12),
                                Text("Izin", style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: "Sakit",
                            child: Row(
                              children: const [
                                Icon(Icons.medical_services, size: 20, color: Color(0xFFFF8A65)),
                                SizedBox(width: 12),
                                Text("Sakit", style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (val) => setStateDialog(() => tempFilter = val!),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Rentang Tanggal
                    const Text(
                      'Rentang Tanggal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: tempRange ??
                              DateTimeRange(
                                start: DateTime.now()
                                    .subtract(const Duration(days: 7)),
                                end: DateTime.now(),
                              ),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF4FC3F7),
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setStateDialog(() => tempRange = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF4FC3F7),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tempRange == null
                                    ? 'Pilih tanggal'
                                    : '${DateFormat('d MMM yyyy').format(tempRange!.start)} - ${DateFormat('d MMM yyyy').format(tempRange!.end)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: tempRange == null
                                      ? Colors.grey.shade600
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _applyFilter(tempFilter, tempRange);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF4FC3F7),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Terapkan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : _filteredList.isEmpty
                            ? const Center(child: Text('Belum ada data absensi.'))
                            : ListView.builder(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 8,
                                  bottom: 80, // Beri ruang untuk tombol filter
                                ),
                                itemCount: _filteredList.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredList[index];
                                  return _buildAbsensiItem(item);
                                },
                              ),
              ),
            ],
          ),
          // Tombol FILTER floating di kanan bawah
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 6,
                backgroundColor: const Color(0xFF4FC3F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              ),
              onPressed: _openFilterDialog,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.filter_list, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "FILTER",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              // === Bar Atas ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Refresh
                  IconButton(
                    onPressed: _loadAbsensi,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),

                  // Nama & Profil
                  Row(
                    children: [
                      FutureBuilder<String?>(
                        future: _getUserName(),
                        builder: (context, snapshot) {
                          String namaUser = snapshot.data ?? 'User';
                          List<String> parts = namaUser.split(' ');
                          if (parts.length > 2) {
                            namaUser = '${parts[0]} ${parts[1]}';
                          }

                          return Text(
                            namaUser,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MainPage(initialIndex: 2)),
                          );
                        },
                        child: const Icon(Icons.account_circle,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Riwayat Absensi',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  now,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        // 🔹 LINGKARAN GELEMBUNG DEKORASI
        Positioned(
          top: 40,
          right: 25,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: 50,
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          top: 80,
          left: 35,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
        ),
        Positioned(
          top: 30,
          left: 70,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ),
        Positioned(
          top: 140,
          left: 100,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.09),
            ),
          ),
        ),
        Positioned(
          bottom: 25,
          right: 70,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbsensiItem(AbsensiModel item) {
    // Format tanggal seperti di dashboard
    String formatTanggal(String tgl) {
      try {
        final DateTime parsed = DateTime.parse(tgl);
        return DateFormat("d MMMM yyyy", "id_ID").format(parsed);
      } catch (e) {
        return tgl;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 4),
          // 🔹 Ikon status
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.statusBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 17),

          // 🔹 Info absensi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTanggal(item.tanggal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (item.keterangan != null &&
                    item.keterangan!.isNotEmpty &&
                    item.keterangan != '-')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'keterangan: ${item.keterangan!}\n',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Masuk: ${item.checkIn}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Keluar: ${item.checkOut}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 5),

          // 🔹 Status text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: item.statusBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.status,
              style: TextStyle(
                color: item.statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 3),
        ],
      ),
    );
  }
}