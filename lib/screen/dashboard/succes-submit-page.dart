import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:absensi_pkl_urban/screen/dashboard/dashboard-page.dart';

class SuccessSubmitPage extends StatefulWidget {
  const SuccessSubmitPage({Key? key}) : super(key: key);

  @override
  State<SuccessSubmitPage> createState() => _SuccessSubmitPageState();
}

class _SuccessSubmitPageState extends State<SuccessSubmitPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();

  
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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
            colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: ConcentricCirclesPainter(),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _checkAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(90, 90),
                              painter: CheckMarkPainter(
                                progress: _checkAnimation.value,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeTransition(
                    opacity: _checkAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'Anda telah berhasil submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 120,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for concentric circles
class ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2.8);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 80;

    final circles = [
      {'radius': 120.0, 'opacity': 0.15},
      {'radius': 200.0, 'opacity': 0.12},
      {'radius': 280.0, 'opacity': 0.09},
      {'radius': 360.0, 'opacity': 0.06},
      {'radius': 440.0, 'opacity': 0.03},
    ];

    for (var circle in circles) {
      paint.color = Colors.white.withOpacity(circle['opacity'] as double);
      canvas.drawCircle(center, circle['radius'] as double, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for animated checkmark
class CheckMarkPainter extends CustomPainter {
  final double progress;

  CheckMarkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    final startPoint = Offset(size.width * 0.2, size.height * 0.5);
    final middlePoint = Offset(size.width * 0.4, size.height * 0.7);
    final endPoint = Offset(size.width * 0.8, size.height * 0.3);

    final firstSegmentLength = (middlePoint - startPoint).distance;
    final secondSegmentLength = (endPoint - middlePoint).distance;
    final totalLength = firstSegmentLength + secondSegmentLength;

    if (progress > 0) {
      path.moveTo(startPoint.dx, startPoint.dy);

      if (progress <= firstSegmentLength / totalLength) {
        final currentProgress = progress * totalLength / firstSegmentLength;
        final currentPoint = Offset(
          startPoint.dx + (middlePoint.dx - startPoint.dx) * currentProgress,
          startPoint.dy + (middlePoint.dy - startPoint.dy) * currentProgress,
        );
        path.lineTo(currentPoint.dx, currentPoint.dy);
      } else {
        path.lineTo(middlePoint.dx, middlePoint.dy);
        final secondProgress =
            (progress - firstSegmentLength / totalLength) /
                (secondSegmentLength / totalLength);
        final currentPoint = Offset(
          middlePoint.dx + (endPoint.dx - middlePoint.dx) * secondProgress,
          middlePoint.dy + (endPoint.dy - middlePoint.dy) * secondProgress,
        );
        path.lineTo(currentPoint.dx, currentPoint.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CheckMarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}