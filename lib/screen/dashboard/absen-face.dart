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
  int _frameCount = 0; // untuk skip frame

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
      ResolutionPreset.medium, // ✅ lebih ringan dari high
      enableAudio: false,
    );

    await _controller!.initialize();
    await _controller!.startImageStream(_processImage);

    if (mounted) setState(() {});
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isDetecting) return;
    _frameCount++;

    // ✅ deteksi hanya tiap 3 frame untuk kurangi beban CPU
    if (_frameCount % 3 != 0) return;

    _isDetecting = true;

    try {
      final bytesBuilder = BytesBuilder();
      for (final Plane plane in image.planes) {
        bytesBuilder.add(plane.bytes);
      }
      final bytes = bytesBuilder.toBytes();

      final rotation =
          InputImageRotationValue.fromRawValue(_controller!.description.sensorOrientation) ??
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

      // ✅ jangan panggil setState terus menerus (cek perubahan dulu)
      final faceDetectedNow = faces.isNotEmpty;
      if (faceDetectedNow != _faceDetected) {
        setState(() {
          _faceDetected = faceDetectedNow;
        });
      }

      if (faceDetectedNow) {
        _faceDetectedCount++;
      } else {
        _faceDetectedCount = 0;
      }

      // ✅ Jika wajah stabil 10 frame
      if (_faceDetectedCount >= 10) {
        await _controller?.stopImageStream();
        await _controller?.dispose();
        _controller = null;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Wajah terverifikasi, absen berhasil!")),
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
          // Header biru
          Stack(
            children: [
              Container(
                height: 240,
                decoration: const BoxDecoration(color: Color(0xFF2196F3)),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    for (var i = 0; i < 4; i++)
                      Positioned(
                        top: -150 + (i * 30),
                        child: Container(
                          width: 600 - (i * 100),
                          height: 600 - (i * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue[(700 - (i * 100))]!.withOpacity(0.5),
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

                      // Kamera Preview
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.45,
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
                                child: AspectRatio(
                                  aspectRatio: _controller!.value.aspectRatio,
                                  child: FittedBox(
                                    fit: BoxFit.cover, // ✅ agar tidak ngezoom
                                    child: SizedBox(
                                      width: _controller!.value.previewSize!.height,
                                      height: _controller!.value.previewSize!.width,
                                      child: CameraPreview(_controller!),
                                    ),
                                  ),
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
