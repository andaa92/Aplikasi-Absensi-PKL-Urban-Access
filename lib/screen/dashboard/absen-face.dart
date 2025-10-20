import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class AbsenFace extends StatefulWidget {
  const AbsenFace({super.key});

  @override
  State<AbsenFace> createState() => _AbsenFaceState();
}

class _AbsenFaceState extends State<AbsenFace> {
  CameraController? _controller;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  bool _faceDetected = false;
  int _faceDetectedCount = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
      ),
    );
  }

  Future<void> _initCamera() async {
    await Permission.camera.request();

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();
    _controller!.startImageStream(_processImage);

    if (mounted) setState(() {});
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
              final bytesBuilder = BytesBuilder();
        for (final Plane plane in image.planes) {
          bytesBuilder.add(plane.bytes);
        }
        final bytes = bytesBuilder.toBytes();

      final camera = _controller!.description;
      final rotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final format =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21;

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
      final faces = await _faceDetector.processImage(inputImage);

      setState(() {
        _faceDetected = faces.isNotEmpty;
        if (_faceDetected) {
          _faceDetectedCount++;
        } else {
          _faceDetectedCount = 0;
        }
      });

      // Jika wajah stabil terdeteksi 10 kali (±2 detik)
      if (_faceDetectedCount >= 10) {
        await _controller?.stopImageStream();
        await _controller?.dispose();
        _controller = null;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Wajah terverifikasi, absen berhasil!"),
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      debugPrint('Error deteksi wajah: $e');
    } finally {
      _isDetecting = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header biru dengan efek lingkaran
          Stack(
            children: [
              Container(
                height: 240,
                decoration: const BoxDecoration(color: Color(0xFF2196F3)),
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
            ],
          ),

          // Body utama
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              transform: Matrix4.translationValues(0, -30, 0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/medima.jpeg',
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'MEDIMA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Login dengan Face ID',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Silahkan arahkan kamera ke wajah Anda',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 30),

                      // 🔥 Area kamera proporsional
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.5,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: _controller == null ||
                                !_controller!.value.isInitialized
                            ? const Center(child: CircularProgressIndicator())
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final screenRatio = constraints.maxWidth /
                                        constraints.maxHeight;
                                    final cameraRatio =
                                        _controller!.value.aspectRatio;
                                    final scale = cameraRatio / screenRatio;

                                    return Transform.scale(
                                      scale: scale,
                                      alignment: Alignment.center,
                                      child: AspectRatio(
                                        aspectRatio: cameraRatio,
                                        child: CameraPreview(_controller!),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),

                      if (_faceDetected)
                        const Text(
                          '✅ Wajah terdeteksi!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
