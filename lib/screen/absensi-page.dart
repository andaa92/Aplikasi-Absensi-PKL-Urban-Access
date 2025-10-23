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
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Filter Absensi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tempFilter,
                    decoration: const InputDecoration(
                      labelText: "Jenis Absensi",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Semua", child: Text("Semua")),
                      DropdownMenuItem(
                          value: "Tepat Waktu", child: Text("Tepat Waktu")),
                      DropdownMenuItem(value: "Izin", child: Text("Izin")),
                      DropdownMenuItem(value: "Sakit", child: Text("Sakit")),
                      DropdownMenuItem(
                          value: "Terlambat", child: Text("Terlambat")),
                    ],
                    onChanged: (val) => setStateDialog(() => tempFilter = val!),
                  ),
                  const SizedBox(height: 16),
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
                      );
                      if (picked != null) {
                        setStateDialog(() => tempRange = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Rentang Tanggal",
                        border: OutlineInputBorder(),
                      ),
                      child: Text(tempRange == null
                          ? 'Pilih tanggal'
                          : '${DateFormat('d MMM yyyy').format(tempRange!.start)} - ${DateFormat('d MMM yyyy').format(tempRange!.end)}'),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilter(tempFilter, tempRange);
                  },
                  child: const Text('Terapkan'),
                ),
              ],
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
      body: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                onPressed: _openFilterDialog,
                child: const Text(
                  "FILTER",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _filteredList.isEmpty
                        ? const Center(child: Text('Belum ada data absensi.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) {
                              final item = _filteredList[index];
                              return _buildAbsensiItem(item);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
  final now = DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now());

  return Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
    ),
    padding: const EdgeInsets.fromLTRB(20, 30, 24, 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 26),
              onPressed: _loadAbsensi,
            ),
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


        const SizedBox(height: 25),
        const Text(
          'Riwayat Absensi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
          const SizedBox(height: 10),

        Text(
          now,
          style: const TextStyle(
            color: Color.fromARGB(198, 255, 255, 255),
            fontSize: 16,
          ),
        ),
       
      ],
    ),
    
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
               Row(children: [
                    Expanded(
                        child: Text("Masuk: ${item.checkIn}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black45))),
                    Expanded(
                        child: Text("Keluar: ${item.checkOut}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black45))),
                  ]),
            ],
          ),
        ),
       
       const SizedBox(width: 5),

        // 🔹 Status text
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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