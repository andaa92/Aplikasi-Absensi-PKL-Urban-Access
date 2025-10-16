import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:absensi_pkl_urban/services/api_absensi_services.dart';
import 'package:absensi_pkl_urban/models/absensipage.dart';

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final AbsensiService _service = AbsensiService();
  List<AbsensiModel> _absensiList = [];
  List<AbsensiModel> _filteredAbsensiList = [];
  
  bool _isLoading = true;
  String? _selectedStatusFilter;
  String userPkl = 'sementara';

  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _refreshData() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final data = await AbsensiService().getAbsensiList(userPkl); // ganti sesuai method kamu
    setState(() {
      _absensiList = data;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memuat ulang data: $e')),
    );
  }
}



  @override
  void initState() {
    super.initState();
    _loadAbsensiData();
  }

  Future<void> _loadAbsensiData() async {
    setState(() =>_isLoading = true);
    try {
      final data = await _service.getAbsensiList('destia@gmail.com');
      setState(() {
        _absensiList = data;
        _filteredAbsensiList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAbsensiList = _absensiList.where((item) {
        bool matchesStatus = true;
        bool matchesDate = true;

        if (_selectedStatusFilter != null && _selectedStatusFilter!.isNotEmpty) {
          matchesStatus = item.status.toLowerCase() == _selectedStatusFilter!.toLowerCase();
        }

        if (_startDate != null && _endDate != null && item.date.isNotEmpty) {
          try {
            final itemDate = DateTime.parse(item.date);
            matchesDate = itemDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                          itemDate.isBefore(_endDate!.add(const Duration(days: 1)));
          } catch (_) {
            matchesDate = false;
          }
        }

        return matchesStatus && matchesDate;
      }).toList();
    });
  }


  Future<void> _selectDateRange(BuildContext context) async {
    final start = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (start == null) return;

    final end = await showDatePicker(
      context: context,
      initialDate: _endDate ?? start,
      firstDate: start,
      lastDate: DateTime(2100),
    );

    if (end != null) {
      setState(() {
        _startDate = start;
        _endDate = end;
      });
      _applyFilters();
    }
  }

  // === UI STATUS HELPER ===
  IconData getStatusIcon(String status) => AbsensiModel.mapStatusToIcon(status);
  Color getStatusColor(String status) => AbsensiModel.mapStatusToColor(status);
  Color getStatusBgColor(String status) => AbsensiModel.mapStatusBgColor(status);

  @override
  Widget build(BuildContext context) {
    final listToShow = _filteredAbsensiList;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          _buildFilterButton(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _absensiList.isEmpty
                    ? const Center(child: Text('Tidak ada data absensi'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: listToShow.length + 1,
                        itemBuilder: (context, index) {
                          if (index < listToShow.length) {
                            final item = listToShow[index];
                            return _buildAbsensiItem(
                              hari: item.hari,
                              tanggal: item.tanggal,
                              checkIn: item.checkIn,
                              checkOut: item.checkOut,
                              status: item.status,
                              statusIcon: getStatusIcon(item.status),
                              statusColor: getStatusColor(item.status),
                              statusBgColor: getStatusBgColor(item.status),
                            );
                          } else {
                            return Column(
                              children: const [
                                SizedBox(height: 20),
                                _KeteranganSection(),
                                SizedBox(height: 80),
                              ],
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // === HEADER ===
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
                    onPressed: _refreshData,
                    tooltip: 'Muat Ulang',
                  )
                  ,
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
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainPage(initialIndex: 2),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Color(0xFF2196F3)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Riwayat Absensi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

   
  // === FILTER BUTTON ===
  Widget _buildFilterButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              _showFilterDialog(context);
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
    );
  }

  void _showFilterDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      String? tempSelectedStatus = _selectedStatusFilter;
      DateTime? tempStartDate = _startDate;
      DateTime? tempEndDate = _endDate;

      final validStatus = ['tepat waktu', 'izin', 'sakit', 'terlambat'];

      if (tempSelectedStatus != null &&
          !validStatus.contains(tempSelectedStatus.toLowerCase())) {
        tempSelectedStatus = null; // reset kalau value gak valid
      }

      return StatefulBuilder(
        builder: (context, setStateDialog) {
          Future<void> pickStartDate() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: tempStartDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setStateDialog(() => tempStartDate = picked);
            }
          }

          Future<void> pickEndDate() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: tempEndDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setStateDialog(() => tempEndDate = picked);
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Filter Absensi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown Status
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Status',
                      border: OutlineInputBorder(),
                    ),
                    value: validStatus.contains(tempSelectedStatus?.toLowerCase())
                        ? tempSelectedStatus
                        : null,
                    items: const [
                      DropdownMenuItem(value: 'tepat waktu', child: Text('Tepat Waktu')),
                      DropdownMenuItem(value: 'izin', child: Text('Izin')),
                      DropdownMenuItem(value: 'sakit', child: Text('Sakit')),
                      DropdownMenuItem(value: 'terlambat', child: Text('Terlambat')),
                    ],
                    onChanged: (value) {
                      setStateDialog(() {
                        tempSelectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tombol pilih tanggal awal
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: pickStartDate,
                          child: Text(
                            tempStartDate == null
                                ? 'Pilih Tanggal Awal'
                                : 'Dari: ${tempStartDate!.toLocal().toString().split(' ')[0]}',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Tombol pilih tanggal akhir
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: pickEndDate,
                          child: Text(
                            tempEndDate == null
                                ? 'Pilih Tanggal Akhir'
                                : 'Sampai: ${tempEndDate!.toLocal().toString().split(' ')[0]}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("BATAL"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedStatusFilter = tempSelectedStatus;
                    _startDate = tempStartDate;
                    _endDate = tempEndDate;
                  });
                  Navigator.pop(context);
                  _applyFilters(); // jalankan filter setelah diterapkan
                },
                child: const Text("TERAPKAN"),
              ),
            ],
          );
        },
      );
    },
  );
}


  // === ABSENSI ITEM ===
  Widget _buildAbsensiItem({
    required String hari,
    required String tanggal,
    required String checkIn,
    required String checkOut,
    required String status,
    required IconData statusIcon,
    required Color statusColor,
    required Color statusBgColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kiri: Hari, tanggal, dan jam
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hari,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(tanggal, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 8),
              Text('In : ${checkIn.isNotEmpty ? checkIn : "-"}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              Text('Out : ${checkOut.isNotEmpty ? checkOut : "-"}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          // Kanan: status badge
          Container(
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  _capitalizeStatus(status),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeStatus(String text) {
    return text.isEmpty ? '' : '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }
}

// === BAGIAN KETERANGAN ===
class _KeteranganSection extends StatelessWidget {
  const _KeteranganSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'KETERANGAN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _KeteranganItem(
                  icon: Icons.sick,
                  text: 'SAKIT',
                  iconColor: Color(0xFFFF9800),
                  iconBgColor: Color(0xFFFFE0B2),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _KeteranganItem(
                  icon: Icons.calendar_today,
                  text: 'IZIN',
                  iconColor: Color(0xFFFFC107),
                  iconBgColor: Color(0xFFFFF9C4),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _KeteranganItem(
                  icon: Icons.check_circle,
                  text: 'TEPAT WAKTU',
                  iconColor: Color(0xFF4CAF50),
                  iconBgColor: Color(0xFFC8E6C9),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _KeteranganItem(
                  icon: Icons.close,
                  text: 'TERLAMBAT',
                  iconColor: Color(0xFFFF5252),
                  iconBgColor: Color(0xFFFFCDD2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeteranganItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color iconBgColor;

  const _KeteranganItem({
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 18),
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
