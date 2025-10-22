import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();

  bool _isPasswordVisible = false;
  bool _hasLoggedInBefore = false;
  BiometricType? _selectedBiometric;

  @override
  void initState() {
    super.initState();
    _checkLoginHistory();
  }

  Future<void> _checkLoginHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasLogin =
        prefs.containsKey('email') && prefs.containsKey('id_device');
    String? savedBiometric = prefs.getString('selected_biometric');

    setState(() {
      _hasLoggedInBefore = hasLogin;
      if (savedBiometric == 'face') {
        _selectedBiometric = BiometricType.face;
      } else if (savedBiometric == 'fingerprint') {
        _selectedBiometric = BiometricType.fingerprint;
      }
    });
  }

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
      print('Gagal mendapatkan device ID: $e');
    }
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

      var data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['statusCode'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', data['email'] ?? email);
        await prefs.setString('id_device', data['id_device'] ?? deviceId);
        await prefs.setString('token', data['token'] ?? '');

        final emailUser = data['email'];
        if (emailUser == null || emailUser.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login gagal: Email user kosong")),
          );
          return;
        }

        // 🔹 Ambil profile siswa
        try {
          final profileResponse = await http.get(
            Uri.parse(
              'https://hr.urbanaccess.net/api/profile-siswa?userPkl=$emailUser',
            ),
            headers: {'Accept': 'application/json'},
          );

          print("📡 Response Profile: ${profileResponse.body}");

          if (profileResponse.statusCode == 200) {
            final profileData = jsonDecode(profileResponse.body);
            final siswa = profileData['data'];

            if (siswa != null) {
              await prefs.setString('nama', siswa['nama_siswa'] ?? '');
              await prefs.setString('nsm', siswa['nsm'] ?? '');
              await prefs.setString('sekolah', siswa['nama_sekolah'] ?? '');
              await prefs.setString('jurusan', siswa['nama_jurusan'] ?? '');
              await prefs.setString('userPkl', emailUser);
              print("✅ Profil siswa tersimpan: ${siswa['nama_siswa']}");
            } else {
              print("⚠ Data siswa kosong di API profile-siswa");
            }
          }
        } catch (e) {
          print("⚠ Error ambil data profile-siswa: $e");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['msg'] ?? "Login berhasil")),
        );

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['msg'] ?? "Login gagal")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  Future<void> _loginCepat() async {
    try {
      bool didAuthenticate = await _auth.authenticate(
        localizedReason:
            _selectedBiometric == BiometricType.face
                ? 'Gunakan Face ID untuk login cepat'
                : 'Gunakan sidik jari untuk login cepat',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('email');
        final savedDevice = prefs.getString('id_device');
        final currentDevice = await _getDeviceId();

        if (savedDevice == currentDevice && savedEmail != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login cepat berhasil")));
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Perangkat tidak cocok, login manual diperlukan"),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal autentikasi biometrik: $e")),
      );
    }
  }

  /// ✅ Satu-satunya versi fungsi autentikasi biometrik yang benar
  Future<void> _autentikasiBiometrik(BiometricType tipe) async {
    try {
      bool authenticated = await _auth.authenticate(
        localizedReason:
            tipe == BiometricType.face
                ? 'Gunakan Face ID untuk login cepat'
                : 'Gunakan sidik jari untuk login cepat',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tipe == BiometricType.face
                  ? 'Login dengan Face ID berhasil!'
                  : 'Login dengan sidik jari berhasil!',
            ),
            backgroundColor: Colors.cyan.shade600,
          ),
        );

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autentikasi gagal, coba lagi')),
        );
      }
    } catch (e) {
      print("Error autentikasi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat autentikasi')),
      );
    }
  }

  Future<void> _pilihMetodeBiometrik() async {
    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      bool isSupported = await _auth.isDeviceSupported();

      if (!canCheckBiometrics || !isSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perangkat tidak mendukung biometrik")),
        );
        return;
      }

      List<BiometricType> available = await _auth.getAvailableBiometrics();

      if (available.isEmpty) {
        available = [BiometricType.fingerprint, BiometricType.face];
      }

      BiometricType? selectedType = await showModalBottomSheet<BiometricType>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.5,
            widthFactor: 1.0,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Pilih Metode Login Cepat",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildBiometricCard(
                    icon: Icons.fingerprint,
                    title: "Gunakan Fingerprint",
                    subtitle: "Login cepat dengan sidik jari",
                    onTap:
                        () => Navigator.pop(context, BiometricType.fingerprint),
                  ),
                  const SizedBox(height: 20),
                  _buildBiometricCard(
                    icon: Icons.face,
                    title: "Gunakan Face ID",
                    subtitle: "Login cepat dengan pemindai wajah",
                    onTap: () => Navigator.pop(context, BiometricType.face),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Colors.cyan, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (selectedType != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'selected_biometric',
          selectedType == BiometricType.face ? 'face' : 'fingerprint',
        );

        setState(() {
          _selectedBiometric = selectedType;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.cyan.shade600,
            content: Row(
              children: [
                Icon(
                  selectedType == BiometricType.face
                      ? Icons.face
                      : Icons.fingerprint,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  selectedType == BiometricType.face
                      ? "Face ID berhasil diaktifkan!"
                      : "Fingerprint berhasil diaktifkan!",
                ),
              ],
            ),
          ),
        );

        // Setelah pilih metode, langsung jalankan autentikasi
        await _autentikasiBiometrik(selectedType);
      }
    } catch (e) {
      print("Error biometrik: $e");
    }
  }

  Widget _buildBiometricCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE0F7FA),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.cyan, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        onTap: onTap,
      ),
    );
  }

  // --- UI build tetap sama, tidak diubah sedikit pun ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E90FF), Color(0xFF00BFFF)],
              ),
            ),
          ),
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
                    Image.asset(
                      'assets/medima.jpeg',
                      width: MediaQuery.of(context).size.width * 0.35,
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
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      'Email',
                      Icons.email_outlined,
                      _emailController,
                    ),
                    const SizedBox(height: 22),
                    _buildPasswordField(),
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
                          ),
                        ),
                      ),
                    ),
                    if (_hasLoggedInBefore && _selectedBiometric == null) ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pilihMetodeBiometrik,
                        icon: const Icon(
                          Icons.fingerprint,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Pilih Metode Login Cepat",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                    if (_selectedBiometric != null) ...[
                      const SizedBox(height: 22),
                      const Text(
                        'Login dengan cara cepat',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickLoginButton(
                            icon:
                                _selectedBiometric == BiometricType.face
                                    ? Icons.face
                                    : Icons.fingerprint,
                            label:
                                _selectedBiometric == BiometricType.face
                                    ? 'Face ID'
                                    : 'Fingerprint',
                            onTap: _loginCepat,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
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
          prefixIcon: Icon(
            Icons.lock_outline,
            color: Colors.grey.shade500,
            size: 22,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey.shade500,
              size: 22,
            ),
            onPressed:
                () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE8F5F9),
          ),
          child: IconButton(
            icon: Icon(icon, color: Color(0xFF00BCD4), size: 32),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}