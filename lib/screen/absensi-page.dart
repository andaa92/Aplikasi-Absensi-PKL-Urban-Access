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
      _loadAbsensi();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Data login tidak ditemukan.';
      });
    }
  }

 Future<void> _loadAbsensi() async { 

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
              'masuk': e.masuk,
              'keluar': e.keluar,
              'status': e.status,
            }))
        .toList();

    // 🟢 Filter hanya data 1 bulan terakhir
    final now = DateTime.now();
    final satuBulanLalu = DateTime(now.year, now.month - 1, now.day);

    final List<AbsensiModel> filtered = list.where((item) {
      final tanggalItem = DateFormat('yyyy-MM-dd').parse(item.tanggal);
      return tanggalItem.isAfter(satuBulanLalu) || tanggalItem.isAtSameMomentAs(satuBulanLalu);
    }).toList();

    // 🟢 Urutkan dari tanggal terbaru ke terlama
    filtered.sort((a, b) {
      final tglA = DateFormat('yyyy-MM-dd').parse(a.tanggal);
      final tglB = DateFormat('yyyy-MM-dd').parse(b.tanggal);
      return tglB.compareTo(tglA); // Descending (terbaru duluan)
    });

    setState(() {
      _absensiList = filtered;
      _filteredList = filtered;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Gagal memuat data absensi: $e';
    });
  }
}


  void _applyFilter(String filter, DateTimeRange? range) {
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
    padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
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


        const SizedBox(height: 20),
        const Text(
          'Riwayat Absensi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          now,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}


  Widget _buildAbsensiItem(AbsensiModel item) {
    return Card(
  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  elevation: 3,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: item.statusBgColor,
        child: Icon(item.icon, color: item.statusColor),
      ),
      title: Text(
        '${item.hari}, ${item.tanggal}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Masuk: ${item.checkIn}'),
          Text('Pulang: ${item.checkOut}'),
        ],
      ),
      trailing: Text(
        item.status,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: item.statusColor,
        ),
      ),
    ),
  ),
);

}
}