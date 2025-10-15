import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = 'unknown_device';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id ?? 'android_unknown';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'ios_unknown';
      }
    } catch (e) {
      print('⚠️ Gagal mendapatkan device ID: $e');
    }

    print('🔍 Device ID Terdeteksi: $deviceId');
    return deviceId;
  }

 Future<void> _login() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email dan Password wajib diisi")),
    );
    return;
  }

  try {
    final deviceId = await _getDeviceId();

    final url = Uri.parse('https://hr.urbanaccess.net/api/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'id_device': deviceId,
      }),
    );

    print('📩 Response Login: ${response.body}');
    var data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['statusCode'] == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // 🟢 Simpan data dasar dari login
      await prefs.setString('email', data['email'] ?? '');
      await prefs.setString('id_device', data['id_device'] ?? deviceId);
      await prefs.setString('token', data['token'] ?? '');

      // Ambil email dari response
      final emailUser = data['email'];
      if (emailUser == null || emailUser.isEmpty) {
        print("⚠️ Email user kosong setelah login");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login gagal: Email user kosong")),
        );
        return;
      }

      // 🟢 Ambil data profil siswa BERDASARKAN email user
      try {
        final profileResponse = await http.get(
          Uri.parse('https://hr.urbanaccess.net/api/profile-siswa?userPkl=$emailUser'),
          headers: {'Accept': 'application/json'},
        );

        print("📡 Response Profile: ${profileResponse.body}");

        if (profileResponse.statusCode == 200) {
          final profileData = jsonDecode(profileResponse.body);
          final siswa = profileData['data'];

          if (siswa != null) {
            // 🟢 Simpan data siswa di local
            await prefs.setString('nama', siswa['nama_siswa'] ?? '');
            await prefs.setString('nsm', siswa['nsm'] ?? '');
            await prefs.setString('sekolah', siswa['nama_sekolah'] ?? '');
            await prefs.setString('jurusan', siswa['nama_jurusan'] ?? '');
            // Simpan email sebagai pengganti userPkl jika backend belum punya userPkl
            await prefs.setString('userPkl', emailUser);

            print("✅ Profil siswa tersimpan: ${siswa['nama_siswa']}");
          } else {
            print("⚠️ Data siswa kosong di API profile-siswa");
          }
        } else {
          print("⚠️ Gagal ambil profile-siswa (${profileResponse.statusCode})");
        }
      } catch (e) {
        print("⚠️ Error ambil data profile-siswa: $e");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['msg'] ?? "Login berhasil")),
      );

      Navigator.pushReplacementNamed(context, '/main');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['msg'] ?? "Login gagal")),
      );
    }
  } catch (e) {
    print("❌ Error Login: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan: $e")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ⚙️ UI TIDAK DIRUBAH SAMA SEKALI SESUAI PERMINTAANMU
          // hanya logic login di atas yang diupdate
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E90FF), Color(0xFF00BFFF)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 180,
                  top: -120,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                ),
                Positioned(
                  left: -80,
                  top: -20,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Positioned(
                  right: -40,
                  top: 40,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 🧩 bagian UI lainnya tetap sama seperti yang kamu punya
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              transform: Matrix4.translationValues(0, -35, 0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 35),
                    Container(
                      height: 60,
                      child: Image.asset(
                        'assets/medima.jpeg',
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: MediaQuery.of(context).size.width * 0.35,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text(
                      'Selamat Datang!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Silahkan login untuk akun Anda',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInputFields(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🧩 Pindahkan form input agar rapi
  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
        const SizedBox(height: 22),
        // Password
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
        const SizedBox(height: 35),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0099FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
