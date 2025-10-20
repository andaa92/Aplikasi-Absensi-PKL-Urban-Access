import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:local_auth/local_auth.dart';

// Tambahan untuk enkripsi (alias enc)
import 'package:encrypt/encrypt.dart' as enc;
import 'package:crypto/crypto.dart';
import 'dart:typed_data';
import 'dart:math';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication(); // ✅ Tambahan

  bool _isPasswordVisible = false;
  bool _hasLoggedInBefore = false;

  @override
  void initState() {
    super.initState();
    _checkLoginHistory(); // ✅ cek apakah pernah login
  }

  Future<void> _checkLoginHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasLogin = prefs.containsKey('email') &&
        prefs.containsKey('id_device') &&
        prefs.containsKey('password_enc');
    setState(() {
      _hasLoggedInBefore = hasLogin;
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
      } else {
        deviceId = 'unknown_platform';
      }
    } catch (e) {
      print('Gagal mendapatkan device ID: $e');
    }
    print('🔍 Device ID: $deviceId');
    return deviceId;
  }

  // ------------------------------
  // ENCRYPT / DECRYPT UTIL
  // keySource = deviceId + email
  // ------------------------------
  Uint8List _sha256Bytes(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  // Encrypt password -> store as base64(iv + cipher)
  String _encryptPassword(String password, String keySource) {
    final keyBytes = _sha256Bytes(keySource); // 32 bytes
    final key = enc.Key(keyBytes);
    final iv = enc.IV.fromSecureRandom(16); // 16 bytes IV

    final encrypter =
        enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(password, iv: iv);

    // combine iv + cipher bytes, then base64 encode
    final combined = Uint8List.fromList(iv.bytes + encrypted.bytes);
    return base64Encode(combined);
  }

  String? _tryDecryptPassword(String base64Combined, String keySource) {
    try {
      final combined = base64Decode(base64Combined);
      if (combined.length < 17) return null; // invalid
      final ivBytes = combined.sublist(0, 16);
      final cipherBytes = combined.sublist(16);

      final keyBytes = _sha256Bytes(keySource);
      final key = enc.Key(keyBytes);
      final iv = enc.IV(Uint8List.fromList(ivBytes));

      final encrypter =
          enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'));
      final decrypted = encrypter.decrypt(
        enc.Encrypted(Uint8List.fromList(cipherBytes)),
        iv: iv,
      );
      return decrypted;
    } catch (e) {
      print('Decrypt error: $e');
      return null;
    }
  }

  // ------------------------------
  // Save credentials setelah login manual berhasil
  // ------------------------------
  Future<void> _saveCredentialsEncrypted(String email, String password) async {
    try {
      final deviceId = await _getDeviceId();
      final keySource = deviceId + email;
      final encPass = _encryptPassword(password, keySource);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('id_device', deviceId);
      await prefs.setString('password_enc', encPass);
      print('Credentials saved (encrypted).');
      setState(() {
        _hasLoggedInBefore = true;
      });
    } catch (e) {
      print('Gagal menyimpan kredensial terenkripsi: $e');
    }
  }

  // ------------------------------
  // Fungsi login manual (tidak banyak diubah selain menyimpan password terenkripsi)
  // ------------------------------
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

      print('Response body: ${response.body}');
      var data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['statusCode'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', data['email'] ?? email);
        await prefs.setString('id_device', data['id_device'] ?? deviceId);
        await prefs.setString('token', data['token'] ?? '');

        // Simpan password terenkripsi (opsi B + enkripsi dinamis)
        await _saveCredentialsEncrypted(email, password);

        setState(() {
          _hasLoggedInBefore = true;
        });

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

  // ------------------------------
  // Reusable: panggil API login dengan kredensial yang ada
  // ------------------------------
  Future<bool> _callApiLogin(
    String email,
    String password,
    String deviceId,
  ) async {
    try {
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

      print('quick login response body: ${response.body}');
      var data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['statusCode'] == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', data['email'] ?? email);
        await prefs.setString('id_device', data['id_device'] ?? deviceId);
        await prefs.setString('token', data['token'] ?? '');
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['msg'] ?? "Login cepat gagal")),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan saat login cepat: $e")),
      );
      return false;
    }
  }

  // ------------------------------
  // Handler biometrik yang dipilih user (Fingerprint / Face)
  // ------------------------------
  Future<void> _loginDenganBiometrik(BiometricType tipe) async {
    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      bool isSupported = await _auth.isDeviceSupported();

      if (!canCheckBiometrics || !isSupported) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perangkat tidak mendukung biometrik")),
        );
        return;
      }

      final available = await _auth.getAvailableBiometrics();
      // Note: on some devices / Android versions, biometric types might be reported differently.
      if (!available.contains(tipe)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tipe == BiometricType.face
                  ? "Face ID tidak tersedia pada perangkat ini"
                  : "Fingerprint tidak tersedia pada perangkat ini",
            ),
          ),
        );
        return;
      }

      bool didAuthenticate = await _auth.authenticate(
        localizedReason: tipe == BiometricType.face
            ? 'Gunakan Face ID untuk login cepat'
            : 'Gunakan fingerprint untuk login cepat',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        // Ambil data tersimpan
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString('email');
        final savedDevice = prefs.getString('id_device');
        final savedEncPass = prefs.getString('password_enc');

        if (savedEmail == null || savedDevice == null || savedEncPass == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Tidak ada kredensial tersimpan. Silakan login manual terlebih dahulu.",
              ),
            ),
          );
          return;
        }

        final currentDevice = await _getDeviceId();

        // Pastikan device cocok
        if (savedDevice != currentDevice) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Perangkat tidak cocok, login manual diperlukan"),
            ),
          );
          return;
        }

        // Derive keySource sama seperti saat menyimpan: deviceId + email
        final keySource = currentDevice + savedEmail;
        final password = _tryDecryptPassword(savedEncPass, keySource);

        if (password == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Gagal mendekripsi password. Silakan login manual.",
              ),
            ),
          );
          return;
        }

        // Panggil API login (sesuai pilihan B)
        bool ok = await _callApiLogin(savedEmail, password, currentDevice);

        if (ok) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login cepat berhasil")));
          Navigator.pushReplacementNamed(context, '/main');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal autentikasi biometrik: $e")),
      );
    }
  }

  // (Opsional) tetap sediakan _loginCepat() jika ada pemanggilan lain, pakai default biometric flow
  Future<void> _loginCepat() async {
    // fallback generic biometric: gunakan availableBiometrics[0] jika ada
    try {
      final available = await _auth.getAvailableBiometrics();
      if (available.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometrik tidak tersedia")),
        );
        return;
      }
      // pilih tipe pertama yang available (biasanya fingerprint atau face)
      final tipe = available.first;
      await _loginDenganBiometrik(tipe);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login cepat gagal: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header biru gradient (tidak diubah)
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

          // Isi body (tetap sama)
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

                    // 🔹 Field email & password (tidak diubah)
                    _buildTextField(
                      'Email',
                      Icons.email_outlined,
                      _emailController,
                    ),
                    const SizedBox(height: 22),
                    _buildPasswordField(),

                    const SizedBox(height: 35),

                    // Tombol login utama
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
                          elevation: 0,
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

                    // ✅ Tampilkan login cepat hanya jika pernah login
                    if (_hasLoggedInBefore) ...[
                      const SizedBox(height: 18),
                      const Text(
                        'Login dengan cara cepat',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickLoginButton(
                            icon: Icons.fingerprint,
                            label: 'Finger Print',
                            onTap: () => _loginDenganBiometrik(
                              BiometricType.fingerprint,
                            ),
                          ),
                          const SizedBox(width: 45),
                          _buildQuickLoginButton(
                            icon: Icons.face,
                            label: 'Face ID',
                            onTap: () =>
                                _loginDenganBiometrik(BiometricType.face),
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

  // 🔹 Helper: textfield
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
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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

  // 🔹 Helper: password field
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
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  // 🔹 Helper: quick login button
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
