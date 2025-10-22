import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Controller untuk rotasi lingkaran
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(); // Repeat untuk rotasi terus menerus

    // Controller untuk fade in logo dan text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Mulai animasi fade in
    _fadeController.forward();

    // Delay 3 detik sebelum pindah ke LoginPage
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0080FF), Color(0xFF0099FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Text kecil di kiri atas
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 15),
                  child: Text(
                    'Landing Page',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Logo / animasi utama
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Lingkaran terluar - rotasi lambat
                          Transform.rotate(
                            angle: _rotationController.value * 2 * 3.14159,
                            child: Container(
                              width: 320,
                              height: 320,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          // Lingkaran kedua - rotasi sedang berlawanan
                          Transform.rotate(
                            angle: -_rotationController.value * 1.5 * 3.14159,
                            child: Container(
                              width: 260,
                              height: 260,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                          ),
                          // Lingkaran ketiga - rotasi cepat
                          Transform.rotate(
                            angle: _rotationController.value * 2.5 * 3.14159,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                          ),
                          // Logo dengan fade in animation
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/logo.jpeg',
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Text motivasi dengan fade in
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: const [
                      Text(
                        'Setiap kehadiran adalah',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'langkah menuju kesuksesan!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Divider(
                        color: Colors.white,
                        thickness: 2,
                        indent: 120,
                        endIndent: 120,
                      ),
                    ],
                  ),
                ),
              ),

              // Loading text
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  'Memuat Aplikasi...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
