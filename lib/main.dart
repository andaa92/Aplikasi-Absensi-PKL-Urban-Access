import 'package:absensi_pkl_urban/screen/dashboard/absen-face.dart';
import 'package:absensi_pkl_urban/screen/dashboard/absen-finger.dart';
import 'package:flutter/material.dart';
import 'package:absensi_pkl_urban/screen/main-page.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-izin.dart';
import 'package:absensi_pkl_urban/screen/dashboard/form-sakit.dart';
import 'package:absensi_pkl_urban/screen/login/landing-page.dart';
import 'package:absensi_pkl_urban/screen/login/login-page.dart';
import 'package:absensi_pkl_urban/screen/dashboard/succes-submit-page.dart';

  import 'package:intl/date_symbol_data_local.dart';


  


// Ensure that the file 'success-submit-page.dart' contains a class named 'SuccessSubmitPage'

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard Absensi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),

      // home: const MainPage(),

      initialRoute: '/landing', // <-- Mulai dari LandingPage
      routes: {
        '/izin': (context) => const FormIzin(),
        '/sakit': (context) => const FormSakit(),
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/main': (context) => const MainPage(),
        '/success': (context) => const SuccessSubmitPage(),
        '/face': (context) => const AbsenFace(),
        '/finger': (context) => const AbsenFinger(),
      },
    );
  }
}
