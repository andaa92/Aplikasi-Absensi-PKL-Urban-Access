class ProfileModel {
  final String nsm;
  final String namaSiswa;
  final String namaSekolah;
  final String namaJurusan;

  ProfileModel({
    required this.nsm,
    required this.namaSiswa,
    required this.namaSekolah,
    required this.namaJurusan,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ProfileModel(
      nsm: data['nsm'] ?? '-',
      namaSiswa: data['nama_siswa'] ?? '-',
      namaSekolah: data['nama_sekolah'] ?? '-',
      namaJurusan: data['nama_jurusan'] ?? '-',
    );
  }
}
