import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _circleController;
  late AnimationController _dividerController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _logoFadeAnimation;
  late Animation<double> _circleRotationAnimation;
  late Animation<double> _dividerAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();

    // Loading animation (pulsing effect)
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _loadingAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    // Logo fade in animation (0.8 detik)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    // Circle rotation animation (berputar terus menerus)
    _circleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _circleRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_circleController);

    // Divider expand animation (0.5 detik, mulai setelah logo selesai)
    _dividerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _dividerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dividerController, curve: Curves.easeOut),
    );

    // Text slide animation (0.5 detik, mulai setelah divider selesai)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // dari bawah (positif)
      end: Offset.zero, // ke posisi normal
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Jalankan animasi secara berurutan
    _startAnimations();

    // Delay 4 detik sebelum pindah ke LoginPage
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _startAnimations() async {
    // Mulai animasi logo dan circle bersamaan
    _logoController.forward();

    // Tunggu logo selesai, lalu jalankan divider
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _dividerController.forward();

    // Tunggu divider selesai, lalu jalankan text slide
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _circleController.dispose();
    _dividerController.dispose();
    _textController.dispose();
    _loadingController.dispose();
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
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: Padding(
              //     padding: const EdgeInsets.only(left: 20, top: 15),
              //     child: Text(
              //       'Landing Page',
              //       style: TextStyle(
              //         color: Colors.white.withOpacity(0.9),
              //         fontSize: 12,
              //         fontWeight: FontWeight.w400,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 40),

              // Logo / animasi utama dengan circle berputar
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _circleController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Circle terluar - berputar
                          Transform.rotate(
                            angle: _circleRotationAnimation.value * 2 * 3.14159,
                            child: Container(
                              width: 320,
                              height: 320,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          // Circle kedua - berputar berlawanan arah
                          Transform.rotate(
                            angle:
                                -_circleRotationAnimation.value * 2 * 3.14159,
                            child: Container(
                              width: 260,
                              height: 260,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                          ),
                          // Circle ketiga - berputar
                          Transform.rotate(
                            angle: _circleRotationAnimation.value * 2 * 3.14159,
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
                            opacity: _logoFadeAnimation,
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

              // Text motivasi dengan animasi
              Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  children: [
                    // Text slide dari bawah
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textController,
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Divider dengan animasi expand dari tengah
                    AnimatedBuilder(
                      animation: _dividerAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 240 * _dividerAnimation.value,
                          height: 2,
                          color: Colors.white,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Loading text dengan pulsing animation
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: FadeTransition(
                  opacity: _loadingAnimation,
                  child: Text(
                    'Memuat Aplikasi...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
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
