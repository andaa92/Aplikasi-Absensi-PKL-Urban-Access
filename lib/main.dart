
import 'package:absensi_pkl_urban/screen/login/login-page.dart';
import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:absensi_pkl_urban/screen/profile-page.dart';
import 'package:absensi_pkl_urban/screen/login/landing-page.dart';
import 'package:absensi_pkl_urban/screen/dashboard/absen-face.dart';
import 'package:absensi_pkl_urban/screen/dashboard/absen-finger.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-izin.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-sakit.dart';

import 'package:intl/date_symbol_data_local.dart';

// Ensure that the file 'landing-page.dart' contains a class named 'LandingPage'


  


// Ensure that the file 'success-submit-page.dart' contains a class named 'SuccessSubmitPage'

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absensi PKL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialRoute: '/',
       // Mulai dari landing
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const MainPage(),
        '/main': (context) => const MainPage(),
        '/form-izin': (context) => const FormIzin(),
        '/form-sakit': (context) => const FormSakit(),
        '/face': (context) => const AbsenFace(),
        '/finger': (context) => const AbsenFinger(),

      },
    );
  }
}