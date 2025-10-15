import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class AbsenFinger extends StatefulWidget {
  const AbsenFinger({super.key});

  @override
  State<AbsenFinger> createState() => _AbsenFingerState();
}

class _AbsenFingerState extends State<AbsenFinger> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  Future<void> _authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Letakkan jari Anda pada sensor fingerprint',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;

      setState(() {
        _isAuthenticated = didAuthenticate;
      });
    } catch (e) {
      debugPrint("Error autentikasi fingerprint: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan efek lingkaran gradasi
            Stack(
              children: [
                Container(
                  height: 240,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2196F3),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: -150,
                        child: Container(
                          width: 600,
                          height: 600,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1976D2).withOpacity(0.4),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -120,
                        child: Container(
                          width: 500,
                          height: 500,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E88E5).withOpacity(0.5),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -90,
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF42A5F5).withOpacity(0.6),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -60,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF64B5F6).withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol back
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            // Konten utama
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              transform: Matrix4.translationValues(0, -30, 0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/medima.jpeg',
                      height: 150,
                      errorBuilder: (context, error, stackTrace) {
                        return const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.apps, color: Colors.red, size: 24),
                            SizedBox(width: 6),
                            Text(
                              'MEDIMA',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Login dengan Finger Print',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Silahkan letakkan jari Anda pada sensor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Area fingerprint besar
                    GestureDetector(
                      onTap: _authenticate,
                      child: Container(
                        width: double.infinity,
                        height: 350,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _isAuthenticated
                                ? Icons.check_circle
                                : Icons.fingerprint,
                            size: 120,
                            color: _isAuthenticated
                                ? Colors.green
                                : Colors.black38,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_isAuthenticated)
                      const Text(
                        '✅ Fingerprint berhasil diverifikasi!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
